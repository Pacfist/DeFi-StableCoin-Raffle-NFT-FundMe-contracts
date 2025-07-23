// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {Script} from "forge-std/Script.sol";
import {BasicNFT} from "../src/BasicNFT.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {console2} from "forge-std/console2.sol";

contract MintBasicNft is Script {
    string public constant apple =
        "ipfs://bafybeicf2nxrk6hc4n7r7uwaaeerov5zmti64kmoeery2f74giy7pwzvrm.ipfs.dweb.link?filename=apple.json";

    string public constant PUG_URI =
        "ipfs://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4/?filename=0-PUG.json";

    function run() external {
        // address mostRecentDep = DevOpsTools.get_most_recent_deployment(
        //     "BasicNFT",
        //     block.chainid
        // );

        mintNFTonContract(0x6B20E8b1715B00908e28Fa995E54BB47Ba6821D3);
    }

    function mintNFTonContract(address contractAddress) public {
        vm.startBroadcast();
        BasicNFT(contractAddress).mintNft(apple);
        vm.stopBroadcast();
    }
}
