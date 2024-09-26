// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.27;

import {RoleType} from './VaultEnums.sol';

/**
 * @title UserProfile Struct
 * @author Emmanuel Joseph (JET)
 * @notice This struct stores the user profile details such as the user address, role, and the timestamp of when they joined.
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
