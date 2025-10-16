// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {ClassicDrop} from "../src/ClassicDrop.sol";

contract Deploy is Script {
    function run() external {
        // Required .env variables:
        // NAME, SYMBOL, BASE_URI, INITIAL_OWNER, INITIAL_SUPPLY
        string memory name_ = vm.envString("NAME");
        string memory symbol_ = vm.envString("SYMBOL");
        string memory baseURI_ = vm.envString("BASE_URI");
        address initialOwner = vm.envAddress("INITIAL_OWNER");
        uint256 initialSupply = vm.envUint("INITIAL_SUPPLY");

        vm.startBroadcast();
        ClassicDrop nft = new ClassicDrop(
            name_,
            symbol_,
            baseURI_,
            initialOwner,
            initialSupply
        );
        vm.stopBroadcast();

        console2.log("ClassicDrop deployed at:", address(nft));
        console2.log("Name:", name_);
        console2.log("Symbol:", symbol_);
        console2.log("BaseURI:", baseURI_);
        console2.log("InitialOwner:", initialOwner);
        console2.log("InitialSupply:", initialSupply);
    }
}

