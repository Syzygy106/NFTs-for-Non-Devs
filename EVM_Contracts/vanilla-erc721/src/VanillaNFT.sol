// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract VanillaNFT is ERC721, Ownable {
    uint256 private _nextTokenId;
    string private _baseTokenURI;

    constructor(string memory name_, string memory symbol_, string memory baseURI_)
        ERC721(name_, symbol_)
        Ownable(msg.sender)
    {
        _baseTokenURI = baseURI_;
    }

    function setBaseURI(string calldata newBaseURI) external onlyOwner {
        _baseTokenURI = newBaseURI;
    }

    function mintTo(address recipient) external onlyOwner returns (uint256 tokenId) {
        tokenId = _nextTokenId;
        _nextTokenId = tokenId + 1;
        _safeMint(recipient, tokenId);
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }
}

