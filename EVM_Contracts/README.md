NFT Contracts Starter Kit

This folder contains multiple Foundry-ready NFT contract templates covering common business cases:

- Vanilla ERC721 (OpenZeppelin)
- ERC721A (gas-efficient batch minting)
- Lazy Minting (off-chain signed vouchers)
- Secret Word Minting (simple on-chain secret check)

Each subproject is self-contained with:

- `foundry.toml`
- `src/` contracts
- `script/Deploy.s.sol` for deployment
- `README.md` with copy-paste commands
- `.env.example` you can copy to `.env`

Prerequisites

- Foundry installed (`forge`, `cast`). See Foundry book.
- A funded deployer wallet private key on your target network (e.g., Sepolia).

Quick Start (example flow)

1. Pick a template, e.g., `vanilla-erc721`.
2. Enter the project folder and install dependencies:
   - `forge install OpenZeppelin/openzeppelin-contracts@v5.0.2`
   - If using ERC721A: `forge install chiru-labs/ERC721A@v4.2.3`
3. Copy `.env.example` to `.env` and fill `PRIVATE_KEY` and `RPC_URL`.
4. Build: `forge build`
5. Deploy:
   - `forge script script/Deploy.s.sol --rpc-url $RPC_URL --broadcast --private-key $PRIVATE_KEY`

Projects

- `vanilla-erc721`: Minimal OpenZeppelin ERC721 with owner minting to arbitrary recipients and token URIs.
- `erc721a`: ERC721A basic minter that supports efficient batch mints.
- `lazy-mint`: Redeem pre-signed vouchers from a trusted signer (no upfront mint cost).
- `secret-word`: Users can mint by providing a secret phrase hashed on-chain.

Notes

- These templates are educational starting points. Review, audit, and adjust for production needs (royalties, metadata, access control, supply limits, pricing, etc.).
- Default Solidity version is 0.8.24 in each subproject; adjust if needed.

