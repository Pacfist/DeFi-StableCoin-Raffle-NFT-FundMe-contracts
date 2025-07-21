// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {Script} from "forge-std/Script.sol";
import {TempToken} from "../src/TempToken.sol";

contract DeployToken is Script {
    function run() external {
        vm.startBroadcast();
        new TempToken(1000 ether);
        vm.stopBroadcast();
    }
}
