// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.27;

import {ActionType} from '../../src/utilities/VaultEnums.sol';
import './BaseMultiSigTest.t.sol';

contract MultiSigTimelockTest is BaseMultiSigTest {
  function testInitiateAndVerifyIncreaseTimelockAction() public {
    vm.prank(firstSigner);
    uint256 executionTimestamp = block.timestamp;
    vault.initiateAction(ActionType.INCREASE_TIMELOCK, address(0), 2 days);

    vm.prank(firstSigner);
    assertEq(vault.totalActions(), 1);

    vm.prank(firstSigner);
    (
      address initiator,
      ActionType actionType,
      address target,
      uint256 value,
      uint256 timestamp,
      uint256 approvals,
      bool isExecuted,
      bool isOverride
    ) = vault.getAction(1);
    assertEq(initiator, firstSigner);
    assertTrue(actionType == ActionType.INCREASE_TIMELOCK);
    assertEq(target, address(0));
    assertEq(value, 2 days);
    assertEq(timestamp, executionTimestamp);
    assertEq(approvals, 0);
    assertFalse(isExecuted);
    assertFalse(isOverride);
  }

  function testInitiateInvalidActions() public {
    vm.prank(firstSigner);
    vm.expectRevert();
    vault.initiateAction(ActionType.ADD_SIGNER, address(0), 0);

    vm.prank(firstSigner);
    vm.expectRevert();
    vault.initiateAction(ActionType.ADD_SIGNER, secondSigner, 0);

    vm.prank(firstSigner);
    vm.expectRevert();
    vault.initiateAction(ActionType.REMOVE_SIGNER, makeAddr('newSigner'), 0);

    vm.prank(secondSigner);
    vm.expectRevert();
    vault.initiateAction(ActionType.INCREASE_TIMELOCK, address(0), 3 hours);

    vm.prank(secondSigner);
    vm.expectRevert();
    vault.initiateAction(ActionType.DECREASE_TIMELOCK, address(0), 3 days);

    vm.prank(vaultOwner);
    vm.expectRevert();
    vault.initiateAction(ActionType.INCREASE_THRESHOLD, address(0), 2);

    vm.prank(vaultOwner);
    vm.expectRevert();
    vault.initiateAction(ActionType.DECREASE_THRESHOLD, address(0), 5);
  }

  function testCannotInitiateInvalidAction() public {
    vm.prank(vaultOwner);
    vm.expectRevert();
    vault.initiateAction(ActionType.INVALID, address(0), 0);
  }

  function testCannotInitiateTwoPendingActions() public {
    vm.prank(firstSigner);
    vault.initiateAction(ActionType.ADD_SIGNER, makeAddr('newSigner'), 0);
    vm.prank(firstSigner);
    assertEq(vault.totalActions(), 1);

    vm.prank(secondSigner);
    vm.expectRevert();
    vault.initiateAction(ActionType.INCREASE_TIMELOCK, address(0), 30 hours);
  }

  function testCannotRetrieveInvalidAction() public {
    vm.prank(firstSigner);
    vault.initiateAction(ActionType.ADD_SIGNER, makeAddr('newSigner'), 0);
    vm.prank(firstSigner);
    assertEq(vault.totalActions(), 1);

    vm.prank(firstSigner);
    vm.expectRevert();
    vault.getAction(2);
  }

  function testDeletePendingAction() public {
    address newSigner = makeAddr('newSigner');
    vm.prank(firstSigner);
    vault.initiateAction(ActionType.ADD_SIGNER, newSigner, 0);
    vm.prank(firstSigner);
    assertEq(vault.totalActions(), 1);
    vm.prank(firstSigner);
    (,, address target,,,,,) = vault.getAction(1);
    assertEq(target, newSigner);

    vm.prank(vaultExecutor);
    vault.deletePendingAction();

    vm.prank(vaultExecutor);
    assertEq(vault.totalActions(), 0);
  }

  function testRevokeActionApproval() public {
    vm.prank(firstSigner);
    vault.initiateAction(ActionType.ADD_SIGNER, makeAddr('newSigner'), 0);
    vm.prank(firstSigner);
    assertEq(vault.getActionApprovals(1), 0);

    // Approve the action
    vm.prank(firstSigner);
    vault.approveAction(1);
    vm.prank(firstSigner);
    assertEq(vault.getActionApprovals(1), 1);

    // Revoke approval
    vm.prank(firstSigner);
    vault.revokeActionApproval(1);

    // Check the approval count after revocation
    vm.prank(firstSigner);
    assertEq(vault.getActionApprovals(1), 0);
  }

  function testCannotApproveActionTwice() public {
    vm.prank(firstSigner);
    vault.initiateAction(ActionType.ADD_SIGNER, makeAddr('newSigner'), 0);
    vm.prank(firstSigner);
    assertEq(vault.getActionApprovals(1), 0);

    vm.prank(firstSigner);
    vault.approveAction(1);
    vm.prank(firstSigner);
    assertEq(vault.getActionApprovals(1), 1);

    vm.prank(firstSigner);
    vm.expectRevert();
    vault.approveAction(1);
  }

  function testInsufficientActionApprovals() public {
    vm.prank(firstSigner);
    vault.initiateAction(ActionType.DECREASE_TIMELOCK, address(0), 12 hours);

    vm.prank(firstSigner);
    vault.approveAction(1);
    vm.prank(secondSigner);
    vault.approveAction(1);

    vm.warp(block.timestamp + vault.multiSigTimelock());

    vm.prank(vaultOwner);
    vm.expectRevert();
    vault.executeAction(1);
  }

  function testApproveAndExecuteAction() public {
    vm.prank(firstSigner);
    uint256 newTimelock = 30 hours;
    vault.initiateAction(ActionType.INCREASE_TIMELOCK, address(0), newTimelock);

    // Signer approvals
    vm.prank(firstSigner);
    vault.approveAction(1);
    vm.prank(secondSigner);
    vault.approveAction(1);
    vm.prank(vaultOwner);
    vault.approveAction(1);
    vm.prank(vaultExecutor);
    assertEq(vault.getActionApprovals(1), 3);
    vm.prank(vaultExecutor);
    assertEq(vault.getActionSignatures(1).length, 3);

    // Simulate time elapse for timelock
    skip(36 hours);

    // Execute action
    vm.prank(vaultExecutor);
    vault.executeAction(1);

    assertEq(vault.multiSigTimelock(), newTimelock);
  }
}
