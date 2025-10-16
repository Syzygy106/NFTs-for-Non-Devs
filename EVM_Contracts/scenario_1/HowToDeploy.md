How to Deploy ClassicDrop (ERC-721A with ERC-2309 initial mint)

Prerequisites
- Install Foundry: https://book.getfoundry.sh/getting-started/installation
- Fund the deployer address with testnet ETH (or mainnet if applicable)

Install dependencies (if needed)
```
forge install OpenZeppelin/openzeppelin-contracts@v5.0.2
forge install chiru-labs/ERC721A@v4.2.3
```

Configure environment
Quick setup: export variables in your shell
Be sure to CHANGE NAME, SYMBOL, and INITIAL_SUPPLY to match your collection.
```
export RPC_URL=https://sepolia.infura.io/v3/YOUR_KEY
export PRIVATE_KEY=0xYOUR_PRIVATE_KEY

# CHANGE THESE ↓↓↓
export NAME=ClassicDrop
export SYMBOL=CDROP
export BASE_URI=ipfs://YOUR_META_CID/
export INITIAL_OWNER=0xYourOwnerAddress
export INITIAL_SUPPLY=3

# Optional (for verification)
export ETHERSCAN_API_KEY=your_key
```

One-shot inline (no persistent export)
Replace NAME, SYMBOL, INITIAL_SUPPLY (and other values) accordingly.
```
NAME=ClassicDrop SYMBOL=CDROP BASE_URI=ipfs://YOUR_META_CID/ \
INITIAL_OWNER=0xYourOwnerAddress INITIAL_SUPPLY=3 \
RPC_URL=https://sepolia.infura.io/v3/YOUR_KEY PRIVATE_KEY=0xYOUR_PRIVATE_KEY \
forge script script/Deploy.s.sol --rpc-url $RPC_URL --broadcast --private-key $PRIVATE_KEY
```

Alternative: use a .env file at the repo root
```
# RPC & broadcasting
RPC_URL=https://sepolia.infura.io/v3/YOUR_KEY
PRIVATE_KEY=0xYOUR_PRIVATE_KEY

# ClassicDrop constructor params
NAME=ClassicDrop
SYMBOL=CDROP
BASE_URI=ipfs://YOUR_META_CID/
INITIAL_OWNER=0xYourOwnerAddress
INITIAL_SUPPLY=3

# Optional (for verification)
ETHERSCAN_API_KEY=your_key
```

Build
```
forge build
```

Simulate (dry-run, no broadcast)
```
forge script script/Deploy.s.sol --rpc-url $RPC_URL
```

Deploy (broadcast)
```
forge script script/Deploy.s.sol \
  --rpc-url $RPC_URL \
  --broadcast \
  --private-key $PRIVATE_KEY
```

Optional: verify on Etherscan (example: Sepolia)
```
forge verify-contract \
  --chain sepolia \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  <DEPLOYED_ADDRESS> \
  src/ClassicDrop.sol:ClassicDrop
```

Notes
- `BASE_URI` must end with a trailing slash so `tokenURI` is `BASE_URI + tokenId`.
- `INITIAL_SUPPLY` must be > 0; the entire supply is minted in the constructor (ERC-2309 consecutive mint).
- `INITIAL_OWNER` receives the entire supply.
- After deploy, you can `setBaseURI` (until you call `freezeBaseURI`).

Parameter reference
- `NAME`: Human-readable collection name shown by wallets/marketplaces. Example: "My Art Collection".
- `SYMBOL`: Short ticker displayed by some UIs. Example: "ART".
- `BASE_URI`: Base path for metadata, usually an IPFS directory CID, must end with `/`.
- `INITIAL_OWNER`: Address that will immediately own the entire minted supply.
- `INITIAL_SUPPLY`: Total tokens minted at deployment via ERC-2309; choose the full collection size.
- `RPC_URL`: Endpoint for the target chain (Sepolia/Mainnet/etc.).
- `PRIVATE_KEY`: Deployer private key used for broadcasting.
- `ETHERSCAN_API_KEY` (optional): Used only for contract verification.

