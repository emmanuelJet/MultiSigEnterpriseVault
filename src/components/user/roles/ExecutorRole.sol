// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.27;

import {AccessControl} from '@openzeppelin/contracts/access/AccessControl.sol';
import {IExecutorRole} from '../../../interfaces/user/roles/IExecutorRole.sol';
import {AddressUtils} from '../../../libraries/AddressUtils.sol';
import {SafeMath} from '../../../libraries/SafeMath.sol';
import '../../../utilities/VaultConstants.sol';

/**
 * @title Executor Role Contract
 * @author Emmanuel Joseph (JET)
 * @dev Abstract contract providing the logic for the Executor role in the MultiSigVault system.
 */
abstract contract ExecutorRole is AccessControl, IExecutorRole {
  using AddressUtils for address;
  using SafeMath for uint256;

  /// @dev Stores the address of the current executor.
  address private _executor;

  /// @dev Timestamp of when the owner override was initiated.
  uint256 private overrideInitiatedAt;

  /// @dev Status to indicate if an override is active.
  bool public isOverrideActive;

  /**
   * @dev Modifier to restrict access to functions to only the executor.
   * Reverts with `AccessControlUnauthorizedExecutor` if the caller is not the executor.
   */
  modifier onlyExecutor() {
    if (!_isExecutor(_msgSender())) {
      revert AccessControlUnauthorizedExecutor(_msgSender());
    }
    _;
  }

  /**
   * @notice Returns the address of the current executor.
   * @return The address of the executor.
   */
  function executor() public view returns (address) {
    return _executor;
  }

  /**
   * @notice Initiates the owner override process with a timelock.
   * @dev Only callable by the executor. The override process will start and only be executable after the timelock period has passed.
   */
  function initiateOwnerOverride() public onlyRole(EXECUTOR_ROLE) {
    if (isOverrideActive) {
      revert OwnerOverrideAlreadyActive();
    }

    overrideInitiatedAt = block.timestamp;
    isOverrideActive = true;
    emit OwnerOverrideInitiated(_msgSender(), overrideInitiatedAt);
  }

  /**
   * @notice Adds a new executor.
   * @param newExecutor The address of the new executor.
   * @dev Only callable by the owner.
   */
  function _addExecutor(
    address newExecutor
  ) internal onlyRole(OWNER_ROLE) {
    if (_executor != address(0)) {
      revert ExecutorAlreadyExists();
    }

    _validateExecutorAddress(newExecutor);
    _grantRole(EXECUTOR_ROLE, newExecutor);
    _executor = newExecutor;

    emit ExecutorAdded(newExecutor);
  }

  /**
   * @notice Removes the current executor.
   * @dev Only callable by the owner.
   */
  function _removeExecutor() internal onlyRole(OWNER_ROLE) {
    address oldExecutor = _executor;
    oldExecutor.requireValidUserAddress();
    _revokeRole(EXECUTOR_ROLE, oldExecutor);
    _executor = address(0);
    emit ExecutorRemoved(oldExecutor);
  }

  /**
   * @notice Updates the executor by replacing the old executor with a new one.
   * @param newExecutor The address of the new executor.
   * @dev Only callable by the owner.
   */
  function _updateExecutor(
    address newExecutor
  ) internal onlyRole(OWNER_ROLE) {
    address oldExecutor = _executor;
    oldExecutor.requireValidUserAddress();

    _validateExecutorAddress(newExecutor);
    _revokeRole(EXECUTOR_ROLE, oldExecutor);
    _grantRole(EXECUTOR_ROLE, newExecutor);

    _executor = newExecutor;

    emit ExecutorUpdated(oldExecutor, newExecutor);
  }

  /**
   * @notice Internal function to approve the owner override after the timelock has elapsed.
   *
   * @param ownerAddress The address of the current owner.
   * @param executionTimestamp The time at which the owner override is executed.
   * @param ownerOverrideTimelock The duration after which the override can be approved.
   *
   * @dev This is called from the `User` contract to execute the owner override.
   * Requirements
   * - The owner override is active
   * - The override timelock has passed
   */
  function _approveOwnerOverride(
    address ownerAddress,
    uint256 executionTimestamp,
    uint256 ownerOverrideTimelock
  ) internal onlyRole(EXECUTOR_ROLE) {
    if (!isOverrideActive) {
      revert OwnerOverrideNotActive();
    }

    uint256 requiredTime = overrideInitiatedAt.add(ownerOverrideTimelock);
    uint256 elapsedTime = executionTimestamp.subtract(overrideInitiatedAt);
    if (elapsedTime < ownerOverrideTimelock) {
      revert OwnerOverrideTimelockNotElapsed(executionTimestamp, requiredTime);
    }

    address newOwner = _msgSender();
    _revokeRole(OWNER_ROLE, ownerAddress);
    _revokeRole(EXECUTOR_ROLE, newOwner);
    _grantRole(OWNER_ROLE, newOwner);

    isOverrideActive = false;
    _executor = address(0);

    emit OwnerOverrideApproved(newOwner, executionTimestamp);
  }

  /**
   * @notice Checks if an address is the contract executor.
   * @param account The address to check.
   * @return status True if the address is the contract executor, otherwise false.
   */
  function _isExecutor(
    address account
  ) internal view returns (bool status) {
    status = account == _executor && hasRole(EXECUTOR_ROLE, account);
  }

  /**
   * @dev Validates the provided executor address.
   *
   * This function checks if the given executor address is a valid user address
   * and ensures that the address does not have the OWNER_ROLE or SIGNER_ROLE.
   * If the address has either of these roles, the function reverts with an
   * `InvalidExecutorUser` error.
   *
   * @param executor_ The address of the executor to validate.
   */
  function _validateExecutorAddress(
    address executor_
  ) private view {
    executor_.requireValidUserAddress();
    if (hasRole(OWNER_ROLE, executor_) || hasRole(SIGNER_ROLE, executor_)) {
      revert InvalidExecutorUser(executor_);
    }
  }
}
