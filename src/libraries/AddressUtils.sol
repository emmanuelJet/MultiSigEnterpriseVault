// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.27;

import '@openzeppelin/contracts/utils/Address.sol';

/**
 * @title AddressUtils Library
 * @dev Extends OpenZeppelin's Address library to add custom utility functions.
 */
library AddressUtils {
  using Address for address;

  /// @dev Error thrown when the provided user address is not valid (zero).
  error InvalidUserAddress(address account);

  /**
   * @notice Checks if the address is valid (i.e., not a zero address).
   * @param account The address to validate.
   * @return status Returns true if the address is valid, otherwise false.
   */
  function isValidUserAddress(
    address account
  ) internal pure returns (bool status) {
    status = account != address(0);
    if (!status) {
      revert InvalidUserAddress(account);
    }
  }
}
