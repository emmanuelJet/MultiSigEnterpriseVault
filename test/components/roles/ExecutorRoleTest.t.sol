// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.27;

import '../../MultiSigEnterpriseVault.t.sol';
import {RoleType} from '../../../src/utilities/VaultEnums.sol';
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

  function testExecutorCanInitiateOwnerOverride() public {
    vm.prank(vaultOwner);
    vault.addExecutor(vaultExecutor);

    vm.prank(vaultExecutor);
    vault.initiateOwnerOverride();
    assertEq(vault.isOverrideActive(), true);
  }

  function testCannotInitiateOwnerOverrideTwice() public {
    vm.prank(vaultOwner);
    vault.addExecutor(vaultExecutor);

    vm.prank(vaultExecutor);
    vault.initiateOwnerOverride();
    assertEq(vault.isOverrideActive(), true);

    vm.prank(vaultExecutor);
    vm.expectRevert();
    vault.initiateOwnerOverride();
  }

  function testNonExecutorCannotInitiateOwnerOverride() public {
    vm.prank(vaultOwner);
    vault.addExecutor(vaultExecutor);

    vm.prank(makeAddr('nonExecutor'));
    vm.expectRevert();
    vault.initiateOwnerOverride();
  }

  function testOwnerOverrideCanBeApprovedAfterTimelock() public {
    address oldOwner = vaultOwner;
    vm.prank(vaultOwner);
    vault.addExecutor(vaultExecutor);
    vm.prank(vaultOwner);
    assertEq(vault.totalUsers(), 2);

    // Initiate owner override
    vm.prank(vaultExecutor);
    vault.initiateOwnerOverride();
    vm.prank(vaultOwner);
    UserProfile memory executorProfile = vault.getUserProfile(vaultExecutor);
    assertTrue(executorProfile.role == RoleType.EXECUTOR);

    // Fast forward time to simulate passing the timelock period
    vm.warp(block.timestamp + vault.ownerOverrideTimelock() + 1);

    // Approve the owner override
    vm.prank(vaultExecutor);
    vault.approveOwnerOverride();

    // Check that override is no longer active
    assertEq(vault.isOverrideActive(), false);

    // Check that the old owner has been updated
    assertNotEq(vault.owner(), oldOwner);

    // Check that the old executor is not the owner
    assertEq(vault.owner(), vaultExecutor);

    // Check that the contract has no executor
    assertEq(vault.executor(), address(0));

    // Check that the old owner cannot perform Owner function
    vm.prank(oldOwner);
    vm.expectRevert();
    vault.totalUsers();

    // Check that the old Executor can perform Owner functions
    vm.prank(vaultExecutor);
    assertEq(vault.totalUsers(), 1);

    vm.prank(vaultExecutor);
    UserProfile memory ownerProfile = vault.getUserProfile(vaultExecutor);
    assertTrue(ownerProfile.role == RoleType.OWNER);

    vm.prank(vaultExecutor);
    uint256 newOwnerOverrideTimelock = 24 hours;
    vault.decreaseOwnerOverrideTimelockLimit(newOwnerOverrideTimelock);
    assertEq(vault.ownerOverrideTimelock(), newOwnerOverrideTimelock);
  }

  function testCannotApproveOwnerOverrideBeforeTimelock() public {
    vm.prank(vaultOwner);
    vault.addExecutor(vaultExecutor);

    vm.prank(vaultExecutor);
    vault.initiateOwnerOverride();

    // Attempt to approve before the timelock has elapsed
    vm.prank(vaultExecutor);
    vm.expectRevert();
    vault.approveOwnerOverride();
  }
}
