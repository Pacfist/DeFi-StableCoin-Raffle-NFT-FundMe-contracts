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

    constructor(DSCEngine _dscEngine, StableCoin _stableCoin) {
        dscEngine = _dscEngine;
        stableCoin = _stableCoin;

        address[] memory collateralTokens = dscEngine.getCollateralTokens();
        wethToken = ERC20Mock(collateralTokens[0]);
        wbtcToken = ERC20Mock(collateralTokens[1]);
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
