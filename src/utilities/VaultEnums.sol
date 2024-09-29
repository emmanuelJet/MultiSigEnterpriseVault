// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.27;

/**
 * @title Vault RoleType Enum
 * @author Emmanuel Joseph (JET)
 * @notice RoleType helps differentiate between Owner, Executor, and Signer roles.
 *
 * @dev Enum representing the different roles in the MultiSig Vault contract.
 * - INVALID  0: Represents an invalid role
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
