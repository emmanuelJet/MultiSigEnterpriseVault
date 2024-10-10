// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

/**
 * @title IOwnerRole Interface
 * @author Emmanuel Joseph (JET)
 * @dev Interface defining errors and events related to the Owner role in the MultiSigVault system.
 */
interface IOwnerRole {
  /**
   * @dev Error thrown when an invalid owner override limit is provided.
   * @param value The invalid timelock value.
   */
  error InvalidOwnerOverrideTimelockValue(uint256 value);

  /**
   * @dev Error thrown when an unauthorized account attempts to perform an owner action.
   * @param account The address of the unauthorized account.
   */
  error AccessControlUnauthorizedOwner(address account);

  /**
   * @dev Event emitted when the owner override timelock is increased.
   * @param newLimit The new timelock limit for owner override.
   */
  event OwnerOverrideTimelockIncreased(uint256 newLimit);

  /**
   * @dev Event emitted when the owner override timelock is decreased.
   * @param newLimit The new timelock limit for owner override.
   */
  event OwnerOverrideTimelockDecreased(uint256 newLimit);

  /**
   * @dev Event emitted when an owner is updated.
   * @param oldOwner The old owner address.
   * @param newOwner The new owner address.
   */
  event OwnerChanged(address indexed oldOwner, address indexed newOwner);
}
