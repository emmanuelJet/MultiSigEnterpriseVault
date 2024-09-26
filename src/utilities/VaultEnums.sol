// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.27;

/**
 * @title Vault RoleType Enum
 * @author Emmanuel Joseph (JET)
 * @notice RoleType helps differentiate between Owner, Executor, and Signer roles.
 *
 * @dev Enum representing the different roles in the MultiSig Vault contract.
 * - OWNER    0: Represents the Owner role
 * - EXECUTOR 1: Represents the Executor role
 * - SIGNER   2: Represents the Signer role
 */
enum RoleType {
  OWNER,
  EXECUTOR,
  SIGNER
}
