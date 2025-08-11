// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {Test} from "forge-std/Test.sol";
import {StableCoin} from "../src/StableCoin.sol";
import {DSCEngine} from "../src/DSCEngine.sol";
import {DeployEngine} from "../script/DeployEngine.sol";
import {console2} from "forge-std/console2.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {HelperConfig} from "../script/HelperConfig.sol";
import {MockV3Aggregator} from "../test/MockV3Aggregator.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract EngineTest is Test {
    error OwnableUnauthorizedAccount(address);
    StableCoin public stableCoin;
    DSCEngine public dscEngine;

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
        vm.deal(USER, 10 ether);
        DeployEngine deployEngine = new DeployEngine();
        (dscEngine, stableCoin, helperConfig) = deployEngine.run();
        (ethUsdPriceFeed, btcUsdPriceFeed, weth, wbtc, ) = helperConfig
            .activeNetworkConfig();
        wethToken = ERC20Mock(weth);
        wbtcToken = ERC20Mock(wbtc);
    }

    modifier depositingCollateralAndMintDsc(
        uint256 AMOUNT_COLLATERALL,
        uint256 AMOUNT_DSC
    ) {
        vm.startPrank(USER);
        wethToken.mint(USER, 100e18);
        wethToken.approve(address(dscEngine), AMOUNT_COLLATERALL);

        dscEngine.depositCollateralAndMintDsc(
            weth,
            AMOUNT_COLLATERALL,
            AMOUNT_DSC
        );
        vm.stopPrank();
        _;
    }

    modifier depositingCollateralAndMintDscBtc(
        uint256 AMOUNT_COLLATERALL,
        uint256 AMOUNT_DSC
    ) {
        vm.startPrank(USER);
        wbtcToken.mint(USER, 100e18);
        wbtcToken.approve(address(dscEngine), AMOUNT_COLLATERALL);

        dscEngine.depositCollateralAndMintDsc(
            wbtc,
            AMOUNT_COLLATERALL,
            AMOUNT_DSC
        );
        vm.stopPrank();
        _;
    }

    address[] public tokenAddresses;
    address[] public feedAddresses;

    function testRevertsIfTokenLengthDoesntMatchPriceFeeds() public {
        tokenAddresses.push(weth);
        feedAddresses.push(ethUsdPriceFeed);
        feedAddresses.push(btcUsdPriceFeed);

        vm.expectRevert(
            DSCEngine.DSCEngine__DifferntQuantityPriceFeedAndTokens.selector
        );
        new DSCEngine(tokenAddresses, feedAddresses, address(dscEngine));
    }

    function testName() public view {
        console2.log(stableCoin.name());
    }

    function testOwner() public view {
        console2.log(stableCoin.owner());
    }

    function testGetUsdValue() public {
        console2.log("token address 0!!! --- ", weth);
        assertEq(dscEngine.getUsdValue(weth, 2), ETH_PRICE * 2);
    }

    function testTokenAmount() public {
        uint256 usdAmount = 2000e18;
        uint256 expectedWeth = 1 ether;
        uint256 actualWeth = dscEngine.getTokenAmountFromUsd(weth, usdAmount);
        assertEq(expectedWeth, actualWeth);
    }

    modifier depositingCollateral(uint256 AMOUNT_COLLATERALL) {
        vm.startPrank(USER);
        wethToken.mint(USER, 100e18);
        wethToken.approve(address(dscEngine), AMOUNT_COLLATERALL);
        dscEngine.depositCollateral(weth, AMOUNT_COLLATERALL);
        console2.log("Balance After depositing: ", wethToken.balanceOf(USER));
        vm.stopPrank();
        _;
    }

    function testDepositCollateralGetAccountInfo()
        public
        depositingCollateral(1e18)
    {
        (uint256 totalDscMinted, uint256 collateralValueInUsd) = dscEngine
            .getAccountInformation(USER);
        console2.log(totalDscMinted, dscEngine.getUsdValue(weth, 1e18));
        assertEq(collateralValueInUsd, dscEngine.getUsdValue(weth, 1e18));
    }

    function testDepositCollaterallAndMintDsc()
        public
        depositingCollateralAndMintDsc(2e18, 2000)
    {
        (uint256 totalDscMinted, uint256 collateralValueInUsd) = dscEngine
            .getAccountInformation(USER);
        console2.log(totalDscMinted, dscEngine.getUsdValue(weth, 2e18));
        console2.log(dscEngine.getHealthFactor(USER));
        assertEq(collateralValueInUsd, dscEngine.getUsdValue(weth, 2e18));
        assertEq(totalDscMinted, 2000);
    }

    function testRedeemCollateral()
        public
        depositingCollateralAndMintDsc(2e18, 1000)
    {
        (uint256 totalDscMinted, uint256 collateralValueInUsd) = dscEngine
            .getAccountInformation(USER);
        console2.log(collateralValueInUsd);
        vm.prank(USER);
        dscEngine.redeemCollateral(weth, 1e18);
        console2.log(wethToken.balanceOf(USER));
        console2.log(dscEngine.getTokenAmount(USER, weth));
        assertEq(wethToken.balanceOf(USER), 100e18 - 1e18);
    }

    function testRedeemCollateralExpectRevertHealthFactor()
        public
        depositingCollateralAndMintDsc(2e18, 1500)
    {
        (uint256 totalDscMinted, uint256 collateralValueInUsd) = dscEngine
            .getAccountInformation(USER);
        console2.log(collateralValueInUsd);
        vm.prank(USER);
        vm.expectRevert();
        dscEngine.redeemCollateral(weth, 1e18);
        console2.log(wethToken.balanceOf(USER));
        console2.log(dscEngine.getTokenAmount(USER, weth));
        assertEq(wethToken.balanceOf(USER), 100e18 - 2e18);
    }

    function testGetTokenAmountFromUsd() public {
        uint256 ans = dscEngine.getTokenAmountFromUsd(weth, 100e18);
        console2.log(ans);
        assertEq(ans, 0.05 ether);
    }

    function testRevertDepositNonRigthTOken() public {
        ERC20Mock tempToken = new ERC20Mock("TEMP", "TEMP");
        vm.startPrank(USER);
        tempToken.mint(USER, 100e18);
        tempToken.approve(address(dscEngine), 1e18);
        vm.expectRevert(DSCEngine.DSCEngine__NotAllowedToken.selector);
        dscEngine.depositCollateralAndMintDsc(address(tempToken), 1e18, 100);
        vm.stopPrank();
    }

    function testRevertIfZero() public {
        vm.startPrank(USER);
        wethToken.mint(USER, 100e18);
        wethToken.approve(address(dscEngine), 1000);
        vm.expectRevert(StableCoin.StableCoint__MustBeMoreThanZero.selector);
        dscEngine.depositCollateralAndMintDsc(weth, 0, 0);
        vm.stopPrank();
    }

    function testRedeemCOlForDsc()
        public
        depositingCollateralAndMintDsc(25e17, 2500)
    {
        vm.startPrank(USER);
        (uint256 totalDscMinted, uint256 collateralValueInUsd) = dscEngine
            .getAccountInformation(USER);

        console2.log("Total dsc minted: ", totalDscMinted);
        console2.log("Collateral val in USD: ", collateralValueInUsd);
        stableCoin.approve(address(dscEngine), 1000);
        dscEngine.redeemCollateralForDsc(weth, 1e18, 1000);

        (totalDscMinted, collateralValueInUsd) = dscEngine
            .getAccountInformation(USER);

        console2.log("Total dsc minted after redeem: ", totalDscMinted);
        console2.log(
            "Collateral val in USD after redeem: ",
            collateralValueInUsd
        );
        vm.stopPrank();
    }

    function testBurnDsc() public depositingCollateralAndMintDsc(2e18, 2000) {
        vm.startPrank(USER);
        (uint256 totalDscMinted, uint256 collateralValueInUsd) = dscEngine
            .getAccountInformation(USER);

        console2.log("Total dsc minted: ", totalDscMinted);
        console2.log("Collateral val in USD: ", collateralValueInUsd);
        stableCoin.approve(address(dscEngine), 100);
        dscEngine.burnDsc(100);

        (
            uint256 totalDscMintedAfterBurn,
            uint256 collateralValueInUsdAfterBurn
        ) = dscEngine.getAccountInformation(USER);

        console2.log("Total dsc minted: ", totalDscMintedAfterBurn);
        console2.log("Collateral val in USD: ", collateralValueInUsdAfterBurn);
        vm.stopPrank();

        assertEq(totalDscMintedAfterBurn, totalDscMinted - 100);
    }

    function testMintAFterDeposit()
        public
        depositingCollateralAndMintDsc(2e18, 1)
    {
        uint256 amountToMint = 100;
        vm.startPrank(USER);
        (uint256 totalDscMinted, uint256 collateralValueInUsd) = dscEngine
            .getAccountInformation(USER);

        console2.log("Total dsc minted: ", totalDscMinted);
        console2.log("Collateral val in USD: ", collateralValueInUsd);

        dscEngine.mintDsc(amountToMint);

        (
            uint256 totalDscMintedAfterMint,
            uint256 collateralValueInUsdAfterMint
        ) = dscEngine.getAccountInformation(USER);

        console2.log("Total dsc minted: ", totalDscMintedAfterMint);
        console2.log("Collateral val in USD: ", collateralValueInUsdAfterMint);
        vm.stopPrank();

        assertEq(totalDscMintedAfterMint, totalDscMinted + amountToMint);
    }

    function testGetAccountCallateralValue()
        public
        depositingCollateralAndMintDscBtc(1e18, 1500)
        depositingCollateralAndMintDsc(2e18, 1000)
    {
        (uint256 totalDscMinted, uint256 collateralValueInUsd) = dscEngine
            .getAccountInformation(USER);

        console2.log("Total dsc minted: ", totalDscMinted);
        console2.log("Collateral val in USD: ", collateralValueInUsd);
        console2.log("User health factor: ", dscEngine.getHealthFactor(USER));
        console2.log(
            "User call value in USD: ",
            dscEngine.getAccountCollateralValue(USER)
        );

        assertEq(
            dscEngine.getAccountCollateralValue(USER),
            1e18 * BTC_PRICE + 2e18 * ETH_PRICE
        );
    }

    function testGetHealthFactor()
        public
        depositingCollateralAndMintDscBtc(1e18, 1500)
        depositingCollateralAndMintDsc(2e18, 2000)
    {
        uint256 hf = dscEngine.getHealthFactor(USER);
        console2.log("User health factor: ", hf);
        assertEq(hf, 1e18);
    }

    function testMintRevertsWhenHealthFactorWouldBreak()
        public
        depositingCollateralAndMintDsc(2e18, 2000)
    {
        vm.startPrank(USER);
        vm.expectRevert(
            abi.encodeWithSelector(
                DSCEngine.DSCEngine_HealthFactorLessThenOne.selector,
                999500249875062468
            )
        );
        dscEngine.mintDsc(1); // any extra debt should push HF < 1
        vm.stopPrank();
    }

    // 2.5 ETH, $5k; HF = 1.0
    function testRedeemCollateralForDscKeepsHFProportional()
        public
        depositingCollateralAndMintDsc(25e17, 2500)
    {
        uint256 hfBefore = dscEngine.getHealthFactor(USER);

        vm.startPrank(USER);
        stableCoin.approve(address(dscEngine), 1000);
        dscEngine.redeemCollateralForDsc(weth, 1e18, 1000); // -$2000 collat, -1000 debt
        vm.stopPrank();

        uint256 hfAfter = dscEngine.getHealthFactor(USER);
        // With your formula, both should be 1.0
        assertEq(hfBefore, 1e18);
        assertEq(hfAfter, 1e18);
    }

    function _expectedHf(
        uint256 totalDsc,
        uint256 collateralUsd
    ) internal pure returns (uint256) {
        if (totalDsc == 0) return type(uint256).max;
        uint256 adj = (collateralUsd * 50) / 100; // 50% threshold
        // NOTE: matches your engine’s scaling (HF in 1e18 units)
        return (adj * 1e18) / totalDsc;
    }

    function _getInfo()
        internal
        view
        returns (uint256 totalDsc, uint256 collUsd, uint256 hf)
    {
        (totalDsc, collUsd) = dscEngine.getAccountInformation(USER);
        hf = dscEngine.getHealthFactor(USER);
    }
}
