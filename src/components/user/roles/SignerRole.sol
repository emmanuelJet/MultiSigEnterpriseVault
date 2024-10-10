// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

import {EnumerableSet} from '@openzeppelin/contracts/utils/structs/EnumerableSet.sol';
import {AccessControl} from '@openzeppelin/contracts/access/AccessControl.sol';
import {ISignerRole} from '../../../interfaces/user/roles/ISignerRole.sol';
import {AddressUtils} from '../../../libraries/AddressUtils.sol';
import '../../../utilities/VaultConstants.sol';
import '../../../libraries/Counters.sol';

/**
 * @title Signer Role Contract
 * @author Emmanuel Joseph (JET)
 * @dev Abstract contract providing the logic for the Signer role in the MultiSigVault system.
 */
abstract contract SignerRole is AccessControl, ISignerRole {
  using EnumerableSet for EnumerableSet.AddressSet;
  using Counters for Counters.Counter;
  using AddressUtils for address;

  /// @notice Using Counter library for total signers
  Counters.Counter private _signerCount;

  /// @dev Using EnumerableSet library for signer addresses.
  EnumerableSet.AddressSet private _signers;

  /**
   * @dev Modifier to restrict access to functions to only the signer.
   * Reverts with `AccessControlUnauthorizedSigner` if the caller is not a signer.
   */
  modifier onlySigner() {
    if (!isSigner(_msgSender())) {
      revert AccessControlUnauthorizedSigner(_msgSender());
    }
    _;
  }

  /**
   * @dev Modifier to restrict access to functions to valid executors.
   * Reverts with `UnauthorizedMultiSigExecutor` if the caller is not an authorized multi-sig executor.
   */
  modifier validExecutor() {
    if (!hasRole(EXECUTOR_ROLE, _msgSender()) && !hasRole(OWNER_ROLE, _msgSender())) {
      revert UnauthorizedMultiSigExecutor(_msgSender());
    }
    _;
  }

  /**
   * @notice Checks if an address is a signer.
   * @param signer The address to check.
   * @return status True if the address is a signer, otherwise false.
   */
  function isSigner(
    address signer
  ) public view returns (bool status) {
    status = _signers.contains(signer) && hasRole(SIGNER_ROLE, signer);
  }

  /**
   * @notice Returns the total number of signers.
   * @return uint256 The number of signers in the contract.
   */
  function totalSigners() public view returns (uint256) {
    return _signerCount.current();
  }

  /**
   * @notice Returns an array of all current signers' addresses.
   * @return address[] The list of signers' addresses.
   */
  function getSigners() public view returns (address[] memory) {
    return _signers.values();
  }

  /**
   * @notice Adds a new signer.
   * @param newSigner The address of the new signer.
   * @dev Only callable by a valid executor.
   */
  function _addSigner(
    address newSigner
  ) internal virtual validExecutor {
    _validateSignerAddress(newSigner);
    if (isSigner(newSigner)) revert SignerAlreadyExists(newSigner);
    if (!_signers.add(newSigner)) revert SignerAlreadyExists(newSigner);

    _grantRole(SIGNER_ROLE, newSigner);
    _signerCount.increment();
    emit SignerAdded(newSigner);
  }

  /**
   * @notice Removes the current signer.
   * @param signer The address of the signer to be removed.
   * @dev Only callable by a valid executor.
   */
  function _removeSigner(
    address signer
  ) internal virtual validExecutor {
    if (!isSigner(signer)) revert SignerDoesNotExist(signer);
    if (!_signers.remove(signer)) revert SignerDoesNotExist(signer);

    _revokeRole(SIGNER_ROLE, signer);
    _signerCount.decrement();
    emit SignerRemoved(signer);
  }

  /**
   * @dev Validates the provided signer address.
   *
   * This function checks if the given signer address is a valid user address
   * and ensures that the address does not have the OWNER_ROLE or SIGNER_ROLE.
   * If the address has either of these roles, the function reverts with an
   * `InvalidSignerUser` error.
   *
   * @param signer The address of the signer to validate.
   */
  function _validateSignerAddress(
    address signer
  ) private view {
    signer.requireValidUserAddress();
    if (hasRole(OWNER_ROLE, signer) || hasRole(EXECUTOR_ROLE, signer)) {
      revert InvalidSignerUser(signer);
    }
  }
}
