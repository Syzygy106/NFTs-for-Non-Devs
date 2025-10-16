// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC721A} from "erc721a/contracts/ERC721A.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title Classic one-shot ERC721A collection with ERC-2309 initial mint
/// @dev Mints the entire supply in the constructor using _mintERC2309.
///      No post-deploy minting is exposed.
contract ClassicDrop is ERC721A, Ownable {
    string private _baseTokenURI;
    bool public baseURIFrozen;

    /// @param name_  Collection name
    /// @param symbol_ Collection symbol
    /// @param baseURI_ Base URI, e.g. ipfs://<CID_META>/
    /// @param initialOwner Owner address (receives the whole supply)
    /// @param initialSupply Total number of tokens to mint at deployment
    constructor(
        string memory name_,
        string memory symbol_,
        string memory baseURI_,
        address initialOwner,
        uint256 initialSupply
    ) ERC721A(name_, symbol_) Ownable(initialOwner) {
        require(initialOwner != address(0), "invalid owner");
        require(initialSupply > 0, "invalid supply");

        _baseTokenURI = baseURI_;

        // ERC-2309: one ConsecutiveTransfer log for the entire range.
        // Per the standard, this can be used only in the constructor.
        _mintERC2309(initialOwner, initialSupply);
    }

    /* ===================== Owner-only admin ===================== */

    /// @notice Update baseURI (e.g. if you re-upload metadata)
    function setBaseURI(string calldata newBaseURI) external onlyOwner {
        require(!baseURIFrozen, "baseURI is frozen");
        _baseTokenURI = newBaseURI;
    }

    /// @notice Make baseURI immutable
    function freezeBaseURI() external onlyOwner {
        baseURIFrozen = true;
    }

    /* ===================== Views / internals ===================== */

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    // Optional: if you want tokenId to start from 1 instead of 0
    // function _startTokenId() internal pure override returns (uint256) {
    //     return 1;
    // }
}


