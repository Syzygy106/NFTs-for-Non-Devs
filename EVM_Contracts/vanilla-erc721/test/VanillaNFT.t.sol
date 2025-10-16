// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {VanillaNFT} from "../src/VanillaNFT.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract VanillaNFTTest is Test {
    using Strings for uint256;

    VanillaNFT private nft;
    address private ownerAccount;
    address private alice;
    address private bob;

    function setUp() public {
        ownerAccount = address(this);
        alice = address(0xA11CE);
        bob = address(0xB0B);
        nft = new VanillaNFT("MyVanillaNFT", "MVN", "ipfs://base/");
    }

    function testOwnerCanMintTo() public {
        uint256 tokenId = nft.mintTo(alice);
        assertEq(tokenId, 0);
        assertEq(nft.ownerOf(0), alice);
    }

    function testNonOwnerCannotMint() public {
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(bytes4(keccak256("OwnableUnauthorizedAccount(address)")), bob));
        nft.mintTo(alice);
    }

    function testBaseURIAndTokenURI() public {
        uint256 tokenId = nft.mintTo(alice);
        assertEq(nft.tokenURI(tokenId), string.concat("ipfs://base/", tokenId.toString()));

        nft.setBaseURI("ipfs://new/");
        assertEq(nft.tokenURI(tokenId), string.concat("ipfs://new/", tokenId.toString()));
    }
}


