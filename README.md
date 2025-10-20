# NFT Business Cases Starter Kit

A practical, production-ready collection of NFT smart contract templates built with Foundry. Each template represents a complete business case with contracts, tests, deployment scripts, and step-by-step guides.

---

## 🎯 Who This Is For

- **Creators & Artists** — Deploy your NFT collection without writing code from scratch
- **Small Teams** — Get production-ready templates with built-in best practices
- **Developers** — Skip boilerplate and start with tested, documented patterns
- **Educators** — Compare different minting strategies side-by-side

---

## 📦 What's Inside

This repository contains **multiple self-contained Foundry projects**, each representing a distinct NFT business case. Every scenario includes:

- ✅ **Smart contracts** (`src/`) — Clean, minimal, auditable code
- ✅ **Deploy scripts** (`script/Deploy.s.sol`) — One-command deployment
- ✅ **Tests** (`test/`) — Full test coverage
- ✅ **Documentation** (per-scenario `HowToDeploy.md`) — Step-by-step deployment guide
- ✅ **Configuration** (`foundry.toml`) — Pre-configured for EVM networks

All contracts use **Solidity 0.8.24** and **OpenZeppelin v5** APIs.

---

## 🗂️ Available Scenarios

Browse the `EVM_Contracts/` folder for complete implementations:

### 📌 Scenario 1: Classic Drop (ERC-721A + Batch Mint)
**Path:** `EVM_Contracts/scenario_1/`

**Use case:** Mint your entire collection upfront, then list on marketplaces (OpenSea, Magic Eden, etc.)

**Tech stack:**
- ERC-721A (gas-efficient batch minting)
- ERC-2309 (consecutive transfer event)
- Batch mint entire supply in constructor
- Owner-controlled metadata with freeze mechanism

**Best for:** Traditional PFP collections, art drops, merch NFTs

**[→ Full deployment guide](EVM_Contracts/scenario_1/HowToDeploy.md)**

---

### 🔜 Coming Soon

- **Scenario 2:** Public Mint with Merkle Whitelist
- **Scenario 3:** Lazy Minting (off-chain vouchers)
- **Scenario 4:** Dutch Auction
- **Scenario 5:** Bonding Curve Minting
- **Scenario 6:** Secret Word Minting

---

## 🚀 Getting Started

### Prerequisites

1. **Install Foundry**  
```bash
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
```
   Full guide: https://book.getfoundry.sh/getting-started/installation

2. **Get testnet ETH**  
   Use a faucet for Sepolia or your chosen testnet

### Choose Your Scenario

Each scenario is **fully self-contained** and includes its own detailed deployment guide:

1. Navigate to the scenario folder (e.g., `EVM_Contracts/scenario_1/`)
2. Open `HowToDeploy.md` inside for complete step-by-step instructions
3. Follow the configuration, build, test, and deployment steps

**Example:**
```bash
cd EVM_Contracts/scenario_1
cat HowToDeploy.md  # Read the full guide
```

Each scenario's README covers:
- Prerequisites and dependencies
- Configuration options (environment variables, `.env` file, inline parameters)
- Build and test commands
- Deployment instructions
- Post-deployment steps (verification, marketplace listing)
- Troubleshooting tips

---

## 📖 How to Use This Repository

### Option 1: Copy a Single Scenario

Each scenario folder is **fully self-contained**. You can:
```bash
# Copy just the scenario you need
cp -r scenarios/scenario_1_classic_drop my-nft-project
cd my-nft-project

# It works independently
forge build
forge test
```

### Option 2: Explore & Compare

Keep the full repo and navigate between scenarios to compare approaches:
```bash
# Compare gas costs
cd scenarios/scenario_1_classic_drop && forge test --gas-report
cd ../scenario_2_merkle_mint && forge test --gas-report

# Compare deployment complexity
diff scenario_1_classic_drop/script/Deploy.s.sol scenario_3_lazy_mint/script/Deploy.s.sol
```

### Option 3: Build Your Own Hybrid

Mix features from different scenarios:

- Take batch minting from Scenario 1
- Add whitelist logic from Scenario 2
- Combine with royalty setup from Scenario 3

---

## 🛠️ Common Tasks

### Build contracts
```bash
forge build
```

### Run tests
```bash
forge test

# With gas report
forge test --gas-report

# Verbose output
forge test -vvv
```

### Deploy to testnet
```bash
forge script script/Deploy.s.sol \
  --rpc-url $RPC_URL \
  --broadcast \
  --private-key $PRIVATE_KEY
```

### Verify contract
```bash
forge verify-contract \
  --chain sepolia \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  <CONTRACT_ADDRESS> \
  src/YourContract.sol:YourContract
```

### Format code
```bash
forge fmt
```

### Local development node
```bash
anvil
```

---

## 🌐 Supported Networks

All scenarios support any EVM-compatible network. Common choices:

| Network | Use Case | RPC Examples |
|---------|----------|--------------|
| **Ethereum Mainnet** | High-value collections | Infura, Alchemy, QuickNode |
| **Polygon** | Low-cost minting | `https://polygon-rpc.com` |
| **Base** | Coinbase ecosystem | `https://mainnet.base.org` |
| **Arbitrum** | L2 scaling | `https://arb1.arbitrum.io/rpc` |
| **Optimism** | L2 scaling | `https://mainnet.optimism.io` |
| **Sepolia (testnet)** | Testing | Infura, Alchemy |

---

## 📚 Resources

### Foundry Documentation
- **Foundry Book:** https://book.getfoundry.sh/
- **Forge Commands:** https://book.getfoundry.sh/reference/forge/
- **Cast (CLI Tools):** https://book.getfoundry.sh/reference/cast/

### NFT Standards & Marketplaces
- **ERC-721 Standard:** https://eips.ethereum.org/EIPS/eip-721
- **ERC-721A (Azuki):** https://www.erc721a.org/
- **OpenSea Metadata:** https://docs.opensea.io/docs/metadata-standards
- **ERC-2981 Royalties:** https://eips.ethereum.org/EIPS/eip-2981

### Testing & Development
- **Remix IDE:** https://remix.ethereum.org/
- **Tenderly (Debugger):** https://tenderly.co/
- **Etherscan (Explorer):** https://etherscan.io/

---

## 🤝 Contributing

Found a bug? Have a scenario suggestion? Contributions are welcome!

1. Fork the repo
2. Create a feature branch (`git checkout -b feature/new-scenario`)
3. Add tests and documentation
4. Submit a pull request

**Guidelines:**
- Each scenario must be self-contained (own README, tests, deploy script)
- Use OpenZeppelin v5 where possible
- Include gas benchmarks in tests
- Document all deployment parameters

---

## ⚠️ Disclaimer

**This repository is provided for educational purposes only.**

- The code is provided "as is" without warranty of any kind, express or implied
- We are not responsible for any loss of funds, damages, or other consequences arising from the use of these contracts
- These templates are **not audited** and should not be used in production without thorough review and testing
- Always conduct your own security audit before deploying to mainnet
- Users are solely responsible for compliance with applicable laws and regulations in their jurisdiction
- The use of smart contracts involves inherent risks, including but not limited to loss of funds due to bugs, vulnerabilities, or user error

**By using this code, you acknowledge and accept these risks.**

---

## 📄 License

This project is free and open-source.

You are free to use, modify, and distribute this code for any purpose, commercial or non-commercial, without restriction.

---

## 🆘 Support

- **Issues:** Open a GitHub issue for bugs or questions
- **Discussions:** Use GitHub Discussions for general questions
- **Documentation:** Each scenario has its own detailed README with full deployment instructions

---

**Ready to launch your NFT collection?** Pick a scenario, read its README, and start building! 🚀