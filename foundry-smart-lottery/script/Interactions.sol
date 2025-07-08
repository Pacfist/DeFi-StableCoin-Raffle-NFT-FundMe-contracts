// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "../test/LinkToken.sol";
import {console2} from "forge-std/console2.sol";

contract CreateSubscription is Script {
    function createSub() public returns (uint256, address) {
        HelperConfig helperConfig = new HelperConfig();
        address vrfCoordinator = helperConfig.getConfig().vrfCoordinator;

        console.log("Creating subscription on chain id:", block.chainid);
        vm.startBroadcast();
        uint256 subId = VRFCoordinatorV2_5Mock(vrfCoordinator)
            .createSubscription();

        vm.stopBroadcast();
        console.log("Subscription id: ", subId);
        return (subId, vrfCoordinator);
    }
}

contract FundSub is Script {
    function fundSub() public {
        HelperConfig helperConfig = new HelperConfig();
        address vrfCoordinator = helperConfig.getConfig().vrfCoordinator;
        uint256 subId = helperConfig.getConfig().subscriptionId;
        address linkToken = helperConfig.getConfig().link;

        if (block.chainid == 31337) {
            vm.startBroadcast();
            VRFCoordinatorV2_5Mock(vrfCoordinator).fundSubscription(
                subId,
                3 ether
            );
            vm.stopBroadcast();
        } else {
            console.log("Funding on chain:");
            console.log("Funding Subscription on chain ID:", block.chainid);
            console.log("Subscription ID:", subId);
            console.log("VRF Coordinator Address:", vrfCoordinator);
            console.log("Link Token Address:", linkToken);
            vm.startBroadcast();
            LinkToken(linkToken).transferAndCall(
                vrfCoordinator,
                1 ether,
                abi.encode(subId)
            );
        }
    }

    function run() public {
        fundSub();
    }
}
