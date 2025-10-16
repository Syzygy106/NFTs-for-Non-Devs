Demo assets for NFTs.

- Place images in assets/images
- Place metadata JSON in assets/metadata
- Define traits in attributes.csv (optional)

What this is
- These are demo/placeholder assets and metadata templates to help you get started.
- You must update metadata after you upload your images and license to IPFS.
- You should also modify assets/LICENSE to reflect your actual license terms.

File naming and mapping
- Image files and metadata files are zero-padded to match token IDs.
  - Example: tokenId 0 → `assets/images/0000.PNG` and `assets/metadata/0000.json`
  - tokenId 1 → `0001.PNG` and `0001.json`, etc.
- Keep the same file extension in the metadata `image` URI (case-sensitive on some systems).

IPFS workflow
1) Upload images folder to IPFS. Record the resulting images CID (IMAGES_CID).
   - Example URI format: `ipfs://IMAGES_CID/0000.PNG`
   - Gateway example: `https://ipfs.io/ipfs/IMAGES_CID/0000.PNG`
2) Upload your license text/file to IPFS (optional but recommended). Record LICENSE_CID.
3) Upload the metadata folder to IPFS only after you update each file with correct URIs. Record METADATA_CID if you upload the folder as a directory.
4) Many ERC-721 contracts use a baseURI. Set `baseURI = ipfs://METADATA_CID/` so that tokenId 0 resolves to `ipfs://METADATA_CID/0000.json`.

Minimum metadata example (ERC-721 compatible)
```json
{
  "name": "My NFT #0000",
  "description": "Short description of the NFT.",
  "image": "ipfs://IMAGES_CID/0000.PNG",
  "attributes": []
}
```

Fuller metadata example with license fields
```json
{
  "name": "My NFT #0000",
  "description": "Detailed description. You can include collection info here.",
  "image": "ipfs://IMAGES_CID/0000.PNG",
  "external_url": "https://example.com/nft/0",
  "animation_url": null,
  "background_color": "000000",
  "attributes": [
    { "trait_type": "Background", "value": "Blue" },
    { "trait_type": "Eyes", "value": "Laser" }
  ],
  "license": "CC BY 4.0",
  "license_url": "https://creativecommons.org/licenses/by/4.0/",
  "license_ipfs": "ipfs://LICENSE_CID/LICENSE"
}
```

How to update your metadata
- Replace `IMAGES_CID` with the actual images folder CID from your IPFS upload.
- Replace `LICENSE_CID` with the CID of your license file (if you uploaded it).
- Ensure each `image` field points to the correct filename, e.g., `0007.PNG` for tokenId 7.
- If you prefer using a gateway URL instead of the `ipfs://` scheme, set `image` to a gateway link (e.g., `https://ipfs.io/ipfs/IMAGES_CID/0000.PNG`).
- If you change your license from the default CC BY 4.0, update `assets/LICENSE` and the `license`/`license_url`/`license_ipfs` fields accordingly.

Notes on attributes
- `attributes` is an array of objects used by marketplaces for filtering and display.
- Typical shape: `{ "trait_type": "Background", "value": "Blue" }`
- You can also include `display_type` for special rendering (e.g., `number`, `boost_percentage`).

Checklist before minting
- Images uploaded to IPFS and CIDs recorded.
- License uploaded to IPFS (optional) and CIDs recorded.
- All metadata files updated with correct `image` and license fields.
- Metadata folder uploaded to IPFS; baseURI set to `ipfs://METADATA_CID/` in your contract (if applicable).
- `assets/LICENSE` edited to match your actual license.
