Lazy Mint (Signed Vouchers)

Idea

- Off-chain signer authorizes mints with a signed voucher. User submits voucher + signature to mint.

Install

```
forge install OpenZeppelin/openzeppelin-contracts@v5.0.2
```

Env

```
export LAZY_SIGNER=0xTRUSTED_SIGNER_ADDRESS
export RPC_URL=https://sepolia.infura.io/v3/YOUR_KEY
export PRIVATE_KEY=0xYOUR_PRIVATE_KEY
```

Build

```
forge build
```

Deploy

```
forge script script/Deploy.s.sol \
  --rpc-url $RPC_URL \
  --broadcast \
  --private-key $PRIVATE_KEY
```

Voucher Format (ABI-encoded before signing)

```
Voucher(address recipient,string tokenURI,uint256 nonce)
```

