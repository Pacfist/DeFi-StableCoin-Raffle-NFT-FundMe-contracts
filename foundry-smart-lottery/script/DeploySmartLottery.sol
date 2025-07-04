// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.sol";
contract DeploySL is Script {
    function run() public {}

    function deplouyContract() public returns (Raffle, HelperConfig) {
        vm.startBroadcast();
        Raffle raffle = new Raffle(networCOnfig);
        vm.stopBroadcast();
    }
}
