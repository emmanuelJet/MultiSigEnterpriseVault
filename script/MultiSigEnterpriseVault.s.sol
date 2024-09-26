// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.27;

import {Script, console} from 'forge-std/Script.sol';
import {MultiSigEnterpriseVault} from '../src/MultiSigEnterpriseVault.sol';

contract MultiSigEnterpriseVaultScript is Script {
  MultiSigEnterpriseVault internal vault;
  address internal vaultAddress;

  function setUp() public {}

  function run() public {
    vm.startBroadcast();

    uint256 initialThreshold = 3;
    uint256 initialOwnerOverrideLimit = 3 days;
    address vaultOwner = makeAddr('vaultOwner');

    vault = new MultiSigEnterpriseVault(vaultOwner, initialThreshold, initialOwnerOverrideLimit);
    vaultAddress = address(vault);

    console.log('MultiSigVault Contract Address:', vaultAddress);

    vm.stopBroadcast();
  }
}
