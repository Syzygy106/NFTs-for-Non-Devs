Vanilla ERC721 (OpenZeppelin)

What you get

- Minimal ERC721 with owner-only mint and base token URI.
- Works with OpenZeppelin Contracts v5.

Install

1) Install dependencies

```
forge install OpenZeppelin/openzeppelin-contracts@v5.0.2
```

2) Set env variables

```
export RPC_URL=https://sepolia.infura.io/v3/YOUR_KEY
export PRIVATE_KEY=0xYOUR_PRIVATE_KEY
```

3) Build

```
forge build
```

Deploy

Ensure `PRIVATE_KEY` and `RPC_URL` are set in your shell.

```
forge script script/Deploy.s.sol \
  --rpc-url $RPC_URL \
  --broadcast \
  --private-key $PRIVATE_KEY
```

Contract

- Edit name/symbol/baseURI in `script/Deploy.s.sol` args.

