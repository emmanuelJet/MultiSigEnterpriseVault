// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.27;

import '../libraries/Counters.sol';
import {RoleType} from './VaultEnums.sol';

using Counters for Counters.Counter;

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
 * - `target`: The address to receive the transaction tokens.
 * - `token`: The token contract address (0x0 for ETH).
 * - `value`: The ETH or token value to send.
 * - `approvals`: The total number of approvals
 * - `signatures`: The addresses of those who approved/signed the transaction
 * - `isExecuted`: Checks whether the transaction has been executed.
 * - `isOverride`: Checks whether the transaction was override by the `executor`.
 * - `data`: The transaction data (0x0 for empty data)
 */
struct Transaction {
  address initiator;
  address payable target;
  address token;
  uint256 value;
  Counters.Counter approvals;
  address[] signatures;
  bool isExecuted;
  bool isOverride;
  bytes data;
}
