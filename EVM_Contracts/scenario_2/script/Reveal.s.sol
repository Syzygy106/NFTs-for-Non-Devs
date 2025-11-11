// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";

interface IRevealer {
    function reveal(string calldata revealedBaseURI_) external;
}

contract Reveal is Script {
    // Reads:
    // - CONTRACT (address): deployed MysteryBoxNFT
    // - REVEALED_BASE_URI (string): ipfs://CID/
    function run() external {
        address contractAddr = vm.envAddress("CONTRACT");
        string memory revealedBaseURI = vm.envString("REVEALED_BASE_URI");

        bool testMode = false;
        try vm.envBool("TEST_MODE") returns (bool b) { testMode = b; } catch {}
        if (!testMode) {
            vm.startBroadcast();
            IRevealer(contractAddr).reveal(revealedBaseURI);
            vm.stopBroadcast();
        } else {
            IRevealer(contractAddr).reveal(revealedBaseURI);
        }

        console2.log("Reveal tx sent to:", contractAddr);
        console2.log("Revealed base URI:", revealedBaseURI);
    }
}


