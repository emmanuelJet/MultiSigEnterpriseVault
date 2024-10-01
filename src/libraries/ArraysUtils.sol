// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.27;

import '@openzeppelin/contracts/utils/Arrays.sol';

/**
 * @title ArraysUtils Library
 * @dev Extends OpenZeppelin's Arrays library to add custom utility functions.
 */
library ArraysUtils {
  /**
   * @dev Error thrown when the provided index is not found in an array.
   * @param index The invalid array index
   */
  error ArrayIndexOutOfBound(uint256 index);

  /**
   * @dev Finds the index of a 'uint256' array element.
   * @param element The array element to find
   * @param array The array to lookup
   * @return index The index of the found element
   */
  function arrayElementIndexLookup(uint256 element, uint256[] memory array) internal pure returns (uint256 index) {
    index = 0;
    while (array[index] != element) {
      index++;
    }
  }

  /**
   * @dev Finds the index of a 'address' array element.
   * @param element The array element to find
   * @param array The array to lookup
   * @return index The index of the found element
   */
  function arrayElementIndexLookup(address element, address[] memory array) internal pure returns (uint256 index) {
    index = 0;
    while (array[index] != element) {
      index++;
    }
  }

  /**
   * @dev Removes an element by index from a 'uint256' array.
   * @param index The array index of the element
   * @param array The array to lookup for removal
   *
   * Requirements:
   * - Ensures the `index` is available in the given array
   */
  function removeElementFromArray(uint256 index, uint256[] storage array) internal {
    if (index > array.length) revert ArrayIndexOutOfBound(index);
    for (uint256 i = index; i < array.length - 1; i++) {
      array[i] = array[i + 1];
    }

    array.pop();
  }

  /**
   * @dev Removes an element by index from a 'address' array.
   * @param index The array index of the element
   * @param array The array to lookup for removal
   *
   * Requirements:
   * - Ensures the `index` is available in the given array
   */
  function removeElementFromArray(uint256 index, address[] storage array) internal {
    if (index > array.length) revert ArrayIndexOutOfBound(index);
    for (uint256 i = index; i < array.length - 1; i++) {
      array[i] = array[i + 1];
    }

    array.pop();
  }
}
