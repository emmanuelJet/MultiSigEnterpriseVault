// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.27;

import '../libraries/Counters.sol';
import '../libraries/AddressUtils.sol';
import '../utilities/VaultConstants.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import {EnumerableSet} from '@openzeppelin/contracts/utils/structs/EnumerableSet.sol';
import {IMultiSigTransaction} from '../interfaces/IMultiSigTransaction.sol';
import {Transaction} from '../utilities/VaultStructs.sol';
import {MultiSigTimelock} from './MultiSigTimelock.sol';
import {SafeMath} from '../libraries/SafeMath.sol';

/**
 * @title MultiSigTransaction
 * @author Emmanuel Joseph (JET)
 * @dev Manages transaction initiation, approval, and execution for ETH and ERC20 transfers.
 */
abstract contract MultiSigTransaction is MultiSigTimelock, IMultiSigTransaction {
  using EnumerableSet for EnumerableSet.AddressSet;
  using Counters for Counters.Counter;
  using SafeMath for uint256;

  /// @notice Stores the check for a pending transaction that requires approvals
  bool private _isPendingTransaction;

  /// @notice Using Counter library for total transactions
  Counters.Counter private _transactionCount;

  /// @notice Mapping to store all transactions by their ID
  mapping(uint256 => Transaction) private _transactions;

  /**
   * @dev Initializes the `MultiSigTransaction` and `MultiSigTimelock` contracts.
   * @param owner The address of the contract owner.
   * @param initialThreshold The initial threshold for signatory approval.
   * @param initialMultiSigTimelock The initial timelock for signatory approval.
   * @param initialOwnerOverrideTimelock The initial timelock for owner override.
   */
  constructor(
    address owner,
    uint256 initialThreshold,
    uint256 initialMultiSigTimelock,
    uint256 initialOwnerOverrideTimelock
  ) MultiSigTimelock(owner, initialThreshold, initialMultiSigTimelock, initialOwnerOverrideTimelock) {}

  /**
   * @dev Modifier to ensure a valid vault transaction.
   * Reverts with `InvalidTransaction` if the given transaction ID is invalid.
   * @param txId The ID of the transaction to validate.
   */
  modifier validTransaction(
    uint256 txId
  ) {
    if (txId == 0 || txId > _transactionCount.current()) {
      revert InvalidTransaction(txId);
    }
    _;
  }

  /**
   * @dev Modifier to ensure a valid vault transaction has't been executed.
   * Reverts with `TransactionAlreadyExecuted` if the valid transaction has been executed.
   * @param txId The ID of the transaction to validate.
   */
  modifier pendingTransaction(
    uint256 txId
  ) {
    if (_transactions[txId].isExecuted) {
      revert TransactionAlreadyExecuted(txId);
    }
    _;
  }

  /**
   * Receives ETH sent to the contract and emits `FundsReceived` event
   */
  receive() external payable {
    emit FundsReceived(_msgSender(), address(0), msg.value);
  }

  /**
   * @inheritdoc IMultiSigTransaction
   */
  function depositToken(address token, uint256 amount) external nonReentrant payable {
    uint256 allowance = IERC20(token).allowance(_msgSender(), address(this));

    if (allowance < amount) {
      uint256 remainingAllowance = amount.subtract(allowance);
      revert ERC20InsufficientAllowance(_msgSender(), allowance, remainingAllowance);
    }

    IERC20(token).transferFrom(_msgSender(), address(this), amount);
    emit FundsReceived(_msgSender(), token, amount);
  }

  /**
   * @notice Initiates a new transaction by an Owner or Signer.
   * @param to The address receiving the transaction token.
   * @param value The amount of ETH or tokens to send.
   * @param token The ERC20 token address (0x0 for ETH).
   * @param data The transaction data (0x0 for empty data).
   */
  function initiateTransaction(
    address payable to,
    address token,
    uint256 value,
    bytes memory data
  ) public validSigner isExecutable nonReentrant {
    AddressUtils.requireValidTransactionReceiver(to);
    if (_isPendingTransaction) revert PendingTransactionState(_isPendingTransaction);

    if (token == address(0)) {
      if (value > getBalance()) revert InsufficientTokenBalance(getBalance(), value);
    } else {
      if (value > getTokenBalance(token)) revert InsufficientTokenBalance(getTokenBalance(token), value);
    }

    _isPendingTransaction = true;
    _transactionCount.increment();
    uint256 transactionId = _transactionCount.current();
    Transaction storage txn = _transactions[transactionId];

    txn.initiator = _msgSender();
    txn.to = to;
    txn.token = token;
    txn.value = value;
    txn.timestamp = block.timestamp;
    txn.data = data;

    emit TransactionInitiated(transactionId, _msgSender(), to, token, value);
  }

  /**
   * @notice Enables valid signers to approve a transaction.
   * @param txId The ID of the transaction to approve.
   */
  function approveTransaction(
    uint256 txId
  ) public validSigner validTransaction(txId) pendingTransaction(txId) {
    Transaction storage txn = _transactions[txId];
    if (txn.signatures.contains(_msgSender())) revert TransactionNotApproved(txId);

    txn.approvals.increment();
    txn.signatures.add(_msgSender());
    emit TransactionApproved(txId, _msgSender(), block.timestamp);
  }

  /**
   * @notice Enables valid signers to revokes a transaction approval.
   * @param txId The ID of the transaction to revoke approval for.
   */
  function revokeTransactionApproval(
    uint256 txId
  ) public validSigner validTransaction(txId) pendingTransaction(txId) {
    Transaction storage txn = _transactions[txId];
    if (!txn.signatures.contains(_msgSender())) revert TransactionNotApproved(txId);

    txn.approvals.decrement();
    txn.signatures.remove(_msgSender());
    emit TransactionRevoked(txId, _msgSender(), block.timestamp);
  }

  /**
   * @notice Executes a transaction if the threshold is met.
   * @param txId The ID of the transaction to execute.
   */
  function executeTransaction(
    uint256 txId
  ) public validExecutor validTransaction(txId) pendingTransaction(txId) nonReentrant {
    uint256 executionTimestamp = block.timestamp;
    Transaction storage txn = _transactions[txId];
    if (!_isMultiSigTimelockElapsed(txn.timestamp)) {
      uint256 requiredTime = txn.timestamp.add(multiSigTimelock);
      revert TimelockNotElapsed(requiredTime, executionTimestamp);
    }

    if (_isOwner(_msgSender())) {
      if (!txn.signatures.contains(_msgSender())) revert TransactionNotApproved(txId);
      if (!_isSignatoryThresholdMet(txn.approvals.current())) {
        revert InsufficientSignerApprovals(signatoryThreshold, txn.approvals.current());
      }
    }

    if (_isExecutor(_msgSender()) && txn.approvals.current() < signatoryThreshold) {
      txn.isOverride = true;
    }

    txn.isExecuted = true;
    _isPendingTransaction = false;
    if (txn.token == address(0)) {
      // Send ETH
      Address.sendValue(txn.to, txn.value);
    } else {
      // Send ERC20 tokens
      IERC20 token = IERC20(txn.token);
      SafeERC20.safeTransfer(token, txn.to, txn.value);
    }

    emit TransactionExecuted(txId, _msgSender(), block.timestamp);
  }

  /**
   * @notice Deletes the latest transaction item if not executed.
   * @dev Only callable by a contract executor (Owner or Executor)
   */
  function deletePendingTransaction() public validExecutor {
    if (!_isPendingTransaction) revert PendingTransactionState(_isPendingTransaction);

    uint256 latestTxId = _transactionCount.current();
    if (_transactions[latestTxId].isExecuted) {
      revert ActionAlreadyExecuted(latestTxId);
    }

    delete _transactions[latestTxId];
    _transactionCount.decrement();
  }

  /**
   * @notice Returns the balance of ETH held in the contract.
   * @return The ETH balance of the contract.
   */
  function getBalance() public view returns (uint256) {
    return address(this).balance;
  }

  /**
   * @notice Returns the balance of a specific ERC20 token held in the contract.
   * @param token The ERC20 token address.
   * @return The token balance of the contract.
   */
  function getTokenBalance(
    address token
  ) public view returns (uint256) {
    return IERC20(token).balanceOf(address(this));
  }

  /**
   * @notice Returns the total number of transactions.
   * @return uint256 The total number of transactions.
   * @dev Only callable by the owner.
   */
  function totalTransactions() public view returns (uint256) {
    return _transactionCount.current();
  }

  /**
   * @notice Returns the transaction details of a given ID, excluding signatures.
   * @param txId The ID of the requested transaction.
   * @return initiator The address of the transaction initiator.
   * @return to The address receiving the transaction tokens.
   * @return token The token contract address (0x0 for ETH).
   * @return value The ETH or token value to send.
   * @return approvals The total number of approvals.
   * @return isExecuted Whether the transaction has been executed.
   * @return isOverride Whether the transaction was overridden by the executor.
   * @return data The transaction data (0x0 for empty data).
   */
  function getTransaction(
    uint256 txId
  )
    public
    view
    onlyUser
    validTransaction(txId)
    returns (
      address initiator,
      address to,
      address token,
      uint256 value,
      uint256 approvals,
      bool isExecuted,
      bool isOverride,
      bytes memory data
    )
  {
    Transaction storage txn = _transactions[txId];
    return
      (txn.initiator, txn.to, txn.token, txn.value, txn.approvals.current(), txn.isExecuted, txn.isOverride, txn.data);
  }

  /**
   * @notice Returns the total number of approvals a transaction has.
   * @param txId The ID of the requested transaction.
   * @return uint256 The transaction total number of approvers.
   */
  function getTransactionApprovals(
    uint256 txId
  ) public view validTransaction(txId) onlyUser returns (uint256) {
    return _transactions[txId].approvals.current();
  }

  /**
   * @notice Returns the signatures associated with a transaction.
   * @param txId The ID of the requested transaction.
   * @return address[] The transaction signatures array.
   */
  function getTransactionSignatures(
    uint256 txId
  ) public view validTransaction(txId) onlyUser returns (address[] memory) {
    Transaction storage txn = _transactions[txId];
    return txn.signatures.values();
  }
}
