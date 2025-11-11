// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {MysteryBoxNFT} from "../src/MysteryBoxNFT.sol";
import {Merkle} from "murky/Merkle.sol";

contract MysteryBoxNFTTest is Test {
    MysteryBoxNFT private nft;
    Merkle private merkle;

    address private owner;
    address private alice;
    address private bob;
    address private charlie;

    uint256 constant MAX_SUPPLY = 100;
    uint256 constant MINT_PRICE = 0.1 ether;
    uint256 constant MAX_PER_WALLET = 5;
    
    uint256 startTime;
    uint256 endTime;
    
    bytes32 provenanceHash = keccak256("PROVENANCE");
    bytes32 whitelistRoot;
    bytes32[] proof;

    function setUp() public {
        owner = makeAddr("owner");
        alice = makeAddr("alice");
        bob = makeAddr("bob");
        charlie = makeAddr("charlie");

        // Setup Merkle tree for whitelist
        merkle = new Merkle();
        bytes32[] memory leaves = new bytes32[](3);
        leaves[0] = keccak256(abi.encodePacked(alice));
        leaves[1] = keccak256(abi.encodePacked(bob));
        leaves[2] = keccak256(abi.encodePacked(charlie));
        whitelistRoot = merkle.getRoot(leaves);

        // Set time periods: starts in 1 hour, ends in 1 week
        startTime = block.timestamp + 1 hours;
        endTime = startTime + 7 days;

        vm.prank(owner);
        nft = new MysteryBoxNFT(
            "Mystery Box Collection",
            "MBC",
            "ipfs://mystery-box-uri",
            provenanceHash,
            whitelistRoot,
            MAX_SUPPLY,
            MINT_PRICE,
            MAX_PER_WALLET,
            startTime,
            endTime
        );

        // Fund test accounts
        vm.deal(alice, 10 ether);
        vm.deal(bob, 10 ether);
        vm.deal(charlie, 10 ether);
    }

    /* ===================== DEPLOYMENT TESTS ===================== */

    function testDeploymentParameters() public {
        assertEq(nft.MAX_SUPPLY(), MAX_SUPPLY);
        assertEq(nft.MINT_PRICE(), MINT_PRICE);
        assertEq(nft.MAX_PER_WALLET(), MAX_PER_WALLET);
        assertEq(nft.BUY_PERIOD_START(), startTime);
        assertEq(nft.BUY_PERIOD_END(), endTime);
        assertEq(nft.PROVENANCE_HASH(), provenanceHash);
        assertEq(nft.whitelistMerkleRoot(), whitelistRoot);
        assertFalse(nft.isRevealed());
    }

    /* ===================== MINT TESTS ===================== */

    function testMintDuringBuyPeriod() public {
        // Warp to buy period
        vm.warp(startTime + 1);

        // Get proof for alice
        bytes32[] memory leaves = new bytes32[](3);
        leaves[0] = keccak256(abi.encodePacked(alice));
        leaves[1] = keccak256(abi.encodePacked(bob));
        leaves[2] = keccak256(abi.encodePacked(charlie));
        proof = merkle.getProof(leaves, 0); // alice is index 0

        vm.prank(alice);
        nft.mint{value: MINT_PRICE * 2}(2, proof);

        assertEq(nft.balanceOf(alice), 2);
        assertEq(nft.mintedPerWallet(alice), 2);
        assertEq(nft.ownerOf(0), alice);
        assertEq(nft.ownerOf(1), alice);
    }

    function testMintFailsBeforeBuyPeriod() public {
        bytes32[] memory leaves = new bytes32[](3);
        leaves[0] = keccak256(abi.encodePacked(alice));
        leaves[1] = keccak256(abi.encodePacked(bob));
        leaves[2] = keccak256(abi.encodePacked(charlie));
        proof = merkle.getProof(leaves, 0);

        vm.prank(alice);
        vm.expectRevert(MysteryBoxNFT.BuyPeriodNotStarted.selector);
        nft.mint{value: MINT_PRICE}(1, proof);
    }

    function testMintFailsAfterBuyPeriod() public {
        vm.warp(endTime + 1);

        bytes32[] memory leaves = new bytes32[](3);
        leaves[0] = keccak256(abi.encodePacked(alice));
        leaves[1] = keccak256(abi.encodePacked(bob));
        leaves[2] = keccak256(abi.encodePacked(charlie));
        proof = merkle.getProof(leaves, 0);

        vm.prank(alice);
        vm.expectRevert(MysteryBoxNFT.BuyPeriodEnded.selector);
        nft.mint{value: MINT_PRICE}(1, proof);
    }

    function testMintFailsWithoutWhitelist() public {
        vm.warp(startTime + 1);

        address notWhitelisted = makeAddr("notWhitelisted");
        vm.deal(notWhitelisted, 1 ether);

        // Empty proof for non-whitelisted address
        bytes32[] memory emptyProof = new bytes32[](0);

        vm.prank(notWhitelisted);
        vm.expectRevert(MysteryBoxNFT.NotWhitelisted.selector);
        nft.mint{value: MINT_PRICE}(1, emptyProof);
    }

    function testMintFailsWithInsufficientPayment() public {
        vm.warp(startTime + 1);

        bytes32[] memory leaves = new bytes32[](3);
        leaves[0] = keccak256(abi.encodePacked(alice));
        leaves[1] = keccak256(abi.encodePacked(bob));
        leaves[2] = keccak256(abi.encodePacked(charlie));
        proof = merkle.getProof(leaves, 0);

        vm.prank(alice);
        vm.expectRevert(MysteryBoxNFT.InsufficientPayment.selector);
        nft.mint{value: MINT_PRICE - 1}(1, proof);
    }

    function testMintRefundsExcessPayment() public {
        vm.warp(startTime + 1);

        bytes32[] memory leaves = new bytes32[](3);
        leaves[0] = keccak256(abi.encodePacked(alice));
        leaves[1] = keccak256(abi.encodePacked(bob));
        leaves[2] = keccak256(abi.encodePacked(charlie));
        proof = merkle.getProof(leaves, 0);

        uint256 balanceBefore = alice.balance;
        uint256 overpayment = 1 ether;

        vm.prank(alice);
        nft.mint{value: MINT_PRICE + overpayment}(1, proof);

        // Should refund the overpayment
        assertEq(alice.balance, balanceBefore - MINT_PRICE);
    }

    function testMintRespectsWalletLimit() public {
        vm.warp(startTime + 1);

        bytes32[] memory leaves = new bytes32[](3);
        leaves[0] = keccak256(abi.encodePacked(alice));
        leaves[1] = keccak256(abi.encodePacked(bob));
        leaves[2] = keccak256(abi.encodePacked(charlie));
        proof = merkle.getProof(leaves, 0);

        // Mint max allowed
        vm.prank(alice);
        nft.mint{value: MINT_PRICE * MAX_PER_WALLET}(MAX_PER_WALLET, proof);
        assertEq(nft.balanceOf(alice), MAX_PER_WALLET);

        // Try to mint one more - should fail
        vm.prank(alice);
        vm.expectRevert(MysteryBoxNFT.WalletLimitExceeded.selector);
        nft.mint{value: MINT_PRICE}(1, proof);
    }

    function testMintRespectsMaxSupply() public {
        vm.warp(startTime + 1);

        // Create a small collection
        vm.prank(owner);
        MysteryBoxNFT smallNFT = new MysteryBoxNFT(
            "Small Collection",
            "SMALL",
            "ipfs://mystery",
            provenanceHash,
            whitelistRoot,
            3, // MAX_SUPPLY = 3
            MINT_PRICE,
            5,
            startTime,
            endTime
        );

        bytes32[] memory leaves = new bytes32[](3);
        leaves[0] = keccak256(abi.encodePacked(alice));
        leaves[1] = keccak256(abi.encodePacked(bob));
        leaves[2] = keccak256(abi.encodePacked(charlie));
        proof = merkle.getProof(leaves, 0);

        // Mint 3 (max supply)
        vm.prank(alice);
        smallNFT.mint{value: MINT_PRICE * 3}(3, proof);

        // Try to mint more - should fail
        proof = merkle.getProof(leaves, 1); // bob's proof
        vm.prank(bob);
        vm.expectRevert(MysteryBoxNFT.MaxSupplyExceeded.selector);
        smallNFT.mint{value: MINT_PRICE}(1, proof);
    }

    /* ===================== REVEAL TESTS ===================== */

    function testRevealAfterBuyPeriod() public {
        vm.warp(endTime + 1);

        string memory revealedURI = "ipfs://revealed-collection/";
        
        vm.prank(owner);
        nft.reveal(revealedURI);

        assertTrue(nft.isRevealed());
    }

    function testRevealFailsBeforeBuyPeriodEnds() public {
        vm.warp(startTime + 1);

        vm.prank(owner);
        vm.expectRevert("Buy period not ended");
        nft.reveal("ipfs://revealed/");
    }

    function testRevealFailsIfAlreadyRevealed() public {
        vm.warp(endTime + 1);

        vm.prank(owner);
        nft.reveal("ipfs://revealed/");

        vm.prank(owner);
        vm.expectRevert(MysteryBoxNFT.AlreadyRevealed.selector);
        nft.reveal("ipfs://another/");
    }

    function testRevealFailsIfNotOwner() public {
        vm.warp(endTime + 1);

        vm.prank(alice);
        vm.expectRevert();
        nft.reveal("ipfs://revealed/");
    }

    /* ===================== TOKEN URI TESTS ===================== */

    function testTokenURIBeforeReveal() public {
        vm.warp(startTime + 1);

        bytes32[] memory leaves = new bytes32[](3);
        leaves[0] = keccak256(abi.encodePacked(alice));
        leaves[1] = keccak256(abi.encodePacked(bob));
        leaves[2] = keccak256(abi.encodePacked(charlie));
        proof = merkle.getProof(leaves, 0);

        vm.prank(alice);
        nft.mint{value: MINT_PRICE * 3}(3, proof);

        // All tokens show mystery box URI
        assertEq(nft.tokenURI(0), "ipfs://mystery-box-uri");
        assertEq(nft.tokenURI(1), "ipfs://mystery-box-uri");
        assertEq(nft.tokenURI(2), "ipfs://mystery-box-uri");
    }

    function testTokenURIAfterReveal() public {
        vm.warp(startTime + 1);

        bytes32[] memory leaves = new bytes32[](3);
        leaves[0] = keccak256(abi.encodePacked(alice));
        leaves[1] = keccak256(abi.encodePacked(bob));
        leaves[2] = keccak256(abi.encodePacked(charlie));
        proof = merkle.getProof(leaves, 0);

        vm.prank(alice);
        nft.mint{value: MINT_PRICE * 3}(3, proof);

        vm.warp(endTime + 1);
        vm.prank(owner);
        nft.reveal("ipfs://revealed/");

        // Tokens show actual metadata with padding
        assertEq(nft.tokenURI(0), "ipfs://revealed/0000.json");
        assertEq(nft.tokenURI(1), "ipfs://revealed/0001.json");
        assertEq(nft.tokenURI(2), "ipfs://revealed/0002.json");
    }

    /* ===================== ADMIN TESTS ===================== */

    function testUpdateWhitelistBeforeStart() public {
        bytes32 newRoot = keccak256("NEW_ROOT");
        
        vm.prank(owner);
        nft.setWhitelistMerkleRoot(newRoot);

        assertEq(nft.whitelistMerkleRoot(), newRoot);
    }

    function testUpdateWhitelistFailsAfterStart() public {
        vm.warp(startTime + 1);

        vm.prank(owner);
        vm.expectRevert("Cannot change after start");
        nft.setWhitelistMerkleRoot(keccak256("NEW_ROOT"));
    }

    function testUpdateMysteryBoxURI() public {
        string memory newURI = "ipfs://new-mystery-box";
        
        vm.prank(owner);
        nft.setMysteryBoxURI(newURI);

        // Deploy a test token to check URI
        vm.warp(startTime + 1);
        bytes32[] memory leaves = new bytes32[](3);
        leaves[0] = keccak256(abi.encodePacked(alice));
        leaves[1] = keccak256(abi.encodePacked(bob));
        leaves[2] = keccak256(abi.encodePacked(charlie));
        proof = merkle.getProof(leaves, 0);

        vm.prank(alice);
        nft.mint{value: MINT_PRICE}(1, proof);

        assertEq(nft.tokenURI(0), newURI);
    }

    function testWithdraw() public {
        vm.warp(startTime + 1);

        bytes32[] memory leaves = new bytes32[](3);
        leaves[0] = keccak256(abi.encodePacked(alice));
        leaves[1] = keccak256(abi.encodePacked(bob));
        leaves[2] = keccak256(abi.encodePacked(charlie));
        
        // Alice mints
        proof = merkle.getProof(leaves, 0);
        vm.prank(alice);
        nft.mint{value: MINT_PRICE * 2}(2, proof);

        // Bob mints
        proof = merkle.getProof(leaves, 1);
        vm.prank(bob);
        nft.mint{value: MINT_PRICE * 3}(3, proof);

        uint256 contractBalance = address(nft).balance;
        assertEq(contractBalance, MINT_PRICE * 5);

        uint256 ownerBalanceBefore = owner.balance;
        
        vm.prank(owner);
        nft.withdraw();

        assertEq(owner.balance, ownerBalanceBefore + contractBalance);
        assertEq(address(nft).balance, 0);
    }

    /* ===================== VIEW FUNCTIONS ===================== */

    function testGetMintStats() public {
        (
            uint256 totalMinted,
            uint256 maxSupply,
            uint256 remainingSupply,
            uint256 currentPrice,
            bool mintActive
        ) = nft.getMintStats();

        assertEq(totalMinted, 0);
        assertEq(maxSupply, MAX_SUPPLY);
        assertEq(remainingSupply, MAX_SUPPLY);
        assertEq(currentPrice, MINT_PRICE);
        assertFalse(mintActive); // Not started yet

        // Warp to buy period and mint
        vm.warp(startTime + 1);
        
        bytes32[] memory leaves = new bytes32[](3);
        leaves[0] = keccak256(abi.encodePacked(alice));
        leaves[1] = keccak256(abi.encodePacked(bob));
        leaves[2] = keccak256(abi.encodePacked(charlie));
        proof = merkle.getProof(leaves, 0);

        vm.prank(alice);
        nft.mint{value: MINT_PRICE * 5}(5, proof);

        (totalMinted, maxSupply, remainingSupply, currentPrice, mintActive) = nft.getMintStats();

        assertEq(totalMinted, 5);
        assertEq(maxSupply, MAX_SUPPLY);
        assertEq(remainingSupply, MAX_SUPPLY - 5);
        assertEq(currentPrice, MINT_PRICE);
        assertTrue(mintActive);
    }
}

