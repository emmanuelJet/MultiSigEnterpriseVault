// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

/**
 * @title IMultiSigTransaction Interface
 * @dev Interface defining custom errors, events, and external functions for transaction management.
 */
interface IMultiSigTransaction {
  /**
   * @dev Error thrown when the provided transaction ID is not valid.
   * @param transactionId The ID of the invalid transaction.
   */
  error InvalidTransaction(uint256 transactionId);

  /**
   * @dev Error indicating the state of a pending transaction.
   * @param isPending Boolean value representing whether the latest transaction is pending.
   */
  error PendingTransactionState(bool isPending);

  /**
   * @dev Error thrown when there are insufficient tokens to complete a transaction.
   * @param availableBalance The available vault token balance.
   * @param requestedValue The requested transaction value.
   */
  error InsufficientTokenBalance(uint256 availableBalance, uint256 requestedValue);

  /**
   * @dev Indicates a failure with the `spender`’s `allowance`. Used in transfers.
   * @param owner The address whose tokens are being transferred.
   * @param allowance Amount of tokens a `spender` is allowed to operate with.
   * @param needed The remaining allowance needed to complete the transfer.
   */
  error ERC20InsufficientAllowance(address owner, uint256 allowance, uint256 needed);

  /**
   * @dev Error thrown when a transaction has already been executed.
   * @param transactionId The ID of the transaction that was already executed.
   */
  error TransactionAlreadyExecuted(uint256 transactionId);

  /**
   * @dev Error thrown when the required number of approvals has not been met.
   * @param transactionId The ID of the not approved transaction.
   */
  error TransactionNotApproved(uint256 transactionId);

  /**
   * @dev Error thrown when there are insufficient approvals to execute a transaction.
   * @param approvalsRequired The required number of approvals.
   * @param currentApprovals The current number of approvals.
   */
  error InsufficientApprovals(uint256 approvalsRequired, uint256 currentApprovals);

  /**
   * @dev Event emitted when tokens (ETH or ERC20) are received.
   * @param from The address that sent the token
   * @param token The token contract address (0x0 for ETH).
   * @param amount The received token amount.
   */
  event FundsReceived(address indexed from, address token, uint256 amount);

  /**
   * @dev Event emitted when a transaction is initiated.
   * @param transactionId The ID of the initiated transaction.
   * @param initiator The address of the initiator.
   * @param to The address to receive the value.
   * @param token The token contract address (0x0 for ETH).
   * @param value The value to be transferred.
   */
  event TransactionInitiated(
    uint256 indexed transactionId, address indexed initiator, address indexed to, address token, uint256 value
  );

  /**
   * @dev Event emitted when a transaction is approved.
   * @param transactionId The ID of the approved transaction.
   * @param approver The address of the account who approved the transaction.
   * @param timestamp The timestamp (in seconds) when the transaction was approved.
   */
  event TransactionApproved(uint256 indexed transactionId, address indexed approver, uint256 timestamp);

  /**
   * @dev Event emitted when a transaction approval is revoked.
   * @param transactionId The ID of the transaction.
   * @param revoker The address of the account who revoked approval.
   * @param timestamp The timestamp (in seconds) when the transaction was revoked.
   */
  event TransactionRevoked(uint256 indexed transactionId, address indexed revoker, uint256 timestamp);

  /**
   * @dev Event emitted when a transaction is executed.
   * @param transactionId The ID of the executed transaction.
   * @param executor The address of the account who executed the transaction.
   * @param timestamp The timestamp (in seconds) when the transaction was executed.
   */
  event TransactionExecuted(uint256 indexed transactionId, address indexed executor, uint256 timestamp);

  /**
   * @notice Receives ERC20 tokens and emits `FundsReceived` event
   * @param token The ERC20 token address.
   * @param amount The amount of ERC20 tokens sent.
   */
  function depositToken(address token, uint256 amount) external payable;

  /**
   * @dev Returns the vault's total transactions.
   * @return The total transaction value.
   */
  function totalTransactions() external view returns (uint256);
}
