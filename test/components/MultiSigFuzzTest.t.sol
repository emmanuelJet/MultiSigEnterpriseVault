// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.27;

import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {Address} from '@openzeppelin/contracts/utils/Address.sol';
import {ActionType} from '../../src/utilities/VaultEnums.sol';
import {MockERC20Token} from '../mocks/MockERC20Token.sol';
import '../MultiSigEnterpriseVault.t.sol';

contract MultiSigFuzzTest is MultiSigEnterpriseVaultTest {
  function testFuzzRemoveSigner(
    address signer
  ) public {
    vm.assume(signer != address(0) && signer != vaultOwner);

    vm.prank(vaultOwner);
    vault.addSigner(signer);
    assertTrue(vault.isSigner(signer));
    assertEq(vault.totalSigners(), 1);

    vm.prank(vaultOwner);
    vault.removeSigner(signer);
    assertFalse(vault.isSigner(signer));
    assertEq(vault.totalSigners(), 0);
  }

  function testFuzzUpdateExecutor(address newExecutor, address anotherExecutor) public {
    vm.assume(newExecutor != address(0) && newExecutor != vaultOwner);
    vm.assume(anotherExecutor != address(0) && anotherExecutor != newExecutor && anotherExecutor != vaultOwner);

    vm.prank(vaultOwner);
    vault.addExecutor(newExecutor);
    assertEq(vault.executor(), newExecutor);

    vm.prank(vaultOwner);
    vault.updateExecutor(anotherExecutor);
    assertEq(vault.executor(), anotherExecutor);
  }

  function testFuzzIncreaseOwnerOverrideTimelock(
    uint256 newLimit
  ) public {
    vm.assume(newLimit > vault.ownerOverrideTimelock());

    vm.prank(vaultOwner);
    vault.increaseOwnerOverrideTimelock(newLimit);
    assertEq(vault.ownerOverrideTimelock(), newLimit);
  }

  function testFuzzUpdateThreshold(
    uint256 newThreshold
  ) public {
    vm.assume(newThreshold > 0);
    vm.prank(vaultOwner);
    vault.updateSignatoryThreshold(newThreshold);
    assertEq(vault.signatoryThreshold(), newThreshold);
  }

  function testFuzzIncreaseTimelock(uint256 newTimelock, address signer1, address signer2, address executor) public {
    vm.assume(newTimelock > vault.multiSigTimelock());
    vm.assume(executor != address(0) && executor != vaultOwner);
    vm.assume(
      signer1 != address(0) && signer2 != address(0) && signer1 != signer2 && signer1 != vaultOwner
        && signer2 != vaultOwner && signer1 != executor && signer2 != executor
    );

    vm.prank(vaultOwner);
    vault.addSigner(signer1);
    vm.prank(vaultOwner);
    vault.addSigner(signer2);
    vm.prank(vaultOwner);
    vault.addExecutor(executor);
    vm.prank(vaultOwner);
    assertEq(vault.totalUsers(), 4);
    assertEq(vault.totalSigners(), 2);

    vm.prank(signer1);
    vault.initiateAction(ActionType.INCREASE_TIMELOCK, address(0), newTimelock);

    vm.prank(signer1);
    vault.approveAction(1);
    vm.prank(signer2);
    vault.approveAction(1);
    vm.prank(vaultOwner);
    vault.approveAction(1);

    skip(30 hours);
    vm.prank(vaultOwner);
    vault.executeAction(1);

    assertEq(vault.multiSigTimelock(), newTimelock);
  }

  function testFuzzInitiateApproveExecuteETHTransaction(
    address payable recipient,
    address signer1,
    address signer2,
    address executor,
    bytes memory data
  ) public {
    vm.assume(executor != address(0) && executor != vaultOwner);
    vm.assume(
      signer1 != address(0) && signer2 != address(0) && signer1 != signer2 && signer1 != vaultOwner
        && signer2 != vaultOwner && signer1 != executor && signer2 != executor
    );
    vm.assume(
      recipient != address(0) && recipient != vaultOwner && recipient != signer1 && recipient != signer2
        && recipient != executor && recipient != vaultAddress
    );

    vm.deal(vaultOwner, 100 ether);
    vm.prank(vaultOwner);
    Address.sendValue(payable(vaultAddress), 10 ether);
    uint256 initialRecipientBalance = recipient.balance;
    uint256 initialVaultBalance = vaultAddress.balance;

    vm.prank(vaultOwner);
    vault.addSigner(signer1);
    vm.prank(vaultOwner);
    vault.addSigner(signer2);
    vm.prank(vaultOwner);
    vault.addExecutor(executor);

    vm.prank(signer1);
    uint256 txValue = 3 ether;
    vault.initiateTransaction(recipient, address(0), txValue, data);
    assertEq(vault.totalTransactions(), 1);

    vm.prank(signer1);
    vault.approveTransaction(1);
    vm.prank(signer2);
    vault.approveTransaction(1);
    vm.prank(vaultOwner);
    vault.approveTransaction(1);

    skip(36 hours);

    vm.prank(executor);
    vault.executeTransaction(1);
    assertEq(vault.getBalance(), initialVaultBalance - txValue);
    assertEq(recipient.balance, initialRecipientBalance + txValue);
  }

  function testFuzzInitiateApproveExecuteERC20Transaction(
    address payable recipient,
    address signer1,
    address signer2,
    address executor,
    bytes memory data
  ) public {
    vm.assume(executor != address(0) && executor != vaultOwner);
    vm.assume(
      signer1 != address(0) && signer2 != address(0) && signer1 != signer2 && signer1 != vaultOwner
        && signer2 != vaultOwner && signer1 != executor && signer2 != executor
    );
    vm.assume(
      recipient != address(0) && recipient != vaultOwner && recipient != signer1 && recipient != signer2
        && recipient != executor && recipient != vaultAddress
    );

    IERC20 mockToken = IERC20(address(new MockERC20Token(vaultOwner)));
    address mockAddress = address(mockToken);

    vm.prank(vaultOwner);
    mockToken.approve(vaultAddress, 300 ether);
    vm.prank(vaultOwner);
    vault.depositToken(mockAddress, 300 ether);

    uint256 initialRecipientBalance = mockToken.balanceOf(recipient);
    uint256 initialVaultBalance = mockToken.balanceOf(vaultAddress);

    vm.prank(vaultOwner);
    vault.addSigner(signer1);
    vm.prank(vaultOwner);
    vault.addSigner(signer2);
    vm.prank(vaultOwner);
    vault.addExecutor(executor);

    vm.prank(signer1);
    uint256 txValue = 100 ether;
    vault.initiateTransaction(recipient, mockAddress, txValue, data);
    assertEq(vault.totalTransactions(), 1);

    vm.prank(signer1);
    vault.approveTransaction(1);
    vm.prank(signer2);
    vault.approveTransaction(1);
    vm.prank(vaultOwner);
    vault.approveTransaction(1);

    skip(36 hours);

    vm.prank(executor);
    vault.executeTransaction(1);
    assertEq(vault.getTokenBalance(mockAddress), initialVaultBalance - txValue);
    assertEq(mockToken.balanceOf(recipient), initialRecipientBalance + txValue);
  }
}
