// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.27;

import '../../MultiSigEnterpriseVault.t.sol';
import {UserProfile} from '../../../src/utilities/VaultStructs.sol';

contract ExecutorRoleTest is MultiSigEnterpriseVaultTest {
  address internal vaultExecutor;

  function setUp() public override {
    super.setUp();
    vaultExecutor = makeAddr('vaultExecutor');
  }

  function testOwnerCanAddExecutor() public {
    vm.prank(vaultOwner);
    vault.addExecutor(vaultExecutor);

    vm.prank(vaultOwner);
    UserProfile memory executor = vault.getUserProfile(vaultExecutor);

    assertEq(vault.executor(), vaultExecutor);
    assertEq(executor.user, vaultExecutor);
  }

  function testAddExecutorWhenAlreadyExists() public {
    vm.prank(vaultOwner);
    vault.addExecutor(vaultExecutor);

    // Try to add a new executor when one already exists
    vm.expectRevert();
    vault.addExecutor(makeAddr('anotherExecutor'));
  }

  function testOwnerCanUpdateExecutor() public {
    vm.prank(vaultOwner);
    vault.addExecutor(vaultExecutor);
    assertEq(vault.executor(), vaultExecutor);

    // Update the executor
    vm.prank(vaultOwner);
    address updatedExecutor = makeAddr('updatedExecutor');
    vault.updateExecutor(updatedExecutor);

    // Check if the executor is updated correctly
    assertEq(vault.executor(), updatedExecutor);
  }

  function testUpdateExecutorWhenNoneExists() public {
    vm.prank(vaultOwner);
    vm.expectRevert();
    vault.updateExecutor(makeAddr('updatedExecutor'));
  }

  function testOwnerCanRemoveExecutor() public {
    vm.prank(vaultOwner);
    vault.addExecutor(vaultExecutor);

    // Remove the executor
    vm.prank(vaultOwner);
    vault.removeExecutor();

    // Ensure executor is removed
    assertEq(vault.executor(), address(0));
  }

  function testRemoveExecutorWhenNoneExists() public {
    vm.prank(vaultOwner);
    vm.expectRevert();
    vault.removeExecutor();
  }

  function testNonOwnerCannotAddExecutor() public {
    vm.prank(address(0x5678));
    vm.expectRevert();
    vault.addExecutor(vaultExecutor);
  }
}
