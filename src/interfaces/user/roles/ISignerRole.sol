// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

/**
 * @title ISignerRole Interface
 * @author Emmanuel Joseph (JET)
 * @dev Interface defining errors and events related to the Signer role in the MultiSigVault system.
 */
interface ISignerRole {
  /**
   * @dev Error thrown when an unauthorized account attempts to perform an signer action.
   * @param account The address of the unauthorized account.
   */
  error AccessControlUnauthorizedSigner(address account);

  /**
   * @dev Error thrown when attempting to add a new signer with an existing user role.
   * @param signer The invalid signer address.
   */
  error InvalidSignerUser(address signer);

  /**
   * @dev Error thrown when an unauthorized account attempts to execute a transaction.
   * @param account The address of the unauthorized account.
   */
  error UnauthorizedMultiSigExecutor(address account);

  /**
   * @dev Error thrown when trying to add a signer that already exists.
   * @param newSigner The address of the signer that already exists.
   */
  error SignerAlreadyExists(address newSigner);

  /**
   * @dev Error indicating that the specified signer does not exist.
   * @param signer The address of the signer that does not exist.
   */
  error SignerDoesNotExist(address signer);

  /**
   * @dev Event emitted when a new signer is added.
   * @param signer The new signer address.
   */
  event SignerAdded(address indexed signer);

  /**
   * @dev Event emitted when an signer is removed.
   * @param signer The removed signer address.
   */
  event SignerRemoved(address indexed signer);
}
