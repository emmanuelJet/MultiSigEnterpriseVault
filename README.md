# MultiSigEnterpriseVault

[![Solidity](https://img.shields.io/badge/Solidity-363636.svg?logo=solidity&logoColor=white)](https://soliditylang.org)
[![Foundry Framework](https://custom-icon-badges.demolab.com/badge/Foundry-E8E8E8.svg?logo=foundry)](https://getfoundry.sh)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
![Build Status](https://github.com/emmanuelJet/MultiSigEnterpriseVault/actions/workflows/ci.yml/badge.svg?branch=main)

An open-source, enterprise-grade Multi-Signature Vault smart contract developed using Solidity and Foundry. It provides advanced security, customizable timelocks, and role-based access control for managing digital assets.

## Features

- Multi-Signature Vault functionality to manage **ETH** and **ERC20** tokens.
- Separate timelocks for transactions and owner overrides with delays.
- Role-based access control (Owner, Executor, Signers).
- Flexible and administrative threshold settings.
- Designed to be secure and gas-efficient.

## Use Cases

The MultiSigEnterpriseVault is ideal for:

- **Enterprise Teams**: Organizations that require multiple approvals before executing high-value transactions, ensuring decentralized control.
- **DAOs (Decentralised Autonomous Organizations)**: Enables decentralized decision-making with threshold-based approvals for critical actions.
- **Family or Joint Accounts**: Multiple signatories can manage shared assets securely with transaction approval mechanisms.
- **Fund Custodians**: Securely manage pooled funds with transaction timelock to prevent unilateral decisions.

## Getting Started

- Clone the repository:

```bash
git clone https://github.com/emmanuelJet/MultiSigEnterpriseVault.git
cd MultiSigEnterpriseVault
```

- Install dependencies:

```bash
forge install
```

- Run the compiler command:

```bash
forge build
```

- Run the test command:

```bash
forge test
```

- Run the gas-snapshot command:

```bash
forge snapshot
```

## Flatten Contracts for Verification

To flatten the contract for verification (e.g., on [Remix IDE](https://remix.ethereum.org/)), run the flatten command:

```bash
forge flatten ./src/MultiSigEnterpriseVault.sol > ./.private/MultiSigEnterpriseVault.sol
```

This command outputs a single Solidity file containing all dependencies.

## Deployment Guide

This section explains how to deploy the MultiSigEnterpriseVault contract to PulseChain Testnet v4 using GitHub Actions.

### Prerequisites

Set the following environment variables:

- `PRIVATE_KEY`: The deployer’s private key (set as a GitHub secret).
- `PULSECHAIN_TESTNET_RPC_URL`: RPC URL for PulseChain Testnet.
- `OWNER_ADDRESS`: The contract owner’s address.
- `INITIAL_THRESHOLD`: The initial threshold for signatory approval.
- `INITIAL_MULTISIG_TIMELOCK`: Time delay for multisig approvals.
- `INITIAL_OWNEROVEREIDE_TIMELOCK`: Time delay for owner override.

### Deployment Steps

1. Navigate to the **Actions** tab in the repository.
2. Find the **CI** workflow and click **Run workflow**.
3. Select the **main** branch and trigger deployment.

### Deployment Artifacts

After a successful deployment, artifacts will be stored in the `dist/` directory:

- `deployment_abi.json`: Contains the contract ABI.
- `deployment_result.txt`: Contains the contract address and deployment transaction details.

## Local Deployment

- Create the `.env` file from the `.env.example` file and fill in the environment variables;

```bash
cp .env.example .env
```

- Load the variables in the `.env` file;

```bash
source .env
```

- Deploy `MultiSigEnterpriseVault` contract using `forge script`

```bash
forge script script/MultiSigEnterpriseVaultScript.s.sol:MultiSigEnterpriseVaultScript --chain pulsechain-testnet --private-key $PRIVATE_KEY --rpc-url $PULSECHAIN_TESTNET_RPC_URL --broadcast --verify --verifier blockscout --verifier-url https://api.scan.v4.testnet.pulsechain.com/api/ | tee .private/deployment_result.txt
```

## Contribution

I welcome contributions to this project. If you’re interested in contributing, please check the [Contribution Guidelines](CONTRIBUTING.md) for detailed instructions.

## Code of Conduct

Please read the [Code of Conduct](CODE_OF_CONDUCT.md) to understand the rules and expectations for participation in the project.

## License

```md
Copyright (C) 2024  Emmanuel Joseph <hello@emmanueljet.com> (https://emmanueljet.com)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
```

## Disclaimer

**This project has not been audited and is not recommended for production use.** Use this code at your own risk. The project maintainer takes no responsibility for any losses or issues that arise from using the code in a live environment.
