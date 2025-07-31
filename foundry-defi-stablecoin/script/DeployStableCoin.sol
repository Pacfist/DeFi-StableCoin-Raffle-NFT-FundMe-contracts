// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import {StableCoin} from "../src/StableCoin.sol";
import {Script} from "forge-std/Script.sol";

contract DeployStableCoin is Script {
    StableCoin public stableCoin;
    function run() public returns (StableCoin) {
        vm.startBroadcast();
        stableCoin = new StableCoin(0x89Fe3AA7844D3954846003AB3284f3D3320f0a1E);
        vm.stopBroadcast();

        return stableCoin;
    }
}
