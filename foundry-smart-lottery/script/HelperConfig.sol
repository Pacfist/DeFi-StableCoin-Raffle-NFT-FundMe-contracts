// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

contract HelperConfig is Script {
    error HelperConfig__InvalidChainId();

    struct NetworkConfig {
        uint256 entranceFee;
        uint256 interval;
        address vrfCoordinator;
        bytes32 gasLane;
        uint256 subscriptionId;
        uint32 callbackGasLimit;
    }
    NetworkConfig public localNetworkConfig;
    mapping(uint256 chainId => NetworkConfig) public networkConfig;
    constructor() {
        networkConfig[11155111] = getSepoliaConfig();
        networkConfig[1] = getMainnetConfig();
    }

    function getConfig() public returns (NetworkConfig memory) {
        return getConfigByChainId(block.chainid);
    }

    function getConfigByChainId(
        uint256 chainId
    ) public returns (NetworkConfig memory) {
        if (networkConfig[chainId].vrfCoordinatorV2_5 != address(0)) {
            return networkConfig[chainId];
        } else if (chainId == 31337) {
            return getOrCreateAnvilEthConfig();
        } else {
            revert HelperConfig__InvalidChainId();
        }
    }

    function getSepoliaConfig() public pure returns (NetworkConfig memory) {
        return
            NetworkConfig({
                entranceFee: 1000000000000000,
                interval: 30,
                vrfCoordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
                gasLane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
                subscriptionId: 7679411351600780301149911877661372214661410357691824210932701096407150720747,
                callbackGasLimit: 500000
            });
    }

    function getMainnetConfig() public pure returns (NetworkConfig memory) {
        return
            NetworkConfig({
                entranceFee: 1000000000000000,
                interval: 30,
                vrfCoordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
                gasLane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
                subscriptionId: 7679411351600780301149911877661372214661410357691824210932701096407150720747,
                callbackGasLimit: 500000
            });
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (networkConfig.vrfCoordinator != address(0)) {
            return networkConfig;
        }

        vm.startBroadcast();
        VRFCoordinatorV2_5Mock vrfMock = new VRFCoordinatorV2_5Mock();
        vm.stopBroadcast();
    }
}
