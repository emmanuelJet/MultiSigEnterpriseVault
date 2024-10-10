// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

/// @dev Role identifier for the Owner role in bytes32
bytes32 constant OWNER_ROLE = keccak256('RoleType.OWNER');

/// @dev Role identifier for the Signer role in bytes32
bytes32 constant SIGNER_ROLE = keccak256('RoleType.SIGNER');

/// @dev Role identifier for the Executor role in bytes32
bytes32 constant EXECUTOR_ROLE = keccak256('RoleType.EXECUTOR');
