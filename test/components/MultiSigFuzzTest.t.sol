// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.27;

import '../MultiSigEnterpriseVault.t.sol';

contract MultiSigFuzzTest is MultiSigEnterpriseVaultTest {
  function testFuzzRemoveSigner(
    address signer
  ) public {
    vm.assume(signer != address(0));

    vm.prank(vaultOwner);
    vault.addSigner(signer);
    assertTrue(vault.isSigner(signer));

    vm.prank(vaultOwner);
    vault.removeSigner(signer);
    assertFalse(vault.isSigner(signer));
  }

  function testFuzzUpdateExecutor(
    address newExecutor
  ) public {
    vm.assume(newExecutor != address(0));
    vm.assume(newExecutor != vaultOwner);

    vm.prank(vaultOwner);
    vault.addExecutor(newExecutor);
    assertEq(vault.executor(), newExecutor);

    address anotherExecutor = makeAddr('randomExecutor');
    vm.prank(vaultOwner);
    vault.updateExecutor(anotherExecutor);
    assertEq(vault.executor(), anotherExecutor);
  }

  function testFuzzIncreaseOwnerOverrideTimelock(
    uint256 newLimit
  ) public {
    vm.assume(newLimit > vault.ownerOverrideTimelock());

    vm.prank(vaultOwner);
    vault.increaseOwnerOverrideTimelockLimit(newLimit);
    assertEq(vault.ownerOverrideTimelock(), newLimit);
  }

  function testFuzzUpdateThreshold(
    uint256 newThreshold
  ) public {
    vm.assume(newThreshold > 0);
    vm.prank(vaultOwner);
    vault.ownerUpdateSignatoryThreshold(newThreshold);
    assertEq(vault.signatoryThreshold(), newThreshold);
  }
}
