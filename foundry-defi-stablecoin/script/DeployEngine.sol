// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import {DSCEngine} from "../src/DSCEngine.sol";
import {Script} from "forge-std/Script.sol";
import {DeployStableCoin} from "./DeployStableCoin.sol";
import {StableCoin} from "../src/StableCoin.sol";

contract DeployEngine is Script {
    DSCEngine public dscEngine;
    StableCoin public stableCoin;

    address[] public tokenAddresses;
    address[] public priceFeedAddresses;
    function run() public returns (DSCEngine, StableCoin) {
        tokenAddresses = [0xdd13E55209Fd76AfE204dBda4007C227904f0a81];
        priceFeedAddresses = [0x694AA1769357215DE4FAC081bf1f309aDC325306];
        DeployStableCoin deploySC = new DeployStableCoin();
        stableCoin = deploySC.run();
        vm.startBroadcast();
        dscEngine = new DSCEngine(
            tokenAddresses,
            priceFeedAddresses,
            address(stableCoin)
        );
        vm.stopBroadcast();

        return (dscEngine, stableCoin);
    }
}
