// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

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
   * @dev Error thrown when attempting to add a new executor with an existing user role.
   * @param executor The invalid executor address.
   */
  error InvalidExecutorUser(address executor);

  /**
   * @dev Error thrown when the contract does not have a valid executor.
   */
  error MissingExecutor();

  /**
   * @dev Error thrown when attempting to add a new executor when one exists.
   */
  error ExecutorAlreadyExists();

  /**
   * @dev Error thrown when attempting to initiate an already active owner override.
   */
  error OwnerOverrideAlreadyActive();

  /**
   * @dev Error thrown when attempting to approve a non active owner override.
   */
  error OwnerOverrideNotActive();

  /**
   * @dev Error thrown when trying to approve an owner override before the timelock has passed.
   * @param currentTime The current time when the error is thrown.
   * @param requiredTime The required time that must elapse before the owner override can be executed.
   */
  error OwnerOverrideTimelockNotElapsed(uint256 currentTime, uint256 requiredTime);

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
  event ExecutorUpdated(address indexed oldExecutor, address indexed newExecutor);

  /**
   * @dev Event emitted when the owner override process is initiated by the executor.
   * @param executor The address of the executor.
   * @param timestamp The time when the override was initiated.
   */
  event OwnerOverrideInitiated(address indexed executor, uint256 timestamp);

  /**
   * @dev Event emitted when the owner override process is approved after the timelock.
   * @param executor The address of the executor.
   * @param timestamp The time when the override was approved.
   */
  event OwnerOverrideApproved(address indexed executor, uint256 timestamp);
}
