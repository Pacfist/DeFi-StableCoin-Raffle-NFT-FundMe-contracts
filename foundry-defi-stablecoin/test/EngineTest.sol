// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {Test} from "forge-std/Test.sol";
import {StableCoin} from "../src/StableCoin.sol";
import {DSCEngine} from "../src/DSCEngine.sol";
import {DeployEngine} from "../script/DeployEngine.sol";
import {console2} from "forge-std/console2.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {HelperConfig} from "../script/HelperConfig.sol";

contract EngineTest is Test {
    error OwnableUnauthorizedAccount(address);
    StableCoin public stableCoin;
    DSCEngine public dscEngine;

    uint256 public constant ETH_PRICE = 2000;
    uint256 public constant BTC_PRICE = 3000;

    address public weth;

    ERC20Mock public wethToken;

    address public USER = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    HelperConfig public helperConfig;
    function setUp() public {
        vm.deal(USER, 10 ether);
        DeployEngine deployEngine = new DeployEngine();
        (dscEngine, stableCoin, helperConfig) = deployEngine.run();
        (, , weth, , ) = helperConfig.activeNetworkConfig();
        wethToken = ERC20Mock(weth);
    }

    // function testName() public view {
    //     console2.log(stableCoin.name());
    // }

    // function testOwner() public view {
    //     console2.log(stableCoin.owner());
    // }

    function testGetUsdValue() public {
        console2.log("token address 0!!! --- ", weth);
        assertEq(dscEngine.getUsdValue(weth, 2), ETH_PRICE * 2);
    }

    function testDepositCollateral() public {
        wethToken.mint(USER, 100e18);
        console2.log(wethToken.balanceOf(USER));
        vm.prank(USER);
        dscEngine.depositCollateralAndMintDsc(weth, 1, 500);
        console2.log(dscEngine.getHealthFactor(USER));
    }

    function testTokenAmount() public {
        uint256 usdAmount = 1.5 ether;
        uint256 expectedWeth = 0.00075 ether;
        uint256 actualWeth = dscEngine.getTokenAmountFromUsd(weth, usdAmount);
        assertEq(expectedWeth, actualWeth);
    }

    modifier depositingCollateral(uint256 AMOUNT_COLLATERALL) {
        vm.startPrank(USER);
        wethToken.mint(USER, 100e18);
        wethToken.approve(address(dscEngine), AMOUNT_COLLATERALL);
        dscEngine.depositCollateral(weth, AMOUNT_COLLATERALL);
        vm.stopPrank();
        _;
    }

    function testDepositCollateralGetAccountInfo()
        public
        depositingCollateral(1e18)
    {
        (uint256 totalDscMinted, uint256 collateralValueInUsd) = dscEngine
            .getAccountInformation(USER);
        console2.log(totalDscMinted, collateralValueInUsd);
    }
}
