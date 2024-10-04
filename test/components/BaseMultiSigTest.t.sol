// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.27;

import '../MultiSigEnterpriseVault.t.sol';

contract BaseMultiSigTest is MultiSigEnterpriseVaultTest {
  address internal firstSigner;
  address internal secondSigner;
  address internal vaultExecutor;

  function setUp() public virtual override {
    super.setUp();

    firstSigner = makeAddr('firstSigner');
    secondSigner = makeAddr('secondSigner');
    vaultExecutor = makeAddr('vaultExecutor');

    vm.prank(vaultOwner);
    vault.addExecutor(vaultExecutor);

    vm.prank(vaultOwner);
    vault.addSigner(firstSigner);

    vm.prank(vaultOwner);
    vault.addSigner(secondSigner);
  }

  function testInitialValues() public view {
    assertEq(vault.owner(), vaultOwner);
    assertEq(vault.signatoryThreshold(), initialThreshold);
    assertEq(vault.multiSigTimelock(), initialMultiSigTimelock);
    assertEq(vault.ownerOverrideTimelock(), initialOwnerOverrideTimelock);
  }

  function testTotalUsers() public {
    vm.prank(vaultOwner);
    assertEq(vault.totalUsers(), 4);
    assertEq(vault.totalSigners(), 2);
  }
}
