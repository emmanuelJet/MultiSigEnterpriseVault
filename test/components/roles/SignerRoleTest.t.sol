// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.27;

import '../../MultiSigEnterpriseVault.t.sol';

contract SignerRoleTest is MultiSigEnterpriseVaultTest {
  address internal firstSigner;
  address internal secondSigner;

  function setUp() public override {
    super.setUp();
    firstSigner = makeAddr('firstSigner');
    secondSigner = makeAddr('secondSigner');
  }

  function testOwnerCanAddSigner() public {
    vm.prank(vaultOwner);
    vault.addSigner(firstSigner);

    // Check if the signer was added correctly via `_signers`
    assertEq(vault.totalSigners(), 1);
    address[] memory signers = vault.getSigners();
    assertEq(signers[0], firstSigner);

    // Check if the signer was added correctly via `_users`
    vm.prank(vaultOwner);
    address signerProfileAddress = vault.getUserProfile(firstSigner).user;
    assertEq(signerProfileAddress, firstSigner);
  }

  function testOwnerCannotAddInvalidSigner() public {
    vm.prank(vaultOwner);
    address invalidSigner = address(0);
    vm.expectRevert();
    vault.addSigner(invalidSigner);
  }

  function testOwnerCannotAddSignerWithoutApproval() public {
    vm.prank(vaultOwner);
    vault.addSigner(firstSigner);
    vm.prank(vaultOwner);
    vault.addSigner(secondSigner);
    vm.prank(vaultOwner);
    assertEq(vault.totalSigners(), 2);

    vm.prank(vaultOwner);
    vm.expectRevert();
    vault.addSigner(vaultDeployer);
  }

  function testOwnerCannotUpdateThresholdWithoutApproval() public {
    vm.prank(vaultOwner);
    vault.addSigner(firstSigner);
    vm.prank(vaultOwner);
    vault.addSigner(secondSigner);
    assertEq(vault.totalSigners(), 2);

    vm.prank(vaultOwner);
    vm.expectRevert();
    vault.updateSignatoryThreshold(5);
  }

  function testSignerCannotAddAnotherSigner() public {
    // Add signer as the owner
    vm.prank(vaultOwner);
    vault.addSigner(firstSigner);

    // Try to add another signer as a non-owner
    vm.prank(firstSigner);
    vm.expectRevert();
    vault.addSigner(secondSigner);
  }

  function testRemoveSigner() public {
    vm.prank(vaultOwner);
    vault.addSigner(firstSigner);

    // Remove signer
    vm.prank(vaultOwner);
    vault.removeSigner(firstSigner);

    // Verify the signer was removed via `_signers`
    assertEq(vault.totalSigners(), 0);
    address[] memory signers = vault.getSigners();
    assertEq(signers.length, 0);

    // Verify the signer was removed via `_users`
    vm.prank(vaultOwner);
    assertEq(vault.totalUsers(), 1);

    vm.prank(vaultOwner);
    vm.expectRevert();
    vault.getUserProfile(firstSigner);
  }

  function testCannotRemoveNonexistentSigner() public {
    vm.prank(vaultOwner);
    vm.expectRevert();
    vault.removeSigner(firstSigner);
  }

  function testCannotAddSameSignerTwice() public {
    vm.prank(vaultOwner);
    vault.addSigner(firstSigner);

    // Try adding the same signer again
    vm.prank(vaultOwner);
    vm.expectRevert();
    vault.addSigner(firstSigner);

    vm.prank(vaultOwner);
    assertEq(vault.totalUsers(), 2);
    assertEq(vault.totalSigners(), 1);
  }
}
