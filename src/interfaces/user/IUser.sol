// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

/**
 * @title IUser Interface
 * @author Emmanuel Joseph (JET)
 * @dev Interface defining errors related to the User role in the MultiSigVault system.
 */
interface IUser {
  /**
   * @dev Error thrown when an invalid user profile is encountered.
   * @param user The address of the user with an invalid profile.
   */
  error InvalidUserProfile(address user);

  /**
   * @dev Error thrown when an unauthorized account attempts to sign a transaction.
   * @param account The address of the unauthorized account.
   */
  error UnauthorizedMultiSigSigner(address account);
}
