// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

import {MultiSigTransaction} from './components/MultiSigTransaction.sol';
import {AddressUtils} from './libraries/AddressUtils.sol';

/**
 * @title MultiSig Enterprise Vault Contract
 * @author Emmanuel Joseph (JET)
 * @notice This contract manages a Multi-Signature Vault system, providing role-based access control with customizable
 * signatory threshold and timelocks for actions. The vault supports both ETH and ERC20 tokens for transaction execution.
 */
contract MultiSigEnterpriseVault is MultiSigTransaction {
  /**
   * @dev Initializes the MultiSigEnterpriseVault with the owner, initial signatory threshold, initial timelock, and owner override timelock.
   * @param owner The address of the contract owner.
   * @param initialThreshold The initial threshold for signatory approval.
   * @param initialMultiSigTimelock The initial timelock for signatory approval.
   * @param initialOwnerOverrideTimelock The initial timelock for owner override.
   */
  constructor(
    address owner,
    uint256 initialThreshold,
    uint256 initialMultiSigTimelock,
    uint256 initialOwnerOverrideTimelock
  ) MultiSigTransaction(owner, initialThreshold, initialMultiSigTimelock, initialOwnerOverrideTimelock) {}

  /**
   * @dev Modifier to ensure an owner can perform an action without requiring signatory approval.
   * Reverts with `SignersApprovalRequired` if the total number of signers is equal to or greater than the signatory threshold.
   */
  modifier withoutSignersApproval() {
    if (_totalValidSigners() >= signatoryThreshold) {
      revert SignersApprovalRequired();
    }
    _;
  }

  /**
   * @notice Updates the signatory threshold for the vault.
   * @param newThreshold The new threshold value for signatory approval.
   * @dev
   * - Requires the total valid signers to be less than the signatory threshold.
   * - Emits a `ThresholdUpdated` event upon successful execution.
   * - Only callable by the owner.
   */
  function updateSignatoryThreshold(
    uint256 newThreshold
  ) public onlyOwner withoutSignersApproval {
    _updateSignatoryThreshold(newThreshold);
  }

  /**
   * @notice Adds a new signer to the vault.
   * @param newSigner The address of the new signer.
   * @dev
   * - Requires the new signer to be a valid address.
   * - Requires the total valid signers to be less than the signatory threshold.
   * - Emits a `SignerAdded` event upon successful execution.
   * - Only callable by the owner.
   */
  function addSigner(
    address newSigner
  ) public onlyOwner withoutSignersApproval {
    AddressUtils.requireValidUserAddress(newSigner);
    if (isSigner(newSigner)) revert SignerAlreadyExists(newSigner);
    _addSigner(newSigner);
  }

  /**
   * @notice Removes a signer from the vault.
   * @param signer The address of the signer to be removed.
   * @dev
   * - Requires the signer to be a valid address.
   * - Requires the total valid signers to be less than the signatory threshold.
   * - Emits a `SignerRemoved` event upon successful execution.
   * - Only callable by the owner.
   */
  function removeSigner(
    address signer
  ) public onlyOwner withoutSignersApproval {
    if (!isSigner(signer)) revert SignerDoesNotExist(signer);
    _removeSigner(signer);
  }
}
