// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

import '@openzeppelin/contracts/utils/Address.sol';

/**
 * @title AddressUtils Library
 * @author Emmanuel Joseph (JET)
 * @dev Extends OpenZeppelin's Address library to add custom utility functions.
 */
library AddressUtils {
  using Address for address;

  /**
   * @dev Error thrown when the provided user address is not valid.
   * @param account The invalid user address
   */
  error InvalidUserAddress(address account);

  /**
   * @dev Error thrown when an invalid transaction receiver is provided.
   * @param receiver The invalid receiver address.
   */
  error InvalidTransactionReceiver(address receiver);

  /**
   * @notice Ensure a user address is valid (i.e., not a zero address).
   * @param account The user address to validate.
   */
  function requireValidUserAddress(
    address account
  ) internal pure {
    if (account == address(0)) {
      revert InvalidUserAddress(account);
    }
  }

  /**
   * @notice Ensure a transaction receiver is valid.
   * @param receiver The transaction receiver to validate.
   */
  function requireValidTransactionReceiver(
    address payable receiver
  ) internal view {
    if (receiver == address(0) || receiver == address(this)) {
      revert InvalidTransactionReceiver(receiver);
    }
  }
}
