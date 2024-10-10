// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

import {Script, console} from 'forge-std/Script.sol';
import {MultiSigEnterpriseVault} from '../src/MultiSigEnterpriseVault.sol';

contract MultiSigEnterpriseVaultScript is Script {
  MultiSigEnterpriseVault internal vault;
  address internal vaultAddress;

  function setUp() public {}

  function run() public {
    uint256 deployerPrivateKey = vm.envUint('PRIVATE_KEY');
    vm.startBroadcast(deployerPrivateKey);

    address vaultOwner = vm.envAddress('OWNER_ADDRESS');
    uint256 initialThreshold = vm.envUint('INITIAL_THRESHOLD');
    uint256 initialMultiSigTimelock = vm.envUint('INITIAL_MULTISIG_TIMELOCK');
    uint256 initialOwnerOverrideTimelock = vm.envUint('INITIAL_OWNEROVEREIDE_TIMELOCK');

    vault =
      new MultiSigEnterpriseVault(vaultOwner, initialThreshold, initialMultiSigTimelock, initialOwnerOverrideTimelock);
    vaultAddress = address(vault);

    console.log('MultiSigVault Contract Address:', vaultAddress);

    vm.stopBroadcast();
  }
}
