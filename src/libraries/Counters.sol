// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.27;

import './SafeMath.sol';

/**
 * @title Counters Library
 * @dev Provides counter functionality that can be incremented or decremented with overflow safety.
 */
library Counters {
  using SafeMath for uint256;

  /**
   * @notice This struct should be used to manage counters in contracts.
   * @dev Struct that holds the counter value.
   */
  struct Counter {
    uint256 value; // Current value of the counter
  }

  /**
   * @notice Returns the current value of the counter.
   * @param counter The counter to query
   * @return The current value of the counter
   */
  function current(
    Counter storage counter
  ) internal view returns (uint256) {
    return counter.value;
  }

  /**
   * @notice Increments the counter by 1.
   * @param counter The counter to increment
   */
  function increment(
    Counter storage counter
  ) internal {
    counter.value = counter.value.add(1);
  }

  /**
   * @notice Increments the counter by a specific quantity.
   * @param counter The counter to increment
   * @param quantity The amount to increment the counter by
   */
  function incrementBy(Counter storage counter, uint256 quantity) internal {
    counter.value = counter.value.add(quantity);
  }

  /**
   * @notice Decrements the counter by 1.
   * @param counter The counter to decrement
   * @dev Reverts if the counter is already at 0.
   */
  function decrement(
    Counter storage counter
  ) internal {
    counter.value = counter.value.subtract(1);
  }

  /**
   * @notice Decrements the counter by a specific quantity.
   * @param counter The counter to decrement
   * @param quantity The amount to decrement the counter by
   * @dev Reverts if the counter does not have enough value.
   */
  function decrementBy(Counter storage counter, uint256 quantity) internal {
    counter.value = counter.value.subtract(quantity);
  }
}
