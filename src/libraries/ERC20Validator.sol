// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.27;

import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';

/**
 * @title ERC20Validator Library
 * @author Emmanuel Joseph (JET)
 * @dev Collection of functions related to address type for validating ERC20 tokens.
 */
library ERC20Validator {
  /**
   * @dev Error thrown when an invalid ERC20 token address is provided.
   * @param token The invalid token address.
   */
  error InvalidERC20TokenAddress(address token);

  /**
   * @notice Checks if the given address is a contract.
   * @param account The address to check.
   * @return bool True if the address is a contract, false otherwise.
   */
  function isContract(
    address account
  ) internal view returns (bool) {
    uint256 size;
    assembly {
      size := extcodesize(account)
    }
    return size > 0;
  }

  /**
   * @notice Checks if a given address is an ERC20 token contract.
   * @param token The address of the token contract to check.
   * @dev This function verifies if the provided address is a contract and attempts to call
   * several ERC20 functions to ensure compliance with the ERC20 standard.
   * If any of these calls fail, the function reverts with an error.
   */
  function requireValidERC20Token(
    address token
  ) internal {
    if (!isContract(token)) {
      revert InvalidERC20TokenAddress(token);
    }

    // Try to call ERC20 functions and check for success
    try IERC20(token).balanceOf(address(this)) returns (uint256) {}
    catch {
      revert InvalidERC20TokenAddress(token);
    }
    try IERC20(token).transfer(address(this), 0) returns (bool) {}
    catch {
      revert InvalidERC20TokenAddress(token);
    }
    try IERC20(token).transferFrom(address(this), address(this), 0) returns (bool) {}
    catch {
      revert InvalidERC20TokenAddress(token);
    }
  }
}
