// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.27;

/**
 * @title IExecutorRole Interface
 * @author Emmanuel Joseph (JET)
 * @dev Interface defining errors and events related to the Executor role in the MultiSigVault system.
 */
interface IExecutorRole {
  /**
   * @dev Error thrown when an unauthorized account attempts to perform an executor action.
   * @param account The address of the unauthorized account.
   */
  error AccessControlUnauthorizedExecutor(address account);

  /**
   * @dev Event emitted when a new executor is added.
   * @param executor The new executor address.
   */
  event ExecutorAdded(address indexed executor);

  /**
   * @dev Event emitted when an executor is removed.
   * @param executor The removed executor address.
   */
  event ExecutorRemoved(address indexed executor);

  /**
   * @dev Event emitted when an executor is updated.
   * @param oldExecutor The old executor address.
   * @param newExecutor The new executor address.
   */
  event ExecutorUpdated(address oldExecutor, address indexed newExecutor);
}
