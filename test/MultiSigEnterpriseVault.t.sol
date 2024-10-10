// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

import {Test, console} from 'forge-std/Test.sol';
import {MultiSigEnterpriseVault} from '../src/MultiSigEnterpriseVault.sol';

contract MultiSigEnterpriseVaultTest is Test {
  MultiSigEnterpriseVault internal vault;

  address internal vaultOwner;
  address internal vaultAddress;
  address internal vaultDeployer;
  uint256 internal initialThreshold;
  uint256 internal initialMultiSigTimelock;
  uint256 internal initialOwnerOverrideTimelock;

  function setUp() public virtual {
    initialThreshold = 3;
    initialMultiSigTimelock = 1 days;
    initialOwnerOverrideTimelock = 3 days;
    vaultOwner = makeAddr('vaultOwner');
    vm.deal(vaultOwner, 100 ether);

    vault =
      new MultiSigEnterpriseVault(vaultOwner, initialThreshold, initialMultiSigTimelock, initialOwnerOverrideTimelock);
    vaultAddress = address(vault);
    vaultDeployer = msg.sender;
  }
}
