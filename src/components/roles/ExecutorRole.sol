// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.27;

import {AccessControl} from '@openzeppelin/contracts/access/AccessControl.sol';
import {EXECUTOR_ROLE, OWNER_ROLE} from '../../utilities/VaultConstants.sol';
import {IExecutorRole} from '../../interfaces/roles/IExecutorRole.sol';
import {AddressUtils} from '../../libraries/AddressUtils.sol';

/**
 * @title Executor Role Contract
 * @author Emmanuel Joseph (JET)
 * @dev Abstract contract providing the logic for the Executor role in the MultiSigVault system.
 */
abstract contract ExecutorRole is AccessControl, IExecutorRole {
  using AddressUtils for address;

  /// @dev Stores the address of the current executor.
  address private _executor;

  /**
   * @dev Modifier to restrict access to functions to only the executor.
   * Reverts with `AccessControlUnauthorizedExecutor` if the caller is not the executor.
   */
  modifier onlyExecutor() {
    if (!hasRole(EXECUTOR_ROLE, _msgSender())) {
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
   * @notice Adds a new executor.
   * @param newExecutor The address of the new executor.
   * @dev Only callable by the owner.
   */
  function _addExecutor(
    address newExecutor
  ) internal onlyRole(OWNER_ROLE) {
    require(_executor == address(0), 'ExecutorRole: Executor already exists');
    if (newExecutor.isValidUserAddress()) {
      grantRole(EXECUTOR_ROLE, newExecutor);
      _executor = newExecutor;
      emit ExecutorAdded(newExecutor);
    }
  }

  /**
   * @notice Removes the current executor.
   * @dev Only callable by the owner.
   */
  function _removeExecutor() internal onlyRole(OWNER_ROLE) {
    address oldExecutor = _executor;
    if (oldExecutor.isValidUserAddress()) {
      revokeRole(EXECUTOR_ROLE, oldExecutor);
      _executor = address(0);
      emit ExecutorRemoved(oldExecutor);
    }
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
    if (oldExecutor.isValidUserAddress() && newExecutor.isValidUserAddress()) {
      // Revoke old executor role and assign to the new executor
      revokeRole(EXECUTOR_ROLE, oldExecutor);
      grantRole(EXECUTOR_ROLE, newExecutor);

      // Update the executor address
      _executor = newExecutor;

      emit ExecutorUpdated(oldExecutor, newExecutor);
    }
  }
}
