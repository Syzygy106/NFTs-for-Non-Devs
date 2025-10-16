// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract LazyMintNFT is ERC721, Ownable {
    using MessageHashUtils for bytes32;

    uint256 private _nextTokenId;
    string private _baseTokenURI;
    address public trustedSigner;

    struct Voucher {
        address recipient;
        string tokenURI;
        uint256 nonce;
    }

    mapping(uint256 => bool) public nonceUsed;

    constructor(
        string memory name_,
        string memory symbol_,
        string memory baseURI_,
        address trustedSigner_
    ) ERC721(name_, symbol_) Ownable(msg.sender) {
        _baseTokenURI = baseURI_;
        trustedSigner = trustedSigner_;
    }

    function setTrustedSigner(address newSigner) external onlyOwner {
        trustedSigner = newSigner;
    }

    function setBaseURI(string calldata newBaseURI) external onlyOwner {
        _baseTokenURI = newBaseURI;
    }

    function redeem(Voucher calldata voucher, bytes calldata signature) external returns (uint256 tokenId) {
        require(voucher.recipient == msg.sender, "Not recipient");
        require(!nonceUsed[voucher.nonce], "Nonce used");

        bytes32 digest = keccak256(abi.encode(
            keccak256("Voucher(address recipient,string tokenURI,uint256 nonce)"),
            voucher.recipient,
            keccak256(bytes(voucher.tokenURI)),
            voucher.nonce
        )).toEthSignedMessageHash();

        address signer = ECDSA.recover(digest, signature);
        require(signer == trustedSigner, "Bad signature");

        nonceUsed[voucher.nonce] = true;

        tokenId = _nextTokenId;
        _nextTokenId = tokenId + 1;
        _safeMint(voucher.recipient, tokenId);
        emit PermanentURI(voucher.tokenURI, tokenId);
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    event PermanentURI(string value, uint256 indexed id);
}

