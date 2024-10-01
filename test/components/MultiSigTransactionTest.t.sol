// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.27;

import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {Address} from '@openzeppelin/contracts/utils/Address.sol';
import {Transaction} from '../../src/utilities/VaultStructs.sol';
import {MockERC20Token} from '../mocks/MockERC20Token.sol';
import './BaseMultiSigTest.t.sol';

contract MultiSigTransactionTest is BaseMultiSigTest {
  IERC20 internal mockToken;
  address internal mockAddress;

  function setUp() public override {
    super.setUp();

    mockToken = IERC20(address(new MockERC20Token()));
    mockAddress = address(mockToken);

    deal(mockAddress, vaultAddress, 1000 ether);
    Address.sendValue(payable(vaultAddress), 10 ether);
  }

  function testContactBalance() public view {
    assertEq(vault.getBalance(), 10 ether);
    assertEq(vault.getTokenBalance(mockAddress), 1000 ether);
  }

  function testInitiateETHTransaction() public {
    vm.prank(firstSigner);
    bytes memory txData = '0x';
    uint256 txValue = 1 ether;
    address txReceiver = address(0x1234);
    vault.initiateTransaction(payable(txReceiver), address(0), txValue, txData);
    assertEq(vault.totalTransactions(), 1);

    vm.prank(vaultOwner);
    assertEq(vault.getTransactionApprovals(1), 0);

    vm.prank(secondSigner);
    Transaction memory txn = vault.getTransaction(1);
    assertEq(txn.initiator, firstSigner);
    assertEq(txn.target, txReceiver);
    assertEq(txn.token, address(0));
    assertEq(txn.value, txValue);
    assertFalse(txn.isExecuted);
    assertEq(txn.data, txData);
  }

  function testApproveAndExecuteETHTransaction() public {
    uint256 transactionValue = 1 ether;
    vm.prank(vaultOwner);
    vault.initiateTransaction(payable(address(0x1234)), address(0), transactionValue, '0x');

    // Approvals
    vm.prank(firstSigner);
    vault.approveTransaction(1);
    vm.prank(secondSigner);
    vault.approveTransaction(1);
    vm.prank(vaultOwner);
    vault.approveTransaction(1);

    // Execute
    vm.prank(vaultOwner);
    vault.executeTransaction(1);

    // Assert transaction executed
    assertEq(vault.getBalance(), 9 ether);
  }

  function testInitiateERC20Transaction() public {
    vm.prank(secondSigner);
    uint256 tokenAmount = 100 ether;
    vault.initiateTransaction(payable(address(0x1234)), mockAddress, tokenAmount, '0x');
    assertEq(vault.totalTransactions(), 1);

    vm.prank(firstSigner);
    Transaction memory txn = vault.getTransaction(1);
    assertEq(txn.initiator, secondSigner);
    assertEq(txn.token, mockAddress);
    assertEq(txn.value, tokenAmount);
  }

  function testApproveAndExecuteERC20Transaction() public {
    vm.prank(vaultOwner);
    uint256 tokenAmount = 100 ether;
    vault.initiateTransaction(payable(address(0x1234)), mockAddress, tokenAmount, '0x');

    vm.prank(firstSigner);
    vault.approveTransaction(1);
    vm.prank(secondSigner);
    vault.approveTransaction(1);
    vm.prank(vaultOwner);
    vault.approveTransaction(1);

    vm.prank(vaultExecutor);
    vault.executeTransaction(1);

    assertEq(mockToken.balanceOf(payable(address(0x1234))), tokenAmount);
    assertEq(vault.getTokenBalance(mockAddress), 900 ether);
  }

  function testRevokeApproval() public {
    vm.prank(firstSigner);
    vault.initiateTransaction(payable(address(0x1234)), address(0), 1 ether, '0x');

    vm.prank(firstSigner);
    vault.approveTransaction(1);
    vm.prank(firstSigner);
    assertEq(vault.getTransactionApprovals(1), 1);

    vm.prank(firstSigner);
    vault.revokeApproval(1);

    vm.prank(firstSigner);
    assertEq(vault.getTransactionApprovals(1), 0);
  }

  function testInsufficientApprovals() public {
    vm.prank(firstSigner);
    vault.initiateTransaction(payable(address(0x1234)), address(0), 1 ether, '0x');

    vm.prank(firstSigner);
    vault.approveTransaction(1);

    vm.prank(vaultExecutor);
    vm.expectRevert();
    vault.executeTransaction(1);
  }
}
