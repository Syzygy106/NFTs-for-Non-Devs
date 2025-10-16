// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {LazyMintNFT} from "../src/LazyMintNFT.sol";

contract Deploy is Script {
    function run() external {
        string memory name_ = "LazyMintNFT";
        string memory symbol_ = "LMN";
        string memory baseURI_ = "ipfs://YOUR_CID/";
        address signer_ = vm.envAddress("LAZY_SIGNER");

        vm.startBroadcast();
        LazyMintNFT nft = new LazyMintNFT(name_, symbol_, baseURI_, signer_);
        vm.stopBroadcast();

        console2.log("LazyMintNFT deployed at:", address(nft));
    }
}

