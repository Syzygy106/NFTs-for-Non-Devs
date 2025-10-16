// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {LazyMintNFT} from "../src/LazyMintNFT.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract LazyMintNFTTest is Test {
    LazyMintNFT private nft;
    address private signer;
    uint256 private signerKey;
    address private alice;

    function setUp() public {
        (signer, signerKey) = makeAddrAndKey("signer");
        alice = address(0xA11CE);
        nft = new LazyMintNFT("LazyMintNFT", "LMN", "ipfs://base/", signer);
    }

    function signVoucher(address recipient, string memory tokenURI, uint256 nonce) internal view returns (bytes memory) {
        bytes32 digest = keccak256(abi.encode(
            keccak256("Voucher(address recipient,string tokenURI,uint256 nonce)"),
            recipient,
            keccak256(bytes(tokenURI)),
            nonce
        ));
        return sign(digest);
    }

    function sign(bytes32 digest) internal view returns (bytes memory sig) {
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerKey, MessageHashUtils.toEthSignedMessageHash(digest));
        sig = abi.encodePacked(r, s, v);
    }

    function testRedeemMintsToRecipient() public {
        bytes memory sig = signVoucher(alice, "ipfs://x", 1);
        vm.prank(alice);
        uint256 tokenId = nft.redeem(LazyMintNFT.Voucher({recipient: alice, tokenURI: "ipfs://x", nonce: 1}), sig);
        assertEq(tokenId, 0);
        assertEq(nft.ownerOf(0), alice);
    }

    function testReplayFails() public {
        bytes memory sig = signVoucher(alice, "ipfs://x", 2);
        vm.prank(alice);
        nft.redeem(LazyMintNFT.Voucher({recipient: alice, tokenURI: "ipfs://x", nonce: 2}), sig);
        vm.prank(alice);
        vm.expectRevert(bytes("Nonce used"));
        nft.redeem(LazyMintNFT.Voucher({recipient: alice, tokenURI: "ipfs://x", nonce: 2}), sig);
    }
}


