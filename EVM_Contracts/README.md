NFT Contracts Starter Kit

This folder contains multiple Foundry-ready NFT contract templates covering common business cases:

- **Scenario 1**: Classic Drop (ERC721A + ERC2309 consecutive mint)
- **Scenario 2**: Mystery Box NFT (whitelist, time-limited, provenance, reveal mechanism)

Each subproject is self-contained with:

- `foundry.toml`
- `src/` contracts
- `script/Deploy.s.sol` for deployment
- `HowToDeploy.md` with copy-paste commands
- `.env.example` you can copy to `.env` (or export env vars inline)

Prerequisites

- **Foundry** installed (`forge`, `cast`). See https://book.getfoundry.sh/getting-started/installation
- **Node.js** (for scenario_2 helper scripts). See https://nodejs.org/
- A funded deployer wallet with private key on your target network (Polygon recommended for testing).

Quick Start (example flow)

1. Pick a scenario, e.g., `scenario_1` (Classic Drop) or `scenario_2` (Mystery Box).
2. Enter the project folder and install dependencies:
   ```bash
   cd scenario_1  # or scenario_2
   forge install OpenZeppelin/openzeppelin-contracts@v5.0.2
   forge install chiru-labs/ERC721A@v4.2.3
   ```
   For `scenario_2`, also install Node.js dependencies for helper scripts:
   ```bash
   cd scripts && npm install && cd ..
   ```
3. Configure deployment by creating `.env` file (see each scenario's `env.example`).
4. Build: `forge build`
5. Test: `forge test --offline -vv`
6. Deploy:
   ```bash
   forge script script/Deploy.s.sol --rpc-url $RPC_URL --broadcast --private-key $PRIVATE_KEY
   ```

Available Scenarios

- **`scenario_1`**: Classic Drop using ERC721A with ERC-2309 consecutive mint; entire supply minted in constructor. Perfect for traditional PFP collections and art drops. See `scenario_1/HowToDeploy.md`.
  
- **`scenario_2`**: Mystery Box NFT with Merkle whitelist, time-limited buy period, mystery box reveal mechanics, and provenance hash verification. Includes Foundry scripts (Deploy/Mint/Reveal/Withdraw) and Node.js helpers (whitelist/proof/provenance generation). Full test coverage (23 tests). See `scenario_2/HowToDeploy.md`.

Notes

- These templates are educational starting points. Review, audit, and adjust for production needs (royalties, metadata, access control, supply limits, pricing, etc.).
- Default Solidity version is 0.8.24 in each subproject; adjust if needed.

