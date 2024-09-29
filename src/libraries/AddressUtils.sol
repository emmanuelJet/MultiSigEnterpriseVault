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
}
