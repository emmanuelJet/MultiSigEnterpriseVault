// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

import {ActionType} from '../utilities/VaultEnums.sol';

/**
 * @title IMultiSigTimelock Interface
 * @author Emmanuel Joseph (JET)
 * @dev Interface defining errors and events for timelock management.
 */
interface IMultiSigTimelock {
  /**
   * @dev Error thrown when the provided action ID is not valid.
   * @param actionId The ID of the invalid action.
   */
  error InvalidAction(uint256 actionId);

  /**
   * @dev Error thrown when the provided action type is not valid.
   * @param action The type of the invalid action.
   */
  error InvalidActionType(ActionType action);

  /**
   * @dev Error indicating the state of a pending action.
   * @param isPending Boolean value representing whether the latest action is pending.
   */
  error PendingActionState(bool isPending);

  /**
   * @dev Error thrown when a action has already been executed.
   * @param actionId The ID of the action that was already executed.
   */
  error ActionAlreadyExecuted(uint256 actionId);

  /**
   * @dev Error thrown when the required number of approvals has not been met.
   * @param actionId The ID of the not approved action.
   */
  error ActionNotApproved(uint256 actionId);

  /**
   * @dev Error thrown when a timelock period has not yet elapsed.
   * @param requiredTimestamp The timestamp at which the timelock will be met.
   * @param currentTimestamp The current timestamp.
   */
  error TimelockNotElapsed(uint256 requiredTimestamp, uint256 currentTimestamp);

  /**
   * @dev Error thrown when the total number of signers is below the required signatory threshold.
   * @param requiredThreshold The required number of signers.
   * @param currentSigners The current number of signers.
   */
  error InsufficientSigners(uint256 requiredThreshold, uint256 currentSigners);

  /**
   * @dev Error thrown when an invalid signatory threshold value is given.
   * @param signatoryThreshold The invalid signatory threshold value.
   */
  error InvalidSignatoryThreshold(uint256 signatoryThreshold);

  /**
   * @dev Error thrown when an invalid timelock value is used during initialization.
   * @param timelockValue The invalid timelock value.
   */
  error InvalidMultiSigTimelockValue(uint256 timelockValue);

  /**
   * @dev Error thrown when trying to increase the timelock to an invalid value.
   * @param newLimit The invalid increase timelock.
   */
  error InvalidMultiSigTimelockIncrease(uint256 newLimit);

  /**
   * @dev Error thrown when trying to decrease the timelock to an invalid value.
   *  @param newLimit The invalid decrease timelock.
   */
  error InvalidMultiSigTimelockDecrease(uint256 newLimit);

  /**
   * @dev Error thrown when trying to increase the signatory threshold to an invalid value.
   * @param newThreshold The invalid increase signatory threshold.
   */
  error InvalidSignatoryThresholdIncrease(uint256 newThreshold);

  /**
   * @dev Error thrown when trying to decrease the signatory threshold to an invalid value.
   *  @param newThreshold The invalid decrease signatory threshold.
   */
  error InvalidSignatoryThresholdDecrease(uint256 newThreshold);

  /**
   * @dev Error thrown when an signers approval is required to perform an action.
   */
  error SignersApprovalRequired();

  /**
   * @dev Error thrown when insufficient signer approvals have been met.
   * @param requiredApprovals The number of approvals required.
   * @param currentApprovals The current number of approvals.
   */
  error InsufficientSignerApprovals(uint256 requiredApprovals, uint256 currentApprovals);

  /**
   * @dev Event emitted when a new action is initiated.
   * @param actionId The unique ID of the initiated action.
   * @param initiator The address of the action initiator.
   * @param actionType The type of action being initiated.
   */
  event ActionInitiated(uint256 indexed actionId, address indexed initiator, ActionType actionType);

  /**
   * @dev Event emitted when an action is approved.
   * @param actionId The ID of the approved action.
   * @param approver The address of the account who approved the action.
   * @param timestamp The timestamp (in seconds) when the action was approved.
   */
  event ActionApproved(uint256 indexed actionId, address indexed approver, uint256 timestamp);

  /**
   * @dev Event emitted when an action approval is revoked.
   * @param actionId The ID of the action.
   * @param revoker The address of the account who revoked approval.
   * @param timestamp The timestamp (in seconds) when the action was revoked.
   */
  event ActionRevoked(uint256 indexed actionId, address indexed revoker, uint256 timestamp);

  /**
   * @dev Event emitted when an action is executed.
   * @param actionId The ID of the executed action.
   * @param actionType The type of action executed.
   * @param executor The address of the account who executed the action.
   * @param timestamp The timestamp (in seconds) when the action was executed.
   */
  event ActionExecuted(
    uint256 indexed actionId, ActionType indexed actionType, address indexed executor, uint256 timestamp
  );

  /**
   * @dev Event emitted when the signatory threshold is updated.
   * @param oldThreshold The old threshold value for signatory approval.
   * @param newThreshold The new threshold value for signatory approval.
   */
  event ThresholdUpdated(uint256 indexed oldThreshold, uint256 indexed newThreshold);

  /**
   * @dev Event emitted when the action timelock is updated.
   * @param oldLimit The old action timelock value.
   * @param newLimit The new action timelock value.
   */
  event MultiSigTimelockUpdated(uint256 oldLimit, uint256 newLimit);

  /**
   * @dev Returns the current timelock for the vault.
   * @return The current timelock.
   */
  function multiSigTimelock() external view returns (uint256);

  /**
   * @dev Returns the current signatory threshold for the vault.
   * @return The current signatory threshold.
   */
  function signatoryThreshold() external view returns (uint256);
}
