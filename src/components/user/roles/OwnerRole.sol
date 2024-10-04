// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.27;

import {AccessControl} from '@openzeppelin/contracts/access/AccessControl.sol';
import {IOwnerRole} from '../../../interfaces/user/roles/IOwnerRole.sol';
import {AddressUtils} from '../../../libraries/AddressUtils.sol';
import {OWNER_ROLE} from '../../../utilities/VaultConstants.sol';

/**
 * @title Owner Role Contract
 * @author Emmanuel Joseph (JET)
 * @dev Abstract contract providing the logic for the Owner role in the MultiSigVault system.
 */
abstract contract OwnerRole is AccessControl, IOwnerRole {
  /// @dev Stores the address of the current owner.
  address private _owner;

  /// @dev Stores the timelock for owner override functionality.
  uint256 public ownerOverrideTimelock;

  /**
   * @dev Initializes the Owner role and sets the initial owner override timelock.
   * @param owner_ The address of the initial owner.
   * @param initialOwnerOverrideTimelock The initial timelock value for owner override.
   */
  constructor(address owner_, uint256 initialOwnerOverrideTimelock) {
    AddressUtils.requireValidUserAddress(owner_);
    if (initialOwnerOverrideTimelock <= 0) {
      revert InvalidOwnerOverrideTimelockValue(initialOwnerOverrideTimelock);
    }

    // Grant DEFAULT_ADMIN_ROLE to the owner
    _grantRole(DEFAULT_ADMIN_ROLE, owner_);

    // Now change the admin role of DEFAULT_ADMIN_ROLE to OWNER_ROLE
    _setRoleAdmin(DEFAULT_ADMIN_ROLE, OWNER_ROLE);

    // Grant OWNER_ROLE to the owner
    _grantRole(OWNER_ROLE, owner_);

    ownerOverrideTimelock = initialOwnerOverrideTimelock;
    _owner = owner_;
  }

  /**
   * @dev Modifier to restrict access to functions to only the owner.
   * Reverts with `AccessControlUnauthorizedOwner` if the caller is not the owner.
   */
  modifier onlyOwner() {
    if (!_isOwner(_msgSender())) {
      revert AccessControlUnauthorizedOwner(_msgSender());
    }
    _;
  }

  /**
   * @notice Returns the address of the current owner.
   * @return The address of the owner.
   */
  function owner() public view returns (address) {
    return _owner;
  }

  /**
   * @notice Increases the owner override timelock to a new limit.
   * Emits the `OwnerOverrideTimelockIncreased` event.
   *
   * @param newOwnerTimelock The new timelock value for the owner override.
   * @dev
   * - `newOwnerTimelock` must be higher than the current value.
   */
  function increaseOwnerOverrideTimelock(
    uint256 newOwnerTimelock
  ) public onlyRole(OWNER_ROLE) {
    if (newOwnerTimelock <= ownerOverrideTimelock) revert InvalidOwnerOverrideTimelockValue(newOwnerTimelock);

    ownerOverrideTimelock = newOwnerTimelock;
    emit OwnerOverrideTimelockIncreased(newOwnerTimelock);
  }

  /**
   * @notice Decreases the owner override timelock to a new limit.
   * Emits the `OwnerOverrideTimelockDecreased` event.
   *
   * @param newOwnerTimelock The new timelock value for the owner override.
   * @dev
   * - `newOwnerTimelock` must be lower than the current value.
   */
  function decreaseOwnerOverrideTimelock(
    uint256 newOwnerTimelock
  ) public onlyRole(OWNER_ROLE) {
    if (newOwnerTimelock >= ownerOverrideTimelock) revert InvalidOwnerOverrideTimelockValue(newOwnerTimelock);

    ownerOverrideTimelock = newOwnerTimelock;
    emit OwnerOverrideTimelockDecreased(newOwnerTimelock);
  }

  /**
   * @notice Checks if an address is the contract owner.
   * @param account The address to check.
   * @return status True if the address is the contract owner, otherwise false.
   */
  function _isOwner(
    address account
  ) internal view returns (bool status) {
    status = account == _owner && hasRole(OWNER_ROLE, account);
  }

  /**
   * @notice Internal function to change the owner address.
   */
  function _changeOwner() internal onlyRole(OWNER_ROLE) {
    address newOwner = _msgSender();
    address oldOwner = _owner;
    if (newOwner == oldOwner) {
      revert AccessControlUnauthorizedOwner(newOwner);
    }

    _owner = newOwner;
    emit OwnerChanged(oldOwner, newOwner);
  }
}
