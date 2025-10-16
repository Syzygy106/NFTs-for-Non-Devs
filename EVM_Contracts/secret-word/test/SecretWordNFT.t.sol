// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {SecretWordNFT} from "../src/SecretWordNFT.sol";

contract SecretWordNFTTest is Test {
    SecretWordNFT private nft;

    function setUp() public {
        bytes32 secretHash = keccak256(bytes("banana"));
        nft = new SecretWordNFT("SecretWordNFT", "SWN", "ipfs://base/", secretHash);
    }

    function testMintWithCorrectSecret() public {
        vm.prank(address(0xA11CE));
        uint256 tokenId = nft.mintWithSecret("banana");
        assertEq(tokenId, 0);
        assertEq(nft.ownerOf(0), address(0xA11CE));
    }

    function testMintWithWrongSecretReverts() public {
        vm.prank(address(0xB0B));
        vm.expectRevert(bytes("Wrong secret"));
        nft.mintWithSecret("apple");
    }
}


