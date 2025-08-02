// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import {DSCEngine} from "../src/DSCEngine.sol";
import {Script} from "forge-std/Script.sol";
import {StableCoin} from "../src/StableCoin.sol";
import {MockV3Aggregator} from "../test/MockV3Aggregator.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {console2} from "forge-std/console2.sol";
import {HelperConfig} from "./HelperConfig.sol";

contract DeployEngine is Script {
    DSCEngine public dscEngine;
    StableCoin public stableCoin;

    address[] public tokenAddresses;
    address[] public priceFeedAddresses;
    address public publicOwnerKey;
    function run() public returns (DSCEngine, StableCoin, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();

        (
            address wethUsdPriceFeed,
            address wbtcUsdPriceFeed,
            address weth,
            address wbtc,
            uint256 deployerKey
        ) = helperConfig.activeNetworkConfig();

        tokenAddresses = [weth, wbtc];
        priceFeedAddresses = [wethUsdPriceFeed, wbtcUsdPriceFeed];

        if (block.chainid == 11155111) {
            publicOwnerKey = 0x89Fe3AA7844D3954846003AB3284f3D3320f0a1E;
        } else {
            publicOwnerKey = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
        }

        vm.startBroadcast(deployerKey);
        stableCoin = new StableCoin(publicOwnerKey);
        dscEngine = new DSCEngine(
            tokenAddresses,
            priceFeedAddresses,
            address(stableCoin)
        );
        stableCoin.transferOwnership(address(dscEngine));
        console2.log("The owner of the coin now is: ", address(dscEngine));
        vm.stopBroadcast();

        return (dscEngine, stableCoin, helperConfig);
    }
}
