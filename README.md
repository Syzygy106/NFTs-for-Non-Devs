## NFT Starter Kit: Meaning and Overview

This repository is a practical, copy‑paste friendly starter kit for launching common NFT business cases using Foundry. It is designed for non‑developers (artists, small businesses) and for developers who want ready‑to‑use, production‑style templates with tests and one‑command deploy scripts.

### Who this is for
- Creators who want to compare minting strategies and deploy fast
- Teams who need clean, minimal contract templates with tests and scripts

### What’s included
- A folder of self‑contained Foundry projects under `NFT_Contracts/`, each with:
  - Contracts (`src/`), deploy scripts (`script/Deploy.s.sol`), tests (`test/`), `foundry.toml`, and a step‑by‑step `README.md`
- Four business cases you can pick from:
  - Vanilla ERC721 (OpenZeppelin)
  - ERC721A (gas‑efficient batch minting)
  - Lazy Minting (off‑chain signed vouchers, on‑demand mint)
  - Secret Word Minting (simple on‑chain secret check)

See details and exact commands in `NFT_Contracts/README.md` and in each subproject’s README.

### How to use
1) Choose a template in `NFT_Contracts/` (e.g., `vanilla-erc721`).
2) Install dependencies (example):
```
forge install foundry-rs/forge-std@v1.9.5 OpenZeppelin/openzeppelin-contracts@v5.0.2
```
3) Set environment variables (example):
```
export RPC_URL=https://sepolia.infura.io/v3/YOUR_KEY
export PRIVATE_KEY=0xYOUR_PRIVATE_KEY
```
4) Build & test:
```
forge build
forge test
```
5) Deploy (from the chosen subproject folder):
```
forge script script/Deploy.s.sol --rpc-url $RPC_URL --broadcast --private-key $PRIVATE_KEY
```

Notes
- These templates are a starting point. Review and adapt (royalties, metadata hosting, access control, supply limits, pricing, etc.).
- All templates compile under Solidity 0.8.24 and use OpenZeppelin v5 APIs.

## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
