// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

import '@openzeppelin/contracts/utils/structs/EnumerableSet.sol';
import '../libraries/Counters.sol';
import './VaultEnums.sol';

using Counters for Counters.Counter;
using EnumerableSet for EnumerableSet.AddressSet;

/**
 * @title UserProfile Struct
 * @author Emmanuel Joseph (JET)
 * @notice This struct stores the vault's user profile details.
 *
 * @dev
 * - `user`: The address of the user.
 * - `role`: The role assigned to the user (from RoleType enum).
 * - `joinedAt`: The timestamp (in seconds) when the user was added to the system.
 */
struct UserProfile {
  address user;
  RoleType role;
  uint256 joinedAt;
}

/**
 * @title Transaction Struct
 * @author Emmanuel Joseph (JET)
 * @notice This struct stores the vault's transaction details.
 *
 * @dev
 * - `initiator`: The initiator of the transaction (Owner or Signer).
 * - `to`: The address receiving the transaction tokens.
 * - `token`: The token contract address (0x0 for ETH).
 * - `value`: The ETH or token value to send.
 * - `approvals`: The total number of approvals
 * - `signatures`: The addresses of those who approved/signed the transaction
 * - `isExecuted`: Checks whether the transaction has been executed.
 * - `isOverride`: Checks whether the transaction was overridden by the `executor`.
 * - `data`: The transaction data (0x0 for empty data)
 */
struct Transaction {
  address initiator;
  address payable to;
  address token;
  uint256 value;
  uint256 timestamp;
  Counters.Counter approvals;
  EnumerableSet.AddressSet signatures;
  bool isExecuted;
  bool isOverride;
  bytes data;
}

/**
 * @title Action Struct
 * @author Emmanuel Joseph (JET)
 * @notice This struct stores information about actions that require approval.
 *
 * @dev
 * - `initiator`: The initiator of the action (Owner or Signer).
 * - `actionType`: The type of action being proposed.
 * - `target`: The target address (for signer-related actions).
 * - `value`: The value related to the action (e.g., timelock or threshold values).
 * - `timestamp`: The time when the action was initiated.
 * - `approvals`: The total number of approvals
 * - `signatures`: The addresses of those who approved/signed the action
 * - `isExecuted`: Checks whether the action has been executed.
 * - `isOverride`: Checks whether the action was overridden by the `executor`.
 */
struct Action {
  address initiator;
  ActionType actionType;
  address target;
  uint256 value;
  uint256 timestamp;
  Counters.Counter approvals;
  EnumerableSet.AddressSet signatures;
  bool isExecuted;
  bool isOverride;
}
