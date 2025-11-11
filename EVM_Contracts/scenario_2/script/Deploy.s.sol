// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {MysteryBoxNFT} from "../src/MysteryBoxNFT.sol";

contract Deploy is Script {
    function run() external {
        // Required environment variables
        string memory name_ = vm.envString("NAME");
        string memory symbol_ = vm.envString("SYMBOL");
        string memory mysteryBoxURI_ = vm.envString("MYSTERY_BOX_URI");
        bytes32 provenanceHash_ = vm.envBytes32("PROVENANCE_HASH");
        bytes32 whitelistRoot_ = vm.envBytes32("WHITELIST_MERKLE_ROOT");
        uint256 maxSupply_ = vm.envUint("MAX_SUPPLY");
        uint256 mintPrice_ = vm.envUint("MINT_PRICE");
        uint256 maxPerWallet_ = vm.envUint("MAX_PER_WALLET");
        uint256 startTime_ = vm.envUint("BUY_PERIOD_START");
        uint256 endTime_ = vm.envUint("BUY_PERIOD_END");

        vm.startBroadcast();
        
        MysteryBoxNFT nft = new MysteryBoxNFT(
            name_,
            symbol_,
            mysteryBoxURI_,
            provenanceHash_,
            whitelistRoot_,
            maxSupply_,
            mintPrice_,
            maxPerWallet_,
            startTime_,
            endTime_
        );
        
        vm.stopBroadcast();

        console2.log("===========================================");
        console2.log("MysteryBoxNFT deployed at:", address(nft));
        console2.log("===========================================");
        console2.log("Configuration:");
        console2.log("  Name:", name_);
        console2.log("  Symbol:", symbol_);
        console2.log("  Max Supply:", maxSupply_);
        console2.log("  Mint Price (wei):", mintPrice_);
        console2.log("  Max Per Wallet:", maxPerWallet_);
        console2.log("  Buy Period Start:", startTime_);
        console2.log("  Buy Period End:", endTime_);
        console2.log("===========================================");
        console2.log("Mystery Box URI:", mysteryBoxURI_);
        console2.log("Provenance Hash:", vm.toString(provenanceHash_));
        console2.log("Whitelist Root:", vm.toString(whitelistRoot_));
        console2.log("===========================================");
    }
}

