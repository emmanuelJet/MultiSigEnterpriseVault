// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.27;

import '../MultiSigEnterpriseVault.t.sol';

contract BaseMultiSigTest is MultiSigEnterpriseVaultTest {
  function testOwnerAddress() public view {
    assertEq(vault.owner(), vaultOwner);
  }

  function testTotalUsers() public {
    vm.prank(vaultOwner);
    assertEq(vault.totalUsers(), 1);
  }

  function testInitialThreshold() public view {
    assertEq(vault.signatoryThreshold(), initialThreshold);
  }
}
