// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {Script} from "forge-std/Script.sol";
import {MoodNFT} from "../src/MoodNft.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {console2} from "forge-std/console2.sol";

contract MintMoodNft is Script {
    function run() external {
        // address mostRecentDep = DevOpsTools.get_most_recent_deployment(
        //     "BasicNFT",
        //     block.chainid
        // );

        mintNFTonContract(0x8D6eC7C39bc96938104447F097A3B4b20c6BF275);
        flipMood(1, 0x8D6eC7C39bc96938104447F097A3B4b20c6BF275);
    }

    function flipMood(uint256 tokenId, address contractAddress) public {
        vm.startBroadcast();
        MoodNFT(contractAddress).flipMood(tokenId);
        vm.stopBroadcast();
    }

    function mintNFTonContract(address contractAddress) public {
        vm.startBroadcast();
        MoodNFT(contractAddress).mintNft();
        vm.stopBroadcast();
    }
}
