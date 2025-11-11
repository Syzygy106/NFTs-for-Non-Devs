// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC721A} from "erc721a/contracts/ERC721A.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/// @title Mystery Box NFT with Whitelist, Time-Limited Minting, and Provenance
/// @notice Users mint mystery boxes during buy period, owner reveals collection later
/// @dev Combines ERC721A with Merkle whitelist, time locks, and provenance hash
contract MysteryBoxNFT is ERC721A, Ownable {
    /* ===================== IMMUTABLE CONFIG ===================== */
    
    /// @notice Maximum number of NFTs that can ever exist
    uint256 public immutable MAX_SUPPLY;
    
    /// @notice Price per NFT in wei
    uint256 public immutable MINT_PRICE;
    
    /// @notice Maximum NFTs per wallet during buy period
    uint256 public immutable MAX_PER_WALLET;
    
    /// @notice Unix timestamp when minting starts
    uint256 public immutable BUY_PERIOD_START;
    
    /// @notice Unix timestamp when minting ends
    uint256 public immutable BUY_PERIOD_END;
    
    /// @notice Provenance hash of the full collection (Merkle root of final metadata)
    /// @dev Set before minting starts to prove no post-sale manipulation
    bytes32 public immutable PROVENANCE_HASH;

    /* ===================== STATE VARIABLES ===================== */
    
    /// @notice Merkle root for whitelist verification
    bytes32 public whitelistMerkleRoot;
    
    /// @notice URI for mystery box (before reveal)
    string private _mysteryBoxURI;
    
    /// @notice Base URI for revealed collection
    string private _revealedBaseURI;
    
    /// @notice Whether collection has been revealed
    bool public isRevealed;
    
    /// @notice Tracks number of NFTs minted per wallet
    mapping(address => uint256) public mintedPerWallet;

    /* ===================== EVENTS ===================== */
    
    event Minted(address indexed minter, uint256 quantity, uint256 totalMinted);
    event Revealed(string revealedBaseURI);
    event WhitelistUpdated(bytes32 newMerkleRoot);

    /* ===================== ERRORS ===================== */
    
    error BuyPeriodNotStarted();
    error BuyPeriodEnded();
    error MaxSupplyExceeded();
    error WalletLimitExceeded();
    error NotWhitelisted();
    error InsufficientPayment();
    error WithdrawFailed();
    error AlreadyRevealed();

    /* ===================== CONSTRUCTOR ===================== */

    /// @param name_ Collection name
    /// @param symbol_ Collection symbol
    /// @param mysteryBoxURI_ URI for unrevealed mystery box (e.g., ipfs://QmMysteryBox)
    /// @param provenanceHash_ Merkle root of final collection metadata (set before sale)
    /// @param whitelistRoot_ Merkle root for whitelist
    /// @param maxSupply_ Maximum collection size
    /// @param mintPrice_ Price per NFT in wei
    /// @param maxPerWallet_ Max NFTs per wallet
    /// @param startTime_ Buy period start (unix timestamp)
    /// @param endTime_ Buy period end (unix timestamp)
    constructor(
        string memory name_,
        string memory symbol_,
        string memory mysteryBoxURI_,
        bytes32 provenanceHash_,
        bytes32 whitelistRoot_,
        uint256 maxSupply_,
        uint256 mintPrice_,
        uint256 maxPerWallet_,
        uint256 startTime_,
        uint256 endTime_
    ) ERC721A(name_, symbol_) Ownable(msg.sender) {
        require(maxSupply_ > 0, "Invalid max supply");
        require(maxPerWallet_ > 0, "Invalid max per wallet");
        require(startTime_ < endTime_, "Invalid time range");
        require(endTime_ > block.timestamp, "End time must be in future");
        
        _mysteryBoxURI = mysteryBoxURI_;
        PROVENANCE_HASH = provenanceHash_;
        whitelistMerkleRoot = whitelistRoot_;
        MAX_SUPPLY = maxSupply_;
        MINT_PRICE = mintPrice_;
        MAX_PER_WALLET = maxPerWallet_;
        BUY_PERIOD_START = startTime_;
        BUY_PERIOD_END = endTime_;
    }

    /* ===================== PUBLIC MINT ===================== */

    /// @notice Mint NFTs during buy period with whitelist proof
    /// @param quantity Number of NFTs to mint
    /// @param merkleProof Proof that msg.sender is whitelisted
    function mint(uint256 quantity, bytes32[] calldata merkleProof) external payable {
        // Check buy period
        if (block.timestamp < BUY_PERIOD_START) revert BuyPeriodNotStarted();
        if (block.timestamp > BUY_PERIOD_END) revert BuyPeriodEnded();
        
        // Check supply limits
        if (_totalMinted() + quantity > MAX_SUPPLY) revert MaxSupplyExceeded();
        
        // Check per-wallet limit
        if (mintedPerWallet[msg.sender] + quantity > MAX_PER_WALLET) {
            revert WalletLimitExceeded();
        }
        
        // Verify whitelist
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        if (!MerkleProof.verify(merkleProof, whitelistMerkleRoot, leaf)) {
            revert NotWhitelisted();
        }
        
        // Check payment
        if (msg.value < MINT_PRICE * quantity) revert InsufficientPayment();
        
        // Update state and mint
        mintedPerWallet[msg.sender] += quantity;
        _mint(msg.sender, quantity);
        
        emit Minted(msg.sender, quantity, _totalMinted());
        
        // Refund excess payment
        if (msg.value > MINT_PRICE * quantity) {
            (bool success, ) = msg.sender.call{value: msg.value - MINT_PRICE * quantity}("");
            require(success, "Refund failed");
        }
    }

    /* ===================== OWNER FUNCTIONS ===================== */

    /// @notice Reveal the collection by setting the real base URI
    /// @dev Can only be called once, after buy period ends
    /// @param revealedBaseURI_ Base URI for revealed collection (e.g., ipfs://QmRevealed/)
    function reveal(string calldata revealedBaseURI_) external onlyOwner {
        if (isRevealed) revert AlreadyRevealed();
        require(block.timestamp > BUY_PERIOD_END, "Buy period not ended");
        
        _revealedBaseURI = revealedBaseURI_;
        isRevealed = true;
        
        emit Revealed(revealedBaseURI_);
    }

    /// @notice Update whitelist Merkle root (before buy period starts)
    function setWhitelistMerkleRoot(bytes32 newRoot) external onlyOwner {
        require(block.timestamp < BUY_PERIOD_START, "Cannot change after start");
        whitelistMerkleRoot = newRoot;
        emit WhitelistUpdated(newRoot);
    }

    /// @notice Update mystery box URI before reveal
    function setMysteryBoxURI(string calldata newURI) external onlyOwner {
        require(!isRevealed, "Already revealed");
        _mysteryBoxURI = newURI;
    }

    /// @notice Withdraw contract balance to owner
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        (bool success, ) = owner().call{value: balance}("");
        if (!success) revert WithdrawFailed();
    }

    /* ===================== VIEW FUNCTIONS ===================== */

    /// @inheritdoc ERC721A
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();
        
        // Before reveal: all tokens show mystery box
        if (!isRevealed) {
            return _mysteryBoxURI;
        }
        
        // After reveal: show actual metadata with padding
        return string(abi.encodePacked(_revealedBaseURI, _toPaddedString(tokenId, 4), ".json"));
    }

    /// @notice Get current mint statistics
    function getMintStats() external view returns (
        uint256 totalMinted,
        uint256 maxSupply,
        uint256 remainingSupply,
        uint256 currentPrice,
        bool mintActive
    ) {
        totalMinted = _totalMinted();
        maxSupply = MAX_SUPPLY;
        remainingSupply = MAX_SUPPLY - totalMinted;
        currentPrice = MINT_PRICE;
        mintActive = block.timestamp >= BUY_PERIOD_START && 
                     block.timestamp <= BUY_PERIOD_END &&
                     totalMinted < MAX_SUPPLY;
    }

    /* ===================== INTERNAL HELPERS ===================== */

    /// @dev Converts uint to zero-padded string
    function _toPaddedString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory raw = bytes(_toString(value));
        if (raw.length >= length) return string(raw);
        
        bytes memory zeros = new bytes(length - raw.length);
        for (uint256 i = 0; i < zeros.length; i++) {
            zeros[i] = "0";
        }
        return string(abi.encodePacked(zeros, raw));
    }
}

