// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";

interface IWithdrawable {
    function withdraw() external;
}

contract Withdraw is Script {
    // Allow receiving native tokens in tests
    receive() external payable {}

    // Reads:
    // - CONTRACT (address): deployed MysteryBoxNFT
    function run() external {
        address contractAddr = vm.envAddress("CONTRACT");

        bool testMode = false;
        try vm.envBool("TEST_MODE") returns (bool b) { testMode = b; } catch {}
        if (!testMode) {
            vm.startBroadcast();
            IWithdrawable(contractAddr).withdraw();
            vm.stopBroadcast();
        } else {
            IWithdrawable(contractAddr).withdraw();
        }

        console2.log("Withdraw executed on:", contractAddr);
    }
}


