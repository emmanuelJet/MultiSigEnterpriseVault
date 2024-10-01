# MultiSigEnterpriseVault

An open-source, enterprise-grade Multi-Signature Vault smart contract developed using Solidity and Foundry. It provides advanced security, customizable timelocks, and role-based access control for managing digital assets.

## Features

- Multi-signature functionality with flexible threshold settings.
- Separate timelocks for transactions and owner overrides.
- Role-based access control (Owner, Executor, Signers).
- Secure self-destruct mechanism with safety checks.

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
