// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.27;

import '../libraries/Counters.sol';
import {User} from './user/User.sol';
import {SafeMath} from '../libraries/SafeMath.sol';
import {Action} from '../utilities/VaultStructs.sol';
import {ActionType} from '../utilities/VaultEnums.sol';
import {IMultiSigTimelock} from '../interfaces/IMultiSigTimelock.sol';
import {EnumerableSet} from '@openzeppelin/contracts/utils/structs/EnumerableSet.sol';

/**
 * @title MultiSigTimelock
 * @author Emmanuel Joseph (JET)
 * @dev Manages the timelock logics in the MultiSigVault system.
 */
abstract contract MultiSigTimelock is User, IMultiSigTimelock {
  using EnumerableSet for EnumerableSet.AddressSet;
  using Counters for Counters.Counter;
  using SafeMath for uint256;

  /// @dev Stores the multi-sig timelock for function execution.
  uint256 public multiSigTimelock;

  /// @notice Stores the minimum number of approvals to execute an action
  uint256 public signatoryThreshold;

  /// @notice Stores the check for a pending action that requires approvals
  bool private _isPendingAction;

  /// @notice Using Counter library for total actions
  Counters.Counter private _actionCount;

  /// @notice Mapping to store all actions by their ID
  mapping(uint256 => Action) private _actions;

  /**
   * @dev Initializes the `MultiSigTimelock` and `User` contracts.
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
  ) User(owner, initialOwnerOverrideTimelock) {
    if (initialMultiSigTimelock <= 0) {
      revert InvalidMultiSigTimelockValue(initialMultiSigTimelock);
    }

    if (initialThreshold <= 0) {
      revert InvalidSignatoryThreshold(initialThreshold);
    }

    signatoryThreshold = initialThreshold;
    multiSigTimelock = initialMultiSigTimelock;
  }

  /**
   * @dev Modifier to check if the total number of signers meets or exceeds the signatory threshold and the contract has an executor.
   * - Reverts with `InsufficientSigners` if the total signers doesn't meet or exceeds the signatory threshold.
   * - Reverts with `MissingExecutor` if no valid executor exists in the multi-sig vault contract.
   */
  modifier isExecutable() {
    if (_totalValidSigners() < signatoryThreshold) {
      revert InsufficientSigners(signatoryThreshold, _totalValidSigners());
    }

    if (executor() == address(0)) {
      revert MissingExecutor();
    }
    _;
  }

  /**
   * @dev Modifier to ensure a valid vault action type.
   * Reverts with `InvalidAction` if the given action ID is invalid.
   * @param actionType The type of the action to validate.
   */
  modifier validActionType(
    ActionType actionType
  ) {
    if (actionType == ActionType.INVALID) {
      revert InvalidActionType(actionType);
    }
    _;
  }

  /**
   * @dev Modifier to ensure a valid vault action.
   * Reverts with `InvalidAction` if the given action ID is invalid.
   * @param actionId The ID of the action to validate.
   */
  modifier validAction(
    uint256 actionId
  ) {
    if (actionId == 0 || actionId > _actionCount.current()) {
      revert InvalidAction(actionId);
    }
    _;
  }

  /**
   * @dev Modifier to ensure a valid vault action has't been executed.
   * Reverts with `ActionAlreadyExecuted` if the valid action has been executed.
   * @param actionId The ID of the action to validate.
   */
  modifier pendingAction(
    uint256 actionId
  ) {
    if (_actions[actionId].isExecuted) {
      revert ActionAlreadyExecuted(actionId);
    }
    _;
  }

  /**
   * @notice Initiates a new action requiring approval.
   * @param actionType The type of action.
   * @param target The target address (for signer-related actions).
   * @param value The associated value.
   */
  function initiateAction(
    ActionType actionType,
    address target,
    uint256 value
  ) public validSigner isExecutable validActionType(actionType) nonReentrant {
    if (_isPendingAction) revert PendingActionState(_isPendingAction);

    if (actionType == ActionType.ADD_SIGNER && target == address(0)) {
      revert InvalidUserProfile(target);
    }

    if (actionType == ActionType.ADD_SIGNER && isSigner(target)) {
      revert SignerAlreadyExists(target);
    }

    if (actionType == ActionType.REMOVE_SIGNER && !isSigner(target)) {
      revert SignerDoesNotExist(target);
    }

    if (actionType == ActionType.INCREASE_TIMELOCK && value <= multiSigTimelock) {
      revert InvalidMultiSigTimelockIncrease(value);
    }

    if (actionType == ActionType.DECREASE_TIMELOCK && value >= multiSigTimelock) {
      revert InvalidMultiSigTimelockDecrease(value);
    }

    if (actionType == ActionType.INCREASE_THRESHOLD && value <= signatoryThreshold) {
      revert InvalidSignatoryThresholdIncrease(value);
    }

    if (actionType == ActionType.DECREASE_THRESHOLD && value >= signatoryThreshold) {
      revert InvalidSignatoryThresholdDecrease(value);
    }

    _isPendingAction = true;
    _actionCount.increment();
    uint256 actionId = _actionCount.current();
    Action storage newAction = _actions[actionId];

    newAction.initiator = _msgSender();
    newAction.actionType = actionType;
    newAction.target = target;
    newAction.value = value;
    newAction.timestamp = block.timestamp;

    emit ActionInitiated(actionId, _msgSender(), actionType);
  }

  /**
   * @notice Enables valid signers to approve a action.
   * @param actionId The ID of the action to approve.
   */
  function approveAction(
    uint256 actionId
  ) public validSigner validAction(actionId) pendingAction(actionId) {
    Action storage action = _actions[actionId];
    if (action.signatures.contains(_msgSender())) revert ActionNotApproved(actionId);

    action.approvals.increment();
    action.signatures.add(_msgSender());
    emit ActionApproved(actionId, _msgSender(), block.timestamp);
  }

  /**
   * @notice Enables valid signers to revokes a action approval.
   * @param actionId The ID of the action to revoke approval for.
   */
  function revokeActionApproval(
    uint256 actionId
  ) public validSigner validAction(actionId) pendingAction(actionId) {
    Action storage action = _actions[actionId];
    if (!action.signatures.contains(_msgSender())) revert ActionNotApproved(actionId);

    action.approvals.decrement();
    action.signatures.remove(_msgSender());
    emit ActionRevoked(actionId, _msgSender(), block.timestamp);
  }

  /**
   * @notice Executes the approved action if threshold approvals and timelock are met.
   * @param actionId The ID of the action.
   */
  function executeAction(
    uint256 actionId
  ) public validExecutor validAction(actionId) pendingAction(actionId) nonReentrant {
    Action storage action = _actions[actionId];
    uint256 executionTimestamp = block.timestamp;
    if (!_isMultiSigTimelockElapsed(action.timestamp)) {
      uint256 requiredTime = action.timestamp.add(multiSigTimelock);
      revert TimelockNotElapsed(requiredTime, executionTimestamp);
    }

    if (_isOwner(_msgSender())) {
      if (!action.signatures.contains(_msgSender())) revert ActionNotApproved(actionId);
      if (!_isSignatoryThresholdMet(action.approvals.current())) {
        revert InsufficientSignerApprovals(signatoryThreshold, action.approvals.current());
      }
    }

    if (_isExecutor(_msgSender()) && action.approvals.current() < signatoryThreshold) {
      action.isOverride = true;
    }

    // Perform the action based on ActionType
    if (action.actionType == ActionType.INCREASE_THRESHOLD || action.actionType == ActionType.DECREASE_THRESHOLD) {
      _updateSignatoryThreshold(action.value);
    } else if (action.actionType == ActionType.INCREASE_TIMELOCK || action.actionType == ActionType.DECREASE_TIMELOCK) {
      _updateMultiSigTimelock(action.value);
    } else if (action.actionType == ActionType.ADD_SIGNER) {
      _addSigner(action.target);
    } else if (action.actionType == ActionType.REMOVE_SIGNER) {
      _removeSigner(action.target);
    }

    _isPendingAction = false;
    action.isExecuted = true;
    emit ActionExecuted(actionId, action.actionType, _msgSender(), executionTimestamp);
  }

  /**
   * @notice Deletes the latest action item if not executed.
   * @dev Only callable by a contract executor (Owner or Executor)
   */
  function deletePendingAction() public validExecutor {
    if (!_isPendingAction) revert PendingActionState(_isPendingAction);

    uint256 latestActionId = _actionCount.current();
    if (_actions[latestActionId].isExecuted) {
      revert ActionAlreadyExecuted(latestActionId);
    }

    delete _actions[latestActionId];
    _actionCount.decrement();
  }

  /**
   * @notice Returns the total number of actions.
   * @return uint256 The total number of actions.
   * @dev Only callable by contract users.
   */
  function totalActions() public view onlyUser returns (uint256) {
    return _actionCount.current();
  }

  /**
   * @notice Returns the action details of a given ID, excluding signatures.
   * @param actionId The ID of the requested action.
   * @return initiator The address of the action initiator.
   * @return actionType The type of action being initiated.
   * @return target The target address (for signer-related actions).
   * @return value The value associated with the action (e.g., timelock or threshold values).
   * @return timestamp The time when the action was initiated.
   * @return approvals The total number of approvals.
   * @return isExecuted Whether the action has been executed.
   * @return isOverride Whether the action was overridden by the executor.
   */
  function getAction(
    uint256 actionId
  )
    public
    view
    onlyUser
    validAction(actionId)
    returns (
      address initiator,
      ActionType actionType,
      address target,
      uint256 value,
      uint256 timestamp,
      uint256 approvals,
      bool isExecuted,
      bool isOverride
    )
  {
    Action storage action = _actions[actionId];
    return (
      action.initiator,
      action.actionType,
      action.target,
      action.value,
      action.timestamp,
      action.approvals.current(),
      action.isExecuted,
      action.isOverride
    );
  }

  /**
   * @notice Returns the total number of approvals an action has.
   * @param actionId The ID of the requested action.
   * @return uint256 The action total number of approvers.
   */
  function getActionApprovals(
    uint256 actionId
  ) public view validAction(actionId) onlyUser returns (uint256) {
    return _actions[actionId].approvals.current();
  }

  /**
   * @notice Returns the signatures associated with an action.
   * @param actionId The ID of the requested action.
   * @return address[] The action signatures array.
   */
  function getActionSignatures(
    uint256 actionId
  ) public view validAction(actionId) onlyUser returns (address[] memory) {
    Action storage action = _actions[actionId];
    return action.signatures.values();
  }

  /**
   * @notice Updates the signatory threshold for the vault.
   *  Emits the `ThresholdUpdated` event.
   * @param newThreshold The new threshold value for signatory approval.
   * @dev Only callable by the contract executors.
   */
  function _updateSignatoryThreshold(
    uint256 newThreshold
  ) internal validExecutor {
    uint256 oldThreshold = signatoryThreshold;
    signatoryThreshold = newThreshold;
    emit ThresholdUpdated(oldThreshold, newThreshold);
  }

  /**
   * @notice Verifies if the signatory threshold has been met for an action.
   * @param approvalCount The current number of approvals for the action.
   * @return bool Returns true if the required signatory threshold is met, otherwise false.
   */
  function _isSignatoryThresholdMet(
    uint256 approvalCount
  ) internal view returns (bool) {
    return approvalCount >= signatoryThreshold;
  }

  /**
   * @notice Verifies if the timelock period has passed for an action.
   * @param initiatedAt The timestamp when the action was initiated.
   * @return bool Returns true if the timelock period has elapsed, otherwise false.
   */
  function _isMultiSigTimelockElapsed(
    uint256 initiatedAt
  ) internal view returns (bool) {
    return block.timestamp >= initiatedAt + multiSigTimelock;
  }

  /**
   * @notice Updates the multi-sig vault timelock.
   * Emits the `MultiSigTimelockUpdated` event.
   * @param newLimit The new timelock value for action execution.
   * @dev Only callable by the contract executors.
   */
  function _updateMultiSigTimelock(
    uint256 newLimit
  ) private validExecutor {
    uint256 oldLimit = multiSigTimelock;
    multiSigTimelock = newLimit;
    emit MultiSigTimelockUpdated(oldLimit, newLimit);
  }
}
