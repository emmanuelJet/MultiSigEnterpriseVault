// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.27;

import '../libraries/Counters.sol';
import {IUser} from '../interfaces/IUser.sol';
import {OwnerRole} from './roles/OwnerRole.sol';
import {SignerRole} from './roles/SignerRole.sol';
import {RoleType} from '../utilities/VaultEnums.sol';
import {ExecutorRole} from './roles/ExecutorRole.sol';
import {UserProfile} from '../utilities/VaultStructs.sol';
import {AddressUtils} from '../libraries/AddressUtils.sol';

/**
 * @title User Contract
 * @author Emmanuel Joseph (JET)
 * @dev Manages user profiles and integrates with the Owner role for user administration within the MultiSigVault system.
 */
abstract contract User is OwnerRole, ExecutorRole, SignerRole, IUser {
  using Counters for Counters.Counter;
  using AddressUtils for address;

  /// @notice Using Counter library for total users
  Counters.Counter private _userCount;

  /// @notice Mapping to store UserProfile by their address
  mapping(address => UserProfile) private _users;

  /**
   * @dev Constructor to initialize the User and Owner role contracts.
   * @param ownerAddress The address of the owner to be assigned the OWNER_ROLE.
   * @param initialOwnerOverrideLimit The initial timelock limit for owner override.
   */
  constructor(
    address ownerAddress,
    uint256 initialOwnerOverrideLimit
  ) OwnerRole(ownerAddress, initialOwnerOverrideLimit) {
    _addUser(ownerAddress, RoleType.OWNER);
  }

  /**
   * @dev Modifier to restrict access to functions to only vault users.
   * Reverts with `AccessControlUnauthorizedSigner` if the caller is not the signer.
   */
  modifier onlyUser() {
    if (!_isUser(_msgSender())) {
      revert InvalidUserProfile(_msgSender());
    }
    _;
  }

  /**
   * @notice Returns the total number of users.
   * @return uint256 The total number of users.
   * @dev Only callable by the owner.
   */
  function totalUsers() public view onlyOwner returns (uint256) {
    return _userCount.current();
  }

  /**
   * @notice Returns the user profile object of a given address.
   *
   * @param user The address of the user whose profile is requested.
   * @return UserProfile The user profile object associated with the provided address.
   * @dev Requirements:
   * - Limited to the owner account.
   * - `user` cannot be the zero address.
   */
  function getUserProfile(
    address user
  ) public view onlyOwner returns (UserProfile memory) {
    if (!_isUser(user)) {
      revert InvalidUserProfile(user);
    }
    return _users[user];
  }

  /**
   * @notice Adds a new executor.
   * @param newExecutor The address of the new executor.
   * @dev Only callable by the owner.
   */
  function addExecutor(
    address newExecutor
  ) public onlyOwner {
    _addExecutor(newExecutor);
    _addUser(newExecutor, RoleType.EXECUTOR);
  }

  /**
   * @notice Updates the executor by replacing the old executor with a new one.
   * @param newExecutor The address of the new executor.
   * @dev Only callable by the owner.
   */
  function updateExecutor(
    address newExecutor
  ) public onlyOwner {
    address oldExecutor = executor();
    if (oldExecutor.isValidUserAddress() && newExecutor.isValidUserAddress()) {
      _updateExecutor(newExecutor);
      _removeUser(oldExecutor);
      _addUser(newExecutor, RoleType.EXECUTOR);
    }
  }

  /**
   * @notice Removes the current executor.
   * @dev Only callable by the owner.
   *
   * NOTE: Removing executor will leave the contract without an executor,
   * thereby disabling any functionality that is only available to the executor.
   */
  function removeExecutor() public onlyOwner {
    address oldExecutor = executor();
    if (oldExecutor.isValidUserAddress()) {
      _removeExecutor();
      _removeUser(oldExecutor);
    }
  }

  /**
   * @notice Adds a new signer user.
   * @param newSigner The address of the new signer.
   * @dev Only callable by the owner.
   */
  function addSigner(
    address newSigner
  ) public onlyOwner {
    _addSigner(newSigner);
    _addUser(newSigner, RoleType.SIGNER);
  }

  /**
   * @notice Removes an existing signer and deletes the user's profile.
   * @param signer The address of the signer to be removed.
   * @dev Only callable by the owner.
   */
  function removeSigner(
    address signer
  ) public onlyOwner {
    if (signer.isValidUserAddress()) {
      _removeSigner(signer);
      _removeUser(signer);
    }
  }

  /**
   * @notice Checks if an address is a user.
   * @param user The address to check.
   * @return status True if the address is a user, otherwise false.
   */
  function _isUser(
    address user
  ) internal view returns (bool status) {
    status = _users[user].user != address(0);
  }

  /**
   * @dev Adds a user profile and assigns a role.
   *
   * @param user The address of the user.
   * @param role The role type assigned to the user.
   * @dev This is a private function to store user details.
   */
  function _addUser(address user, RoleType role) private {
    _users[user] = UserProfile(user, role, block.timestamp);
    _userCount.increment();
  }

  /**
   * @notice Removes a user's profile.
   * @param user The address of the user to be removed.
   */
  function _removeUser(
    address user
  ) private {
    UserProfile storage profile = _users[user];
    if (profile.user.isValidUserAddress()) {
      delete _users[user];
      _userCount.decrement();
    }
  }
}
