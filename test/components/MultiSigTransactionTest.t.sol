// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {Address} from '@openzeppelin/contracts/utils/Address.sol';
import {MockERC20Token} from '../mocks/MockERC20Token.sol';
import './BaseMultiSigTest.t.sol';

contract MultiSigTransactionTest is BaseMultiSigTest {
  IERC20 internal mockToken;
  address internal mockAddress;

  function setUp() public override {
    super.setUp();

    mockToken = IERC20(address(new MockERC20Token(vaultOwner)));
    mockAddress = address(mockToken);

    vm.prank(vaultOwner);
    mockToken.approve(vaultAddress, 300 ether);
    vm.prank(vaultOwner);
    vault.depositToken(mockAddress, 300 ether);
    vm.prank(vaultOwner);
    Address.sendValue(payable(vaultAddress), 10 ether);
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
    (
      address initiator,
      address to,
      address token,
      uint256 value,
      uint256 approvals,
      bool isExecuted,
      bool isOverride,
      bytes memory data
    ) = vault.getTransaction(1);
    assertEq(initiator, firstSigner);
    assertEq(to, txReceiver);
    assertEq(token, address(0));
    assertEq(value, txValue);
    assertEq(approvals, 0);
    assertFalse(isExecuted);
    assertFalse(isOverride);
    assertEq(data, txData);
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

    // Fast forward time to simulate passing the timelock period
    skip(2 days);
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
    (address initiator,, address token, uint256 value,,,,) = vault.getTransaction(1);
    assertEq(initiator, secondSigner);
    assertEq(token, mockAddress);
    assertEq(value, tokenAmount);
  }

  function testApproveAndExecuteERC20Transaction() public {
    vm.prank(vaultOwner);
    uint256 tokenAmount = 100 ether;
    vault.initiateTransaction(payable(address(0x1234)), mockAddress, tokenAmount, '0x');

    vm.prank(secondSigner);
    vault.approveTransaction(1);
    vm.prank(vaultOwner);
    vault.approveTransaction(1);

    // Fast forward time to simulate passing the timelock period for executor override
    skip(2 days);

    vm.prank(vaultExecutor);
    vault.executeTransaction(1);

    bool isOverride;
    uint256 approvals;
    vm.prank(vaultExecutor);
    (,,,, approvals,, isOverride,) = vault.getTransaction(1);
    assertTrue(isOverride);
    assertEq(approvals, 2);
    assertEq(mockToken.balanceOf(payable(address(0x1234))), tokenAmount);
    assertEq(vault.getTokenBalance(mockAddress), 200 ether);
  }

  function testRevokeApproval() public {
    vm.prank(firstSigner);
    vault.initiateTransaction(payable(address(0x1234)), address(0), 1 ether, '0x');

    vm.prank(firstSigner);
    vault.approveTransaction(1);
    vm.prank(firstSigner);
    assertEq(vault.getTransactionApprovals(1), 1);

    vm.prank(firstSigner);
    vault.revokeTransactionApproval(1);

    vm.prank(firstSigner);
    assertEq(vault.getTransactionApprovals(1), 0);
  }

  function testInsufficientTransactionApprovals() public {
    vm.prank(firstSigner);
    vault.initiateTransaction(payable(address(0x1234)), address(0), 1 ether, '0x');

    vm.prank(firstSigner);
    vault.approveTransaction(1);

    skip(2 days);

    vm.prank(vaultOwner);
    vm.expectRevert();
    vault.executeTransaction(1);
  }
}
