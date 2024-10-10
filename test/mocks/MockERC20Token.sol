// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

/**
 * @title MockERC20Token
 * @dev A mock ERC20 token for testing purposes.
 */
contract MockERC20Token is ERC20 {
  constructor(
    address owner
  ) ERC20('Mock Token', 'MOCK') {
    _mint(owner, 1000 ether);
  }
}
