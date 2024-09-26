// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.27;

/**
 * @title IMultiSigEnterpriseVault Interface
 * @author Emmanuel Joseph (JET)
 * @dev Interface defining events and external functions for the MultiSig Enterprise Vault contract.
 */
interface IMultiSigEnterpriseVault {
  /**
   * @dev Error thrown when an signers approval is required to perform an action.
   */
  error SignersApprovalRequired();

  /**
   * @notice Emitted when the signatory threshold is updated.
   * @param newThreshold The new threshold value for signatory approval.
   */
  event ThresholdUpdated(uint256 newThreshold);

  /**
   * @notice Returns the current signatory threshold for the vault.
   * @return The current signatory threshold.
   */
  function signatoryThreshold() external view returns (uint256);
}
