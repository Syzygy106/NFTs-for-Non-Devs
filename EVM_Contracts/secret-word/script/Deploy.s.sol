// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {SecretWordNFT} from "../src/SecretWordNFT.sol";

contract Deploy is Script {
    function run() external {
        string memory name_ = "SecretWordNFT";
        string memory symbol_ = "SWN";
        string memory baseURI_ = "ipfs://YOUR_CID/";
        // Example secret: "banana" => keccak256("banana")
        bytes32 secretHash_ = vm.envBytes32("SECRET_HASH");

        vm.startBroadcast();
        SecretWordNFT nft = new SecretWordNFT(name_, symbol_, baseURI_, secretHash_);
        vm.stopBroadcast();

        console2.log("SecretWordNFT deployed at:", address(nft));
    }
}

