// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.27;

import {AccessControl} from '@openzeppelin/contracts/access/AccessControl.sol';
import {SIGNER_ROLE, OWNER_ROLE} from '../../utilities/VaultConstants.sol';
import {ISignerRole} from '../../interfaces/roles/ISignerRole.sol';
import {AddressUtils} from '../../libraries/AddressUtils.sol';
import {ArraysUtils} from '../../libraries/ArraysUtils.sol';
import '../../libraries/Counters.sol';

/**
 * @title Signer Role Contract
 * @author Emmanuel Joseph (JET)
 * @dev Abstract contract providing the logic for the Signer role in the MultiSigVault system.
 */
abstract contract SignerRole is AccessControl, ISignerRole {
  using Counters for Counters.Counter;
  using AddressUtils for address;

  /// @notice Using Counter library for total signers
  Counters.Counter private _signerCount;

  /// @dev Stores store all signer addresses.
  address[] private _signers;

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
   * @notice Checks if an address is a signer.
   * @param signer The address to check.
   * @return status True if the address is a signer, otherwise false.
   */
  function isSigner(
    address signer
  ) public view returns (bool status) {
    status = hasRole(SIGNER_ROLE, signer);
  }

  /**
   * @notice Returns the total number of signers.
   * @return uint256 The number of signers in the system.
   */
  function totalSigners() public view returns (uint256) {
    return _signerCount.current();
  }

  /**
   * @notice Returns an array of all current signers' addresses.
   * @return address[] The list of signers' addresses.
   */
  function getSigners() public view returns (address[] memory) {
    return _signers;
  }

  /**
   * @notice Adds a new signer.
   * @param newSigner The address of the new signer.
   * @dev Only callable by the owner.
   */
  function _addSigner(
    address newSigner
  ) internal onlyRole(OWNER_ROLE) {
    require(!isSigner(newSigner), 'SignerRole: Signer already exists');
    newSigner.requireValidUserAddress();

    grantRole(SIGNER_ROLE, newSigner);
    _signers.push(newSigner);
    _signerCount.increment();
    emit SignerAdded(newSigner);
  }

  /**
   * @notice Removes the current signer.
   * @param signer The address of the signer to be removed.
   * @dev Only callable by the owner.
   */
  function _removeSigner(
    address signer
  ) internal onlyRole(OWNER_ROLE) {
    require(isSigner(signer), 'SignerRole: Signer does not exist');

    /// Remove Signer ROle
    revokeRole(SIGNER_ROLE, signer);

    // Remove signer from the _signers array
    uint256 signerIndex = ArraysUtils.arrayElementIndexLookup(signer, _signers);
    ArraysUtils.removeElementFromArray(signerIndex, _signers);
    _signerCount.decrement();
    
    emit SignerRemoved(signer);
  }
}
