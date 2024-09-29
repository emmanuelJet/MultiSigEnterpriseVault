// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.27;

import {AccessControl} from '@openzeppelin/contracts/access/AccessControl.sol';
import {IOwnerRole} from '../../interfaces/roles/IOwnerRole.sol';
import {OWNER_ROLE} from '../../utilities/VaultConstants.sol';

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
   * @param _ownerAddress The address of the initial owner.
   * @param _initialOwnerOverrideLimit The initial timelock value for owner override.
   */
  constructor(address _ownerAddress, uint256 _initialOwnerOverrideLimit) {
    if (_initialOwnerOverrideLimit <= 0) {
      revert InvalidOwnerOverrideLimitValue(_initialOwnerOverrideLimit);
    }

    // Grant DEFAULT_ADMIN_ROLE to the owner
    _grantRole(DEFAULT_ADMIN_ROLE, _ownerAddress);

    // Now change the admin role of DEFAULT_ADMIN_ROLE to OWNER_ROLE
    _setRoleAdmin(DEFAULT_ADMIN_ROLE, OWNER_ROLE);

    // Grant OWNER_ROLE to the owner
    _grantRole(OWNER_ROLE, _ownerAddress);

    ownerOverrideTimelock = _initialOwnerOverrideLimit;
    _owner = _ownerAddress;
  }

  /**
   * @dev Modifier to restrict access to functions to only the owner.
   * Reverts with `AccessControlUnauthorizedOwner` if the caller is not the owner.
   */
  modifier onlyOwner() {
    if (!hasRole(OWNER_ROLE, _msgSender())) {
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
   * @param newLimit The new timelock value for the owner override.
   * @dev
   * - `newLimit` must be higher than the current value.
   */
  function increaseOwnerOverrideTimelockLimit(
    uint256 newLimit
  ) public onlyRole(OWNER_ROLE) {
    require(newLimit > ownerOverrideTimelock, 'OwnerRole: New limit must be higher');
    ownerOverrideTimelock = newLimit;
    emit OwnerOverrideTimelockIncreased(newLimit);
  }

  /**
   * @notice Decreases the owner override timelock to a new limit.
   * Emits the `OwnerOverrideTimelockDecreased` event.
   *
   * @param newLimit The new timelock value for the owner override.
   * @dev
   * - `newLimit` must be lower than the current value.
   */
  function decreaseOwnerOverrideTimelockLimit(
    uint256 newLimit
  ) public onlyRole(OWNER_ROLE) {
    require(newLimit < ownerOverrideTimelock, 'OwnerRole: New limit must be lower');
    ownerOverrideTimelock = newLimit;
    emit OwnerOverrideTimelockDecreased(newLimit);
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
