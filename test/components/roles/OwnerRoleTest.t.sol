// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.27;

import '../../MultiSigEnterpriseVault.t.sol';
import {RoleType} from '../../../src/utilities/VaultEnums.sol';
import {UserProfile} from '../../../src/utilities/VaultStructs.sol';

contract OwnerRoleTest is MultiSigEnterpriseVaultTest {
  function testOwnerProfile() public {
    vm.prank(vaultOwner);
    UserProfile memory adminUser = vault.getUserProfile(vaultOwner);
    assertEq(adminUser.user, vaultOwner);
  }

  function testInvalidUserProfile() public {
    vm.prank(vaultOwner);
    vm.expectRevert();
    vault.getUserProfile(address(0x5678));
  }

  function testOnlyOwnerCanUpdateThreshold() public {
    vm.prank(address(0x5678));
    vm.expectRevert();
    vault.updateSignatoryThreshold(5);
  }

  function testUpdateSignatoryThreshold() public {
    vm.prank(vaultOwner);
    uint256 newSignatoryThreshold = 5;
    vault.updateSignatoryThreshold(newSignatoryThreshold);
    assertEq(vault.signatoryThreshold(), newSignatoryThreshold);
  }

  function testUnauthorizedTimelockUpdate() public {
    vm.prank(address(0x5678));
    vm.expectRevert();
    vault.increaseOwnerOverrideTimelock(5 days);
  }

  function testOwnerOverrideTimelock() public view {
    assertEq(vault.ownerOverrideTimelock(), initialOwnerOverrideTimelock);
  }

  function testOwnerCanIncreaseOverrideTimelock() public {
    vm.prank(vaultOwner);
    vault.increaseOwnerOverrideTimelock(5 days);
    assertEq(vault.ownerOverrideTimelock(), 5 days);
  }

  function testOwnerCanDecreaseOverrideTimelock() public {
    vm.prank(vaultOwner);
    vault.decreaseOwnerOverrideTimelock(24 hours);
    assertEq(vault.ownerOverrideTimelock(), 24 hours);
  }
}
