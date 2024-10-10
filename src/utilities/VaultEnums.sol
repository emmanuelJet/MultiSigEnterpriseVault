// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

/**
 * @title Vault RoleType Enum
 * @author Emmanuel Joseph (JET)
 * @notice RoleType helps differentiate between Owner, Executor, and Signer roles.
 *
 * @dev Enum representing the different roles in the MultiSig Vault contract.
 * - INVALID  0: Represents an invalid role for security purpose
 * - OWNER    1: Represents the Owner role
 * - EXECUTOR 2: Represents the Executor role
 * - SIGNER   3: Represents the Signer role
 */
enum RoleType {
  INVALID,
  OWNER,
  EXECUTOR,
  SIGNER
}

/**
 * @title Vault ActionType Enum
 * @author Emmanuel Joseph (JET)
 * @notice ActionType helps differentiate between types of actions that require approval.
 *
 * @dev Enum representing the different signatory actions in the MultiSig Vault contract.
 * - INVALID            0: Represents an invalid action for security purpose
 * - ADD_SIGNER         1: Represents the add signer action
 * - REMOVE_SIGNER      2: Represents the remove signer action
 * - INCREASE_TIMELOCK  3: Represents the increase timelock action
 * - DECREASE_TIMELOCK  4: Represents the decrease timelock action
 * - INCREASE_THRESHOLD 5: Represents the increase threshold action
 * - DECREASE_THRESHOLD 6: Represents the decrease threshold action
 */
enum ActionType {
  INVALID,
  ADD_SIGNER,
  REMOVE_SIGNER,
  INCREASE_TIMELOCK,
  DECREASE_TIMELOCK,
  INCREASE_THRESHOLD,
  DECREASE_THRESHOLD
}
