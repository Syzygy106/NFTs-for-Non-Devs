Secret Word Minting

Idea

- Users mint by providing the correct secret phrase. Contract stores only the hash.

Install

```
forge install OpenZeppelin/openzeppelin-contracts@v5.0.2
```

Env

```
export SECRET_HASH=$(cast keccak "banana")
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

