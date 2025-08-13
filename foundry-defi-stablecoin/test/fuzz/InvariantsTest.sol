// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {Test} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {StableCoin} from "../../src/StableCoin.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {DeployEngine} from "../../script/DeployEngine.sol";
import {console2} from "forge-std/console2.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {HelperConfig} from "../../script/HelperConfig.sol";

import {Handler} from "./Handler.sol";

contract InvariantsTests is StdInvariant, Test {
    StableCoin public stableCoin;
    DSCEngine public dscEngine;
    DeployEngine public deployEngine;
    Handler public handler;

    uint256 public constant ETH_PRICE = 2000;
    uint256 public constant BTC_PRICE = 3000;

    address public weth;
    address public wbtc;

    ERC20Mock public wethToken;
    ERC20Mock public wbtcToken;

    address public ethUsdPriceFeed;
    address public btcUsdPriceFeed;

    address public USER = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    HelperConfig public helperConfig;
    function setUp() public {
        deployEngine = new DeployEngine();

        (dscEngine, stableCoin, helperConfig) = deployEngine.run();
        // targetContract(address(dscEngine));

        handler = new Handler(dscEngine, stableCoin);
        targetContract(address(handler));

        (ethUsdPriceFeed, btcUsdPriceFeed, weth, wbtc, ) = helperConfig
            .activeNetworkConfig();
        wethToken = ERC20Mock(weth);
        wbtcToken = ERC20Mock(wbtc);
    }

    function invariant_protocolMustHaveMoreValueThanTotalSupply() public view {
        uint256 totalSupply = stableCoin.totalSupply();

        uint256 totalWethDeposited = wethToken.balanceOf(address(dscEngine));
        uint256 totalWbtcDeposited = wbtcToken.balanceOf(address(dscEngine));

        uint256 wethValue = dscEngine.getUsdValue(weth, totalWethDeposited);
        uint256 wbtcValue = dscEngine.getUsdValue(wbtc, totalWbtcDeposited);

        console2.log(
            "In varian test wethValue: ",
            wethValue,
            weth,
            totalWethDeposited
        );
        console2.log(
            "In varian test wbtcValue: ",
            wbtcValue,
            wbtc,
            totalWbtcDeposited
        );

        console2.log("In varian test totalSupply: ", totalSupply);
        console2.log(
            "timesMintIsCalled is: ",
            handler.timesMintIsCalled(),
            handler.timesCollateralIsCalled()
        );

        assert(wethValue + wbtcValue >= totalSupply);
    }
}
