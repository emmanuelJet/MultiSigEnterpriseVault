// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

/**
 * @title SafeMath Library
 * @dev Collection of functions related to uint256 type for performing arithmetic operations safely with overflow checks.
 */
library SafeMath {
  /**
   * @notice Adds two unsigned integers, reverts on overflow.
   *
   * @param x First unsigned integer
   * @param y Second unsigned integer
   * @return r The sum of the two unsigned integers
   */
  function add(uint256 x, uint256 y) internal pure returns (uint256 r) {
    r = x + y;
    require(r >= x, 'SafeMath: addition overflow');
  }

  /**
   * @notice Subtracts two unsigned integers, reverts on underflow (when the result is negative).
   *
   * @param x First unsigned integer
   * @param y Second unsigned integer
   * @return r The difference of the two unsigned integers
   */
  function subtract(uint256 x, uint256 y) internal pure returns (uint256 r) {
    require(y <= x, 'SafeMath: subtraction overflow');
    r = x - y;
  }

  /**
   * @notice Multiplies two unsigned integers, reverts on overflow.
   *
   * @param x First unsigned integer
   * @param y Second unsigned integer
   * @return r The product of the two unsigned integers
   */
  function multiply(uint256 x, uint256 y) internal pure returns (uint256 r) {
    if (x == 0) {
      return 0;
    }
    r = x * y;
    require(r / x == y, 'SafeMath: multiplication overflow');
  }

  /**
   * @notice Divides two unsigned integers, reverts on division by zero.
   *
   * @param x First unsigned integer
   * @param y Second unsigned integer (must be non-zero)
   * @return r The quotient of the two unsigned integers
   */
  function divide(uint256 x, uint256 y) internal pure returns (uint256 r) {
    require(y > 0, 'SafeMath: division by zero');
    r = x / y;
  }

  /**
   * @notice Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * reverts when dividing by zero.
   *
   * @param x First unsigned integer
   * @param y Second unsigned integer (must be non-zero)
   * @return r The remainder of the division
   */
  function mod(uint256 x, uint256 y) internal pure returns (uint256 r) {
    require(y != 0, 'SafeMath: modulo by zero');
    r = x % y;
  }
}
