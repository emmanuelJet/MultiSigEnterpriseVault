// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.27;

import '../libraries/Counters.sol';
import '../libraries/AddressUtils.sol';
import '../utilities/VaultConstants.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import {IMultiSigTransaction} from '../interfaces/IMultiSigTransaction.sol';
import {Transaction} from '../utilities/VaultStructs.sol';
import {ArraysUtils} from '../libraries/ArraysUtils.sol';
import {User} from './user/User.sol';

/**
 * @title MultiSigTransaction
 * @dev Manages transaction initiation, approval, and execution for ETH and ERC20 transfers.
 */
abstract contract MultiSigTransaction is User, IMultiSigTransaction {
  using Counters for Counters.Counter;

  /// @notice The minimum number of approvals to execute a transaction
  uint256 public signatoryThreshold;

  /// @notice Using Counter library for total transactions
  Counters.Counter private _transactionCount;

  /// @notice Mapping to store all transactions by their ID
  mapping(uint256 => Transaction) private _transactions;

  /// @notice Mapping to track approvals for each transaction by signers
  mapping(uint256 => mapping(address => bool)) public approvals;

  /**
   * @dev Initializes the `MultiSigTransaction` and `User` contracts.
   * @param owner The address of the contract owner.
   * @param initialThreshold The initial threshold for signatory approval.
   * @param initialOwnerOverrideLimit The initial timelock limit for owner override.
   */
  constructor(
    address owner,
    uint256 initialThreshold,
    uint256 initialOwnerOverrideLimit
  ) User(owner, initialOwnerOverrideLimit) {
    signatoryThreshold = initialThreshold;
  }

  /**
   * @dev Modifier to ensure a valid vault transaction.
   * Reverts with `InvalidTransaction` if the given transaction ID is invalid.
   * @param transactionId The ID of the transaction to validate.
   */
  modifier validTransaction(
    uint256 transactionId
  ) {
    if (transactionId == 0 || transactionId < _transactionCount.current()) {
      revert InvalidTransaction(transactionId);
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
  function depositToken(address token, uint256 amount) external payable {
    AddressUtils.requireValidTokenAddress(token);
    require(amount >= msg.value, 'MultiSigTransaction: Invalid deposit amount');

    IERC20(token).transferFrom(_msgSender(), address(this), msg.value);
    emit FundsReceived(_msgSender(), token, msg.value);
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
    AddressUtils.requireValidTokenAddress(token);
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
   * @notice Returns the transaction details of a given ID.
   * @param transactionId The ID of the requested transaction.
   * @return Transaction The transaction object associated with the provided ID.
   */
  function getTransaction(
    uint256 transactionId
  ) public view validTransaction(transactionId) onlyUser returns (Transaction memory) {
    return _transactions[transactionId];
  }

  /**
   * @notice Returns the total number of approvals a transaction has.
   * @param transactionId The ID of the requested transaction.
   * @return uint256 The transaction total number of approvers.
   */
  function getTransactionApprovals(
    uint256 transactionId
  ) public view validTransaction(transactionId) onlyUser returns (uint256) {
    return _transactions[transactionId].approvals.current();
  }

  /**
   * @notice Returns the signatures associated with a transaction.
   * @param transactionId The ID of the requested transaction.
   * @return address[] The transaction signatures array.
   */
  function getTransactionSignatures(
    uint256 transactionId
  ) public view validTransaction(transactionId) onlyUser returns (address[] memory) {
    return _transactions[transactionId].signatures;
  }

  /**
   * @notice Initiates a new transaction by an Owner or Signer.
   * @param target The target address for the transaction.
   * @param value The amount of ETH or tokens to send.
   * @param token The ERC20 token address (0x0 for ETH).
   * @param data The transaction data (0x0 for empty data).
   */
  function initiateTransaction(
    address payable target,
    address token,
    uint256 value,
    bytes memory data
  ) public validSigner {
    AddressUtils.requireValidTransactionTarget(target);
    if (token == address(0)) {
      if (value > getBalance()) revert InsufficientTokenBalance(getBalance(), value);
    } else {
      if (value > getTokenBalance(token)) revert InsufficientTokenBalance(getTokenBalance(token), value);
    }

    _transactionCount.increment();
    uint256 transactionId = _transactionCount.current();
    Transaction storage txn = _transactions[transactionId];

    txn.initiator = _msgSender();
    txn.target = target;
    txn.token = token;
    txn.value = value;
    txn.data = data;

    emit TransactionInitiated(transactionId, _msgSender(), target, token, value);
  }

  /**
   * @notice Enables valid signers to approve a transaction.
   * @param transactionId The ID of the transaction to approve.
   */
  function approveTransaction(
    uint256 transactionId
  ) public validTransaction(transactionId) validSigner {
    Transaction storage txn = _transactions[transactionId];
    if (txn.isExecuted) revert TransactionAlreadyExecuted(transactionId);
    if (approvals[transactionId][_msgSender()]) revert TransactionNotApproved(transactionId);

    txn.approvals.increment();
    txn.signatures.push(_msgSender());
    approvals[transactionId][_msgSender()] = true;
    emit TransactionApproved(transactionId, _msgSender(), block.timestamp);
  }

  /**
   * @notice Enables valid signers to revokes a transaction approval.
   * @param transactionId The ID of the transaction to revoke approval for.
   */
  function revokeApproval(
    uint256 transactionId
  ) public validTransaction(transactionId) validSigner {
    Transaction storage txn = _transactions[transactionId];
    if (txn.isExecuted) revert TransactionAlreadyExecuted(transactionId);
    if (!approvals[transactionId][_msgSender()]) revert TransactionNotApproved(transactionId);

    txn.approvals.decrement();
    approvals[transactionId][_msgSender()] = false;
    uint256 signerSignatureIndex = ArraysUtils.arrayElementIndexLookup(_msgSender(), txn.signatures);
    ArraysUtils.removeElementFromArray(signerSignatureIndex, txn.signatures);

    emit TransactionRevoked(transactionId, _msgSender(), block.timestamp);
  }

  /**
   * @notice Executes a transaction if the threshold is met.
   * @param transactionId The ID of the transaction to execute.
   */
  function executeTransaction(
    uint256 transactionId
  ) public validTransaction(transactionId) validExecutor {
    Transaction storage txn = _transactions[transactionId];
    if (txn.isExecuted) revert TransactionAlreadyExecuted(transactionId);
    if (txn.approvals.current() < signatoryThreshold) {
      revert InsufficientApprovals(signatoryThreshold, txn.approvals.current());
    }
    if (hasRole(OWNER_ROLE, _msgSender())) {
      if (!approvals[transactionId][_msgSender()]) revert TransactionNotApproved(transactionId);
    }

    txn.isExecuted = true;
    if (txn.token == address(0)) {
      // Send ETH
      Address.sendValue(txn.target, txn.value);
    } else {
      // Send ERC20 tokens
      IERC20 token = IERC20(txn.token);
      SafeERC20.safeTransfer(token, txn.target, txn.value);
    }

    emit TransactionExecuted(transactionId, _msgSender(), block.timestamp);
  }
}
