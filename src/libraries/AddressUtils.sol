// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.27;

import '@openzeppelin/contracts/utils/Address.sol';

/**
 * @title AddressUtils Library
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
   * @dev Error thrown when an invalid token address is provided.
   * @param token The invalid token address.
   */
  error InvalidTokenAddress(address token);

  /**
   * @dev Error thrown when an invalid transaction target is provided.
   * @param target The invalid target address.
   */
  error InvalidTransactionTarget(address target);

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
   * @notice Ensure a token address is valid.
   * @param token The token address to validate.
   */
  function requireValidTokenAddress(
    address token
  ) internal pure {
    if (token == address(0)) {
      revert InvalidTokenAddress(token);
    }
  }

  /**
   * @notice Ensure a transaction target is valid.
   * @param target The transaction target to validate.
   */
  function requireValidTransactionTarget(
    address payable target
  ) internal pure {
    if (target == address(0)) {
      revert InvalidTransactionTarget(target);
    }
  }
}
