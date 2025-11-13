// How to Deploy Mystery Box NFT

A comprehensive guide to deploying and managing a Mystery Box NFT collection with whitelist, time-limited minting, and provenance proof.

---

## 📋 Prerequisites

### Install Foundry
Follow the official guide: https://book.getfoundry.sh/getting-started/installation

### Install Node.js (required for scripts)
We use Node.js scripts for whitelist/proofs and provenance. Install Node.js (LTS):
https://nodejs.org/en/download

Then install script dependencies:
```bash
cd scripts && npm install && cd ..
```

### 2. Install Dependencies (Foundry)
Install Solidity libraries used by this scenario:
```bash
# OpenZeppelin Contracts v5
forge install OpenZeppelin/openzeppelin-contracts@v5.0.2

# ERC721A (Azuki)
forge install chiru-labs/ERC721A@v4.2.3

# Murky (Merkle tree utils for tests)
forge install dmfxyz/murky
```

If dependencies are already present, you can update them via:
```bash
forge update
```

### 3. Get Funds
- Recommended for testing on marketplaces: fund your wallet with **MATIC on Polygon (mainnet)** — low fees and fully supported by OpenSea.
- For Ethereum mainnet: fund with **ETH** (higher fees).

### 4. Get RPC URL
Use a public RPC (no API key required):
- [PublicNode](https://publicnode.com/) — reliable public endpoints.

Example RPC URLs:
```
# Polygon mainnet (recommended for testing/listing)
https://polygon-rpc.publicnode.com
# Ethereum mainnet
https://ethereum.publicnode.com
```
---

## 🎨 Step 1: Prepare Your Collection

Use the repo's `assets/` folder and follow its short guide:
- Images: `assets/images/` (zero‑padded filenames: `0000.PNG`, `0001.PNG`, ...).
- Metadata: `assets/metadata/` (one JSON per tokenId).
- Full tips: see `assets/README.md`.

### Mystery Box Metadata
Create a single `mystery.json` file for the unrevealed state. All tokens will show this before reveal:

```json
{
  "name": "Mystery Box",
  "description": "This NFT is currently unrevealed. Wait for the collection reveal to discover what's inside!",
  "image": "ipfs://QmYourMysteryImage/box.png",
  "attributes": [
    {
      "trait_type": "Status",
      "value": "Unrevealed"
    }
  ]
}
```

Upload this file to IPFS and save the full path (e.g., `ipfs://QmXXX/mystery.json`).

### What you need:
1. **Mystery Box Image**: Create one "closed box" image → upload to IPFS
2. **Mystery Box Metadata**: Create `mystery.json` (example above) → upload to IPFS → save URI for `MYSTERY_BOX_URI`
3. **Collection Images**: Upload `assets/images/` to IPFS → save `IMAGES_CID` (used in individual metadata files)
4. **Collection Metadata**: Upload `assets/metadata/` to IPFS → save `METADATA_CID` for reveal (`REVEALED_BASE_URI=ipfs://METADATA_CID/`)

**Important**: 
- `MYSTERY_BOX_URI` = full path to file (`ipfs://QmXXX/mystery.json`)
- `REVEALED_BASE_URI` = directory path with trailing slash (`ipfs://QmYYY/`)

---

## 🔐 Step 2: Generate Provenance Hash

The provenance hash proves you won't manipulate the collection after sale.

### Using Node.js (reads from assets/metadata by default)

Run it from scenario_2/:
```bash
node scripts/generateProvenance.js
```
---

## 👥 Step 3: Create Whitelist

### Collect Addresses
Create a file `whitelist.txt` with one address per line:
```
0x1234567890123456789012345678901234567890
0xabcdefabcdefabcdefabcdefabcdefabcdefabcd
0x...
```

Note: A starter whitelist template is provided at `scripts/whitelist.txt`. You can edit that file directly and run the generation step below without creating a new file.

### Generate Merkle Root

#### Method 1: Using JavaScript

Install dependencies and run from scenario_2/:
```bash
cd scripts && npm install && cd ..
node scripts/generateWhitelist.js
```

#### Method 2: Using Online Tool
Use [OpenZeppelin Merkle Tree Generator](https://github.com/OpenZeppelin/merkle-tree) or similar tools.

---

## ⚙️ Step 4: Configure Deployment

### Create `.env` File
In the `scenario_2` directory, create `.env`:

```bash
# Network Configuration
RPC_URL=https://polygon-rpc.publicnode.com
PRIVATE_KEY=0xYOUR_PRIVATE_KEY_HERE

# Collection Configuration
NAME="Mystery Box Collection"
SYMBOL=MBC

# URIs
MYSTERY_BOX_URI=ipfs://Qm.../mystery.json
REVEALED_BASE_URI=ipfs://Qm.../

# Supply & Pricing
MAX_SUPPLY=1000
MINT_PRICE=100000000000000000
MAX_PER_WALLET=5

# Time Configuration (Unix timestamps)
BUY_PERIOD_START=1700000000
BUY_PERIOD_END=1700604800

# Security
PROVENANCE_HASH=0xYOUR_PROVENANCE_HASH
WHITELIST_MERKLE_ROOT=0xYOUR_WHITELIST_ROOT

# Optional (for verification)
ETHERSCAN_API_KEY=YOUR_ETHERSCAN_API_KEY
```

### Calculate Timestamps
Use [Epoch Converter](https://www.epochconverter.com/) or:

```bash
# Current time
date +%s

# Specific date (macOS/Linux)
date -j -f "%Y-%m-%d %H:%M:%S" "2024-12-01 12:00:00" +%s
```

### Calculate Wei Amount
For MINT_PRICE:
```bash
# 0.1 ETH = 100000000000000000 wei
# 0.05 ETH = 50000000000000000 wei
# 1 ETH = 1000000000000000000 wei
```

Or use:
```bash
cast to-wei 0.1 ether
# Output: 100000000000000000
```

---

## 🚀 Step 5: Deploy Contract

### Build
```bash
forge build
```

Expected output:
```
Compiling...
Compiler run successful
```

### Simulate Deployment (Dry Run)
```bash
forge script script/Deploy.s.sol \
  --rpc-url $RPC_URL
```

Review the output carefully. Check all parameters.

### Deploy to Polygon (recommended for marketplace testing)
```bash
export RPC_URL=https://polygon-rpc.publicnode.com

forge script script/Deploy.s.sol \
  --rpc-url $RPC_URL \
  --broadcast \
  --private-key $PRIVATE_KEY
```

Save the contract address from the output. You can list and test your collection on OpenSea with low fees.

Add it to your `.env` for later scripts:
```env
CONTRACT=0xYOUR_CONTRACT_ADDRESS
```

### Deploy to Ethereum Mainnet (optional)
```bash
export RPC_URL=https://ethereum.publicnode.com

forge script script/Deploy.s.sol \
  --rpc-url $RPC_URL \
  --broadcast \
  --private-key $PRIVATE_KEY
```

---

## ✅ Step 6: Verify Contract

### Option 1: During Deployment (Polygon)
Add `--verify` with an Etherscan API key (one key works across Etherscan-powered explorers, including Polygon):
```bash
forge script script/Deploy.s.sol \
  --rpc-url $RPC_URL \
  --broadcast \
  --private-key $PRIVATE_KEY \
  --verify \
  --etherscan-api-key $ETHERSCAN_API_KEY
```

### Option 2: After Deployment (Polygon)
```bash
forge verify-contract \
  --chain polygon \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  0xYOUR_CONTRACT_ADDRESS \
  src/MysteryBoxNFT.sol:MysteryBoxNFT \
  --constructor-args $(cast abi-encode \
    "constructor(string,string,string,bytes32,bytes32,uint256,uint256,uint256,uint256,uint256)" \
    "$NAME" "$SYMBOL" "$MYSTERY_BOX_URI" "$PROVENANCE_HASH" \
    "$WHITELIST_MERKLE_ROOT" "$MAX_SUPPLY" "$MINT_PRICE" \
    "$MAX_PER_WALLET" "$BUY_PERIOD_START" "$BUY_PERIOD_END")
```

---

## 🎮 Step 7: User Minting (During Buy Period)

### Generate Merkle Proof for User

Usage:
```bash
node scripts/generateProof.js 0x1234567890123456789012345678901234567890
```

### Mint Using Foundry Script (recommended)
We include a Foundry script that reads the proof JSON file and sends the correct ETH based on `MINT_PRICE`. Ensure `CONTRACT` is set in `.env`.

```bash
# From scenario_2/
export QUANTITY=1
export PROOF_FILE=scripts/proof_XXXXXX.json   # generated by scripts/generateProof.js

forge script script/Mint.s.sol \
  --rpc-url $RPC_URL \
  --broadcast \
  --private-key $USER_PRIVATE_KEY \
  -vvvv
```

Proof file format (generated by `scripts/generateProof.js`):
```json
{
  "address": "0xYOUR_ADDRESS",
  "proof": ["0xabc...", "0xdef..."]
}
```

---

## 🎁 Step 8: Reveal Collection

### After Buy Period Ends
Use the Foundry script (make sure `.env` has `CONTRACT` and `REVEALED_BASE_URI`, e.g. `ipfs://METADATA_CID/`):
```bash
forge script script/Reveal.s.sol \
  --rpc-url $RPC_URL \
  --broadcast \
  --private-key $PRIVATE_KEY
```

### Verify Reveal
```bash
cast call $CONTRACT \
  "isRevealed()(bool)" \
  --rpc-url $RPC_URL
# Should return: true

# Check a token URI
cast call $CONTRACT \
  "tokenURI(uint256)(string)" \
  0 \
  --rpc-url $RPC_URL
# Should return: ipfs://METADATA_CID/0000.json
```

---

## 💰 Step 9: Withdraw Funds

```bash
forge script script/Withdraw.s.sol \
  --rpc-url $RPC_URL \
  --broadcast \
  --private-key $PRIVATE_KEY
```

Verify balance:
```bash
cast balance $YOUR_WALLET_ADDRESS --rpc-url $RPC_URL
```

---

## 📊 Useful Commands

### Check Contract State
```bash
# Total minted
cast call $CONTRACT \
  "totalSupply()(uint256)" \
  --rpc-url $RPC_URL

# Max supply
cast call $CONTRACT \
  "MAX_SUPPLY()(uint256)" \
  --rpc-url $RPC_URL

# Mint stats
cast call $CONTRACT \
  "getMintStats()(uint256,uint256,uint256,uint256,bool)" \
  --rpc-url $RPC_URL

# Is revealed
cast call $CONTRACT \
  "isRevealed()(bool)" \
  --rpc-url $RPC_URL

# Provenance hash
cast call $CONTRACT \
  "PROVENANCE_HASH()(bytes32)" \
  --rpc-url $RPC_URL
```

### Check User State
```bash
# User's minted count
cast call $CONTRACT \
  "mintedPerWallet(address)(uint256)" \
  $USER_ADDRESS \
  --rpc-url $RPC_URL

# User's balance
cast call $CONTRACT \
  "balanceOf(address)(uint256)" \
  $USER_ADDRESS \
  --rpc-url $RPC_URL
```

---

## 🐛 Troubleshooting

### Error: "BuyPeriodNotStarted"
- Check current time: `date +%s`
- Verify `BUY_PERIOD_START` timestamp
- Wait until period starts

### Error: "BuyPeriodEnded"
- Minting period has closed
- Only owner can reveal now

### Error: "NotWhitelisted"
- Check address is in whitelist
- Verify Merkle proof is correct
- Ensure proof matches current whitelist root

### Error: "InsufficientPayment"
- Send at least `MINT_PRICE * quantity` wei
- Check: `cast call $CONTRACT "MINT_PRICE()(uint256)"`

### Error: "WalletLimitExceeded"
- User has already minted `MAX_PER_WALLET` NFTs
- Check: `cast call $CONTRACT "mintedPerWallet(address)(uint256)" $USER`

### Error: "MaxSupplyExceeded"
- Collection is sold out
- Check: `cast call $CONTRACT "totalSupply()(uint256)"`

### Verification Failed
- Ensure constructor args are in correct order
- Use `cast abi-encode` to generate args
- Check Solidity version matches (0.8.24)

---

## 📋 Deployment Checklist

- [ ] Collection metadata created and uploaded to IPFS
- [ ] Mystery box metadata created and uploaded
- [ ] Provenance hash calculated and saved
- [ ] Whitelist created and Merkle root calculated
- [ ] `.env` file configured with correct values
- [ ] Timestamps are correct (future start, start < end)
- [ ] Price is in wei (use `cast to-wei`)
- [ ] Test with a small initial run on Polygon (low fees)
- [ ] Verify contract on block explorer
- [ ] Test minting with whitelisted address
- [ ] Test reveal after buy period
- [ ] Document contract address and parameters
- [ ] **Only then:** Deploy to mainnet

---

## 🎉 Post-Launch

### Publish Information
Share with your community:
- Contract address
- Provenance hash (for verification)
- Buy period start/end times
- Price and max per wallet
- Instructions for generating Merkle proofs

### Create Frontend
Consider creating a minting UI with:
- Wallet connection (WalletConnect, MetaMask)
- Whitelist check
- Merkle proof generation
- Minting interface
- Countdown timer
- Supply tracker

### Monitor
- Watch for minting activity on Etherscan
- Track total supply
- Be ready to reveal after buy period

### List on Marketplaces
- OpenSea: Will auto-detect verified contracts
- Magic Eden: Submit collection
- LooksRare: Create collection page

---

## ⚠️ Security Reminders

1. **Never share private keys**
2. **Test on testnet first**
3. **Verify all parameters before mainnet deployment**
4. **Keep provenance hash and metadata backups**
5. **Document everything for your community**
6. **Consider multisig for owner functions on mainnet**

---

## 📚 Additional Resources

- [Foundry Book](https://book.getfoundry.sh/)
- [Cast Reference](https://book.getfoundry.sh/reference/cast/)
- [Merkle Trees Explained](https://medium.com/@ItsCuzzo/using-merkle-trees-for-nft-whitelists-523b58ada3f9)
- [IPFS Documentation](https://docs.ipfs.tech/)
- [Etherscan Verification Guide](https://docs.etherscan.io/tutorials/verifying-contracts-programmatically)

---

**Ready to launch your mystery box collection? Follow this guide step-by-step and you'll be live in no time!** 🚀

