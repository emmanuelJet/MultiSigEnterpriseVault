// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.27;

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
