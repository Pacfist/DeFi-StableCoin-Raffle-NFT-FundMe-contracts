// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
import {Script, console} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.sol";
import {CreateSubscription, FundSub, AddConsumer} from "./Interactions.sol";
import {console2} from "forge-std/console2.sol";
contract DeploySL is Script {
    function run() public {
        deployContract();
    }

    function deployContract() public returns (Raffle, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        if (config.subscriptionId == 0) {
            CreateSubscription createSub = new CreateSubscription();
            (config.subscriptionId, config.vrfCoordinator) = createSub
                .createSubscription(config.vrfCoordinator);
            console2.log("New subId is ", config.subscriptionId);
            FundSub fundSub = new FundSub();
            fundSub.fundSub(
                config.vrfCoordinator,
                config.subscriptionId,
                config.link
            );
        }

        vm.startBroadcast();
        Raffle raffle = new Raffle(
            config.entranceFee,
            config.interval,
            config.vrfCoordinator,
            config.gasLane,
            config.subscriptionId,
            config.callbackGasLimit
        );
        vm.stopBroadcast();

        AddConsumer addCon = new AddConsumer();
        addCon.addConsumer(
            address(raffle),
            config.vrfCoordinator,
            config.subscriptionId
        );

        return (raffle, helperConfig);
    }
}
