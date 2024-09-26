// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.27;

import {Test, console} from 'forge-std/Test.sol';
import {MultiSigEnterpriseVault} from '../src/MultiSigEnterpriseVault.sol';

contract MultiSigEnterpriseVaultTest is Test {
  MultiSigEnterpriseVault internal vault;

  address internal vaultOwner;
  address internal vaultAddress;
  address internal vaultDeployer;
  uint256 internal initialThreshold;
  uint256 internal initialOwnerOverrideLimit;

  function setUp() public virtual {
    initialThreshold = 3;
    initialOwnerOverrideLimit = 3 days;
    vaultOwner = makeAddr('vaultOwner');

    vault = new MultiSigEnterpriseVault(vaultOwner, initialThreshold, initialOwnerOverrideLimit);
    vaultAddress = address(vault);
    vaultDeployer = msg.sender;
  }
}
