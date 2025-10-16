// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {ClassicDrop} from "../src/ClassicDrop.sol";

contract ClassicDropTest is Test {
    ClassicDrop private nft;

    address private initialOwner;
    address private alice;
    address private bob;

    function setUp() public {
        initialOwner = makeAddr("owner");
        alice = makeAddr("alice");
        bob = makeAddr("bob");

        nft = new ClassicDrop(
            "ClassicDrop",
            "CDROP",
            "ipfs://meta/",
            initialOwner,
            3
        );
    }

    function testConstructorMintsAllToOwner() public {
        assertEq(nft.totalSupply(), 3);
        assertEq(nft.balanceOf(initialOwner), 3);
        assertEq(nft.ownerOf(0), initialOwner);
        assertEq(nft.ownerOf(1), initialOwner);
        assertEq(nft.ownerOf(2), initialOwner);
    }

    function testOnlyOwnerCanSetBaseURI() public {
        vm.prank(alice);
        vm.expectRevert();
        nft.setBaseURI("ipfs://new/");

        vm.prank(initialOwner);
        nft.setBaseURI("ipfs://new/");
        assertEq(nft.tokenURI(0), "ipfs://new/0");
    }

    function testFreezeBaseURILocksUpdates() public {
        vm.prank(initialOwner);
        nft.setBaseURI("ipfs://before/");

        vm.prank(initialOwner);
        nft.freezeBaseURI();
        assertTrue(nft.baseURIFrozen());

        vm.prank(initialOwner);
        vm.expectRevert(bytes("baseURI is frozen"));
        nft.setBaseURI("ipfs://after/");
    }

    function testOnlyOwnerOrApprovedCanTransfer() public {
        // Unapproved user cannot transfer others' tokens
        vm.prank(bob);
        vm.expectRevert();
        nft.transferFrom(initialOwner, bob, 0);

        // Owner can transfer
        vm.prank(initialOwner);
        nft.safeTransferFrom(initialOwner, alice, 0);
        assertEq(nft.ownerOf(0), alice);
    }

    function testApprovedAddressCanTransfer() public {
        // Approve bob for token 1
        vm.prank(initialOwner);
        nft.approve(bob, 1);

        // Now bob can transfer token 1
        vm.prank(bob);
        nft.transferFrom(initialOwner, bob, 1);
        assertEq(nft.ownerOf(1), bob);
    }

    function testOperatorCanTransfer() public {
        // Make bob operator for all of initialOwner's tokens
        vm.prank(initialOwner);
        nft.setApprovalForAll(bob, true);

        vm.prank(bob);
        nft.transferFrom(initialOwner, bob, 2);
        assertEq(nft.ownerOf(2), bob);
    }

    function testSupportsInterface() public {
        // ERC165
        assertTrue(nft.supportsInterface(0x01ffc9a7));
        // ERC721
        assertTrue(nft.supportsInterface(0x80ac58cd));
        // ERC721Metadata
        assertTrue(nft.supportsInterface(0x5b5e139f));
    }

    function testTokenURIConcatenation() public {
        // default baseURI set in constructor
        assertEq(nft.tokenURI(0), "ipfs://meta/0");

        vm.prank(initialOwner);
        nft.setBaseURI("ipfs://updated/");
        assertEq(nft.tokenURI(2), "ipfs://updated/2");
    }
}


