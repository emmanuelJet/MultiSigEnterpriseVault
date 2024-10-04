// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.27;

import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {Address} from '@openzeppelin/contracts/utils/Address.sol';
import {ActionType} from '../../src/utilities/VaultEnums.sol';
import {MockERC20Token} from '../mocks/MockERC20Token.sol';
import './BaseMultiSigTest.t.sol';

contract MultiSigFuzzTest is BaseMultiSigTest {
  function testFuzzUpdateExecutor(
    address newExecutor
  ) public {
    vm.assume(
      newExecutor != address(0) && newExecutor != vaultOwner && newExecutor != vaultExecutor
        && newExecutor != vaultAddress && newExecutor != firstSigner && newExecutor != secondSigner
    );

    assertEq(vault.executor(), vaultExecutor);

    vm.prank(vaultOwner);
    vault.updateExecutor(newExecutor);
    assertEq(vault.executor(), newExecutor);
  }

  function testFuzzIncreaseOwnerOverrideTimelock(
    uint256 newLimit
  ) public {
    vm.assume(newLimit > vault.ownerOverrideTimelock());

    vm.prank(vaultOwner);
    vault.increaseOwnerOverrideTimelock(newLimit);
    assertEq(vault.ownerOverrideTimelock(), newLimit);
  }

  function testFuzzIncreaseTimelock(
    uint256 newTimelock
  ) public {
    vm.assume(newTimelock > vault.multiSigTimelock());

    vm.prank(firstSigner);
    vault.initiateAction(ActionType.INCREASE_TIMELOCK, address(0), newTimelock);

    vm.prank(firstSigner);
    vault.approveAction(1);
    vm.prank(secondSigner);
    vault.approveAction(1);
    vm.prank(vaultOwner);
    vault.approveAction(1);

    skip(30 hours);
    vm.prank(vaultOwner);
    vault.executeAction(1);

    assertEq(vault.multiSigTimelock(), newTimelock);
  }

  function testFuzzInitiateApproveExecuteETHTransaction(address payable recipient, bytes memory data) public {
    vm.assume(
      recipient != address(0) && recipient != vaultOwner && recipient != firstSigner && recipient != secondSigner
        && recipient != vaultExecutor && recipient != vaultAddress
    );

    vm.deal(vaultOwner, 100 ether);
    vm.prank(vaultOwner);
    Address.sendValue(payable(vaultAddress), 10 ether);
    uint256 initialRecipientBalance = recipient.balance;
    uint256 initialVaultBalance = vaultAddress.balance;

    vm.prank(firstSigner);
    uint256 txValue = 3 ether;
    vault.initiateTransaction(recipient, address(0), txValue, data);
    assertEq(vault.totalTransactions(), 1);

    vm.prank(firstSigner);
    vault.approveTransaction(1);
    vm.prank(secondSigner);
    vault.approveTransaction(1);
    vm.prank(vaultOwner);
    vault.approveTransaction(1);

    skip(36 hours);

    vm.prank(vaultExecutor);
    vault.executeTransaction(1);
    assertEq(vault.getBalance(), initialVaultBalance - txValue);
    assertEq(recipient.balance, initialRecipientBalance + txValue);
  }

  function testFuzzInitiateApproveExecuteERC20Transaction(address payable recipient, bytes memory data) public {
    vm.assume(
      recipient != address(0) && recipient != vaultOwner && recipient != firstSigner && recipient != secondSigner
        && recipient != vaultExecutor && recipient != vaultAddress
    );

    IERC20 mockToken = IERC20(address(new MockERC20Token(vaultOwner)));
    address mockAddress = address(mockToken);

    vm.prank(vaultOwner);
    mockToken.approve(vaultAddress, 300 ether);
    vm.prank(vaultOwner);
    vault.depositToken(mockAddress, 300 ether);

    uint256 initialRecipientBalance = mockToken.balanceOf(recipient);
    uint256 initialVaultBalance = mockToken.balanceOf(vaultAddress);

    vm.prank(firstSigner);
    uint256 txValue = 100 ether;
    vault.initiateTransaction(recipient, mockAddress, txValue, data);
    assertEq(vault.totalTransactions(), 1);

    vm.prank(firstSigner);
    vault.approveTransaction(1);
    vm.prank(secondSigner);
    vault.approveTransaction(1);
    vm.prank(vaultOwner);
    vault.approveTransaction(1);

    skip(36 hours);

    vm.prank(vaultExecutor);
    vault.executeTransaction(1);
    assertEq(vault.getTokenBalance(mockAddress), initialVaultBalance - txValue);
    assertEq(mockToken.balanceOf(recipient), initialRecipientBalance + txValue);
  }
}
