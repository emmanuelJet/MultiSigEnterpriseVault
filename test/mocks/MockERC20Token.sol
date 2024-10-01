// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.27;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

/**
 * @title MockERC20Token
 * @dev A mock ERC20 token for testing purposes.
 */
contract MockERC20Token is ERC20 {
  constructor() ERC20('Mock Token', 'MOCK') {
    _mint(msg.sender, 1000 ether);
  }
}
