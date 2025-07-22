// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {Script} from "forge-std/Script.sol";
import {BasicNFT} from "../src/BasicNFT.sol";

contract DeployNft is Script {
    function run() external returns (BasicNFT) {
        vm.startBroadcast();
        BasicNFT basicNFT = new BasicNFT();
        vm.stopBroadcast();
        return basicNFT;
    }
}
