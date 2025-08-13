// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {Test} from "forge-std/Test.sol";
import {StableCoin} from "../../src/StableCoin.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {DeployEngine} from "../../script/DeployEngine.sol";
import {console2} from "forge-std/console2.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {HelperConfig} from "../../script/HelperConfig.sol";
import {MockV3Aggregator} from "../MockV3Aggregator.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Handler is Test {
    DSCEngine dscEngine;
    StableCoin stableCoin;

    ERC20Mock public wethToken;
    ERC20Mock public wbtcToken;

    uint256 MAX_DEPOSIT_SIZE = type(uint96).max;

    uint256 public timesMintIsCalled = 0;
    uint256 public timesCollateralIsCalled = 0;
    address[] public usersWithCollateralDeposited;

    MockV3Aggregator public ethUsdPriceFeed;

    constructor(DSCEngine _dscEngine, StableCoin _stableCoin) {
        dscEngine = _dscEngine;
        stableCoin = _stableCoin;

        address[] memory collateralTokens = dscEngine.getCollateralTokens();
        wethToken = ERC20Mock(collateralTokens[0]);
        wbtcToken = ERC20Mock(collateralTokens[1]);

        ethUsdPriceFeed = MockV3Aggregator(
            dscEngine.getCollateralTokenPriceFeed(address(wethToken))
        );
    }

    // function depositCollateralAndMintDsc(
    //     uint256 collateralSeed,
    //     uint256 _amountCollateral,
    //     uint256 _amountDsc
    // ) public {
    //     ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);

    //     (uint256 totalDscMinted, uint256 collateralValueInUsd) = dscEngine
    //         .getAccountInformation(msg.sender);
    //     console2.log("collateralValueInUsd: ", collateralValueInUsd);

    //     int256 maxDscToMint = (int256(collateralValueInUsd) / 2) -
    //         int256(totalDscMinted);

    //     if (maxDscToMint == 0) {
    //         collateralValueInUsd = dscEngine.getUsdValue(
    //             address(collateral),
    //             _amountCollateral
    //         );

    //         maxDscToMint =
    //             (int256(collateralValueInUsd) / 2) -
    //             int256(totalDscMinted);
    //     }

    //     console2.log("maxDscToMint: ", maxDscToMint);

    //     if (maxDscToMint < 0) {
    //         return;
    //     }
    //     _amountDsc = bound(_amountDsc, 0, uint256(maxDscToMint));
    //     console2.log("_amountDsc: ", _amountDsc);

    //     if (_amountDsc == 0) {
    //         return;
    //     }

    //     _amountCollateral = bound(_amountCollateral, 1, MAX_DEPOSIT_SIZE);

    //     vm.startPrank(msg.sender);
    //     collateral.mint(msg.sender, _amountCollateral);
    //     collateral.approve(address(dscEngine), _amountCollateral);

    //     dscEngine.depositCollateralAndMintDsc(
    //         address(collateral),
    //         _amountCollateral,
    //         _amountDsc
    //     );
    //     vm.stopPrank();

    //     (
    //         uint256 totalDscMintedAfetrDep,
    //         uint256 collateralValueInUsdAfterDep
    //     ) = dscEngine.getAccountInformation(msg.sender);

    //     console2.log(
    //         "Afetr dep dsc and colla value and collateral address: ",
    //         totalDscMintedAfetrDep,
    //         collateralValueInUsdAfterDep,
    //         address(collateral)
    //     );

    //
    // }

    function mintDsc(uint256 _amount, uint256 _addressSeed) public {
        if (usersWithCollateralDeposited.length == 0) {
            return;
        }
        address sender = usersWithCollateralDeposited[
            _addressSeed % usersWithCollateralDeposited.length
        ];
        (uint256 totalDscMinted, uint256 collateralValueInUsd) = dscEngine
            .getAccountInformation(sender);
        int256 maxDscToMint = (int256(collateralValueInUsd) / 2) -
            int256(totalDscMinted);

        console2.log("totalDscMinted: ", totalDscMinted);
        if (maxDscToMint < 0) {
            return;
        }
        _amount = bound(_amount, 0, uint256(maxDscToMint));
        if (_amount == 0) {
            return;
        }
        vm.startPrank(sender);
        dscEngine.mintDsc(_amount);
        vm.stopPrank();

        timesMintIsCalled++;
    }

    function depositCollateral(
        uint256 collateralSeed,
        uint256 _amountCollateral
    ) public {
        _amountCollateral = bound(_amountCollateral, 1, MAX_DEPOSIT_SIZE);
        ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);
        vm.startPrank(msg.sender);
        collateral.mint(msg.sender, _amountCollateral);
        collateral.approve(address(dscEngine), _amountCollateral);

        dscEngine.depositCollateral(address(collateral), _amountCollateral);
        vm.stopPrank();
        usersWithCollateralDeposited.push(msg.sender);
        timesCollateralIsCalled++;
    }

    function redeemCollateral(
        uint256 collateralSeed,
        uint256 _amountCollateral
    ) public {
        ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);

        uint256 maxCollaterallToRedeem = dscEngine.getTokenAmount(
            msg.sender,
            address(collateral)
        );

        _amountCollateral = bound(_amountCollateral, 0, maxCollaterallToRedeem);
        if (_amountCollateral == 0) {
            return;
        }
        console2.log("Amount collTERAL: ", _amountCollateral);
        console2.log("Max collaterall to redeem: ", maxCollaterallToRedeem);
        vm.prank(msg.sender);
        dscEngine.redeemCollateral(address(collateral), _amountCollateral);
    }

    function updateCollateralPrice(uint96 newPrice) public {
        int256 newPriceInt = int256(uint256(newPrice));
        ethUsdPriceFeed.updateAnswer(newPriceInt);
    }

    //HELPER FUNCTIONS

    function _getCollateralFromSeed(
        uint256 collateralSeed
    ) private view returns (ERC20Mock) {
        if (collateralSeed % 2 == 0) {
            return wethToken;
        }
        return wbtcToken;
    }
}
