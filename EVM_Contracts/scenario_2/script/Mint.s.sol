// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";

interface IMysteryBoxNFT {
    function mint(uint256 quantity, bytes32[] calldata merkleProof) external payable returns (uint256);
    function MINT_PRICE() external view returns (uint256);
}

contract Mint is Script {
    /// Env vars:
    /// - CONTRACT: address of deployed MysteryBoxNFT
    /// - QUANTITY: how many NFTs to mint (uint)
    /// - PROOF_FILE: path to JSON file with {"proof":[ "0x...", "0x..." ]}
    ///
    /// Example:
    /// forge script script/Mint.s.sol \
    ///   --rpc-url $RPC_URL \
    ///   --broadcast \
    ///   --private-key $PRIVATE_KEY \
    ///   -vvvv
    function run() external {
        address contractAddr = vm.envAddress("CONTRACT");
        uint256 quantity = vm.envUint("QUANTITY");
        bytes32[] memory proof;
        bool testMode = false;
        bool usedJson = false;
        bool usedFile = false;
        string memory proofJson = "";
        string memory proofFile = "";
        try vm.envBool("TEST_MODE") returns (bool b) { testMode = b; } catch {}
        if (testMode) {
            // For unit-tests we allow single-leaf trees (root = leaf) so proof can be empty.
            proof = new bytes32[](0);
        } else {
            // Prefer inline JSON via PROOF_JSON if provided; otherwise read from file
            try vm.envString("PROOF_JSON") returns (string memory pj) {
                proofJson = pj;
            } catch {}
            if (bytes(proofJson).length != 0) {
                bytes memory raw = vm.parseJson(proofJson, ".proof");
                proof = abi.decode(raw, (bytes32[]));
                usedJson = true;
            } else {
                proofFile = vm.envString("PROOF_FILE");
                string memory json = vm.readFile(proofFile);
                bytes memory raw = vm.parseJson(json, ".proof");
                proof = abi.decode(raw, (bytes32[]));
                usedFile = true;
            }
        }

        IMysteryBoxNFT nft = IMysteryBoxNFT(contractAddr);

        uint256 price = nft.MINT_PRICE();
        uint256 valueToSend = price * quantity;

        if (testMode) {
            // In test mode, call directly without broadcasting
            nft.mint{value: valueToSend}(quantity, proof);
            return; // Early return for tests
        }

        vm.startBroadcast();
        nft.mint{value: valueToSend}(quantity, proof);
        vm.stopBroadcast();

        console2.log("Minted", quantity, "token(s) on contract:", contractAddr);
        console2.log("Paid (wei):", valueToSend);
        if (usedJson) {
            console2.log("Proof source: PROOF_JSON");
        } else if (usedFile) {
            console2.log("Proof source: PROOF_FILE");
            console2.log("Proof file:", proofFile);
        }
    }
}


