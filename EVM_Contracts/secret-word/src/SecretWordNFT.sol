// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract SecretWordNFT is ERC721, Ownable {
    uint256 private _nextTokenId;
    string private _baseTokenURI;
    bytes32 public secretHash;

    constructor(string memory name_, string memory symbol_, string memory baseURI_, bytes32 secretHash_)
        ERC721(name_, symbol_)
        Ownable(msg.sender)
    {
        _baseTokenURI = baseURI_;
        secretHash = secretHash_;
    }

    function setBaseURI(string calldata newBaseURI) external onlyOwner {
        _baseTokenURI = newBaseURI;
    }

    function setSecretHash(bytes32 newHash) external onlyOwner {
        secretHash = newHash;
    }

    function mintWithSecret(string calldata secret) external returns (uint256 tokenId) {
        require(keccak256(bytes(secret)) == secretHash, "Wrong secret");
        tokenId = _nextTokenId;
        _nextTokenId = tokenId + 1;
        _safeMint(msg.sender, tokenId);
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }
}

