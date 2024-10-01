// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.27;

import {IMultiSigEnterpriseVault} from './interfaces/IMultiSigEnterpriseVault.sol';
import {MultiSigTransaction} from './components/MultiSigTransaction.sol';
import {AddressUtils} from './libraries/AddressUtils.sol';

/**
 * @title MultiSig Enterprise Vault Contract
 * @author Emmanuel Joseph (JET)
 */
contract MultiSigEnterpriseVault is MultiSigTransaction, IMultiSigEnterpriseVault {
  /**
   * @dev Initializes the MultiSigEnterpriseVault with the owner, initial signatory threshold, and owner override limit.
   * @param owner The address of the contract owner.
   * @param initialThreshold The initial threshold for signatory approval.
   * @param initialOwnerOverrideLimit The initial timelock limit for owner override.
   */
  constructor(
    address owner,
    uint256 initialThreshold,
    uint256 initialOwnerOverrideLimit
  ) MultiSigTransaction(owner, initialThreshold, initialOwnerOverrideLimit) {
    AddressUtils.requireValidUserAddress(owner);
  }

  /**
   * @notice Owner updates the signatory threshold for the vault.
   * @param newThreshold The new threshold value for signatory approval.
   * @dev Only callable by the owner of the contract.
   */
  function ownerUpdateSignatoryThreshold(
    uint256 newThreshold
  ) public onlyOwner {
    if (newThreshold > signatoryThreshold && totalSigners() >= signatoryThreshold) {
      revert SignersApprovalRequired();
    }

    signatoryThreshold = newThreshold;
    emit ThresholdUpdated(newThreshold);
  }
}
