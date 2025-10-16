// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {VanillaNFT} from "../src/VanillaNFT.sol";

contract Deploy is Script {
    function run() external {
        string memory name_ = "MyVanillaNFT";
        string memory symbol_ = "MVN";
        string memory baseURI_ = "ipfs://YOUR_CID/";

        vm.startBroadcast();
        VanillaNFT nft = new VanillaNFT(name_, symbol_, baseURI_);
        vm.stopBroadcast();

        console2.log("VanillaNFT deployed at:", address(nft));
    }
}

