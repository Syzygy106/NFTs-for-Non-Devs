# How to Deploy ClassicDrop

**ClassicDrop** is an ERC-721A contract with ERC-2309 batch minting that deploys your entire NFT collection in a single transaction.

---

## Prerequisites

1. **Install Foundry**  
   Follow the official guide: https://book.getfoundry.sh/getting-started/installation

2. **Fund your deployer wallet**  
   Get testnet ETH from a faucet (for Sepolia) or ensure you have mainnet ETH if deploying to production.

3. **Install dependencies** (if not already installed)
```bash
   forge install OpenZeppelin/openzeppelin-contracts@v5.0.2
   forge install chiru-labs/ERC721A@v4.2.3
```

---

## Configuration

You have three options for setting up your deployment parameters:

### Option 1: Export variables in your shell
```bash
export RPC_URL=https://sepolia.infura.io/v3/YOUR_KEY
export PRIVATE_KEY=0xYOUR_PRIVATE_KEY

# Collection parameters — CHANGE THESE ↓
export NAME="My NFT Collection"
export SYMBOL=MNFT
export BASE_URI=ipfs://YOUR_META_CID/
export INITIAL_SUPPLY=100

# Optional (for contract verification)
export ETHERSCAN_API_KEY=your_etherscan_api_key
```

### Option 2: Inline environment variables (no export)
```bash
NAME="My NFT Collection" \
SYMBOL=MNFT \
BASE_URI=ipfs://YOUR_META_CID/ \
INITIAL_SUPPLY=100 \
RPC_URL=https://sepolia.infura.io/v3/YOUR_KEY \
PRIVATE_KEY=0xYOUR_PRIVATE_KEY \
forge script script/Deploy.s.sol --rpc-url $RPC_URL --broadcast --private-key $PRIVATE_KEY
```

### Option 3: Use a `.env` file (recommended)

Create a `.env` file in the repository root:
```env
# Network & wallet
RPC_URL=https://sepolia.infura.io/v3/YOUR_KEY
PRIVATE_KEY=0xYOUR_PRIVATE_KEY

# Collection parameters
NAME=My NFT Collection
SYMBOL=MNFT
BASE_URI=ipfs://YOUR_META_CID/
INITIAL_SUPPLY=100

# Optional (for verification)
ETHERSCAN_API_KEY=your_etherscan_api_key
```

⚠️ **Security:** Never commit `.env` to version control. Ensure it's in `.gitignore`.

---

## Parameter Reference

| Parameter | Description | Example |
|-----------|-------------|---------|
| `NAME` | Human-readable collection name | `"Cosmic Cats"` |
| `SYMBOL` | Short ticker (3-5 chars) | `CATS` |
| `BASE_URI` | IPFS metadata directory CID (must end with `/`) | `ipfs://bafybei.../` |
| `INITIAL_SUPPLY` | Total NFTs to mint at deployment | `1000` |
| `RPC_URL` | Blockchain RPC endpoint | `https://sepolia.infura.io/v3/...` |
| `PRIVATE_KEY` | Deployer wallet private key | `0xabc123...` |
| `ETHERSCAN_API_KEY` | For contract verification (optional) | `ABC123XYZ` |

**Important notes:**
- `BASE_URI` **must end with a trailing slash** (`/`) so that `tokenURI(id)` resolves to `BASE_URI + tokenId`
- `INITIAL_SUPPLY` must be > 0 — the entire supply mints to the deployer in the constructor
- The deployer (`msg.sender`) receives all tokens initially

---

## Deployment Steps

### 1. Build the contract
```bash
forge build
```

### 2. Simulate deployment (dry-run, no gas spent)
```bash
forge script script/Deploy.s.sol --rpc-url $RPC_URL
```

Review the output to confirm parameters before broadcasting.

### 3. Deploy to blockchain
```bash
forge script script/Deploy.s.sol \
  --rpc-url $RPC_URL \
  --broadcast \
  --private-key $PRIVATE_KEY
```

**Expected output:**
- Transaction hash
- Deployed contract address
- Gas used

### 4. (Optional) Verify contract on block explorer

**Sepolia example:**
```bash
forge verify-contract \
  --chain sepolia \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  <DEPLOYED_CONTRACT_ADDRESS> \
  src/ClassicDrop.sol:ClassicDrop
```

**Or verify during deployment:**
```bash
forge script script/Deploy.s.sol \
  --rpc-url $RPC_URL \
  --broadcast \
  --private-key $PRIVATE_KEY \
  --verify \
  --etherscan-api-key $ETHERSCAN_API_KEY
```

---

## Example: Full Deployment

Here's a complete example deploying to Sepolia testnet:
```bash
# Set variables
export RPC_URL=https://magical-skilled-film.ethereum-sepolia.quiknode.pro/7a0c...2eb013/
export PRIVATE_KEY=0xYOUR_PRIVATE_KEY
export NAME="Classic Drop Demo"
export SYMBOL=CLD
export BASE_URI=ipfs://bafybeibqciccdwpic7fxotyudzk2xzpuihibnnmfyenauxfaedxrhwpfsm/
export INITIAL_SUPPLY=3
export ETHERSCAN_API_KEY=your_key

# Build
forge build

# Deploy
forge script script/Deploy.s.sol \
  --rpc-url $RPC_URL \
  --broadcast \
  --private-key $PRIVATE_KEY

# Verify (optional)
forge verify-contract \
  --chain sepolia \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  0xDEPLOYED_ADDRESS \
  src/ClassicDrop.sol:ClassicDrop
```

---

## Post-Deployment

After successful deployment:

1. **Save the contract address** — you'll need it for marketplace listings
2. **Test minting** — verify tokens appear correctly with metadata
3. **Update base URI** (if needed) — call `setBaseURI()` before freezing
4. **Freeze metadata** — call `freezeBaseURI()` to make it immutable
5. **List on marketplace** — create a collection page on OpenSea, Magic Eden, etc.

---

## Troubleshooting

**"Insufficient funds"**  
Ensure your deployer wallet has enough ETH for gas fees.

**"Invalid constructor arguments"**  
Check that `BASE_URI` ends with `/` and `INITIAL_SUPPLY` > 0.

**Verification fails**  
Make sure the deployed bytecode matches the source. Try adding `--constructor-args` if needed.

**Metadata not showing**  
Verify your IPFS CID is accessible and JSON files are properly formatted.

---

## Useful Commands
```bash
# Check Foundry version
forge --version

# Update dependencies
forge update

# Run tests (if available)
forge test

# Format code
forge fmt

# Get contract size
forge build --sizes
```