// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {Test} from "forge-std/Test.sol";
import {StableCoin} from "../src/StableCoin.sol";
import {DeployStableCoin} from "../script/DeployStableCoin.sol";
import {DSCEngine} from "../src/DSCEngine.sol";
import {DeployEngine} from "../script/DeployEngine.sol";
import {console2} from "forge-std/console2.sol";

contract EngineTest is Test {
    error OwnableUnauthorizedAccount(address);
    StableCoin public stableCoin;
    DSCEngine public dscEngine;

    address public owner = 0x89Fe3AA7844D3954846003AB3284f3D3320f0a1E;
    function setUp() public {
        DeployEngine deployEngine = new DeployEngine();
        (dscEngine, stableCoin) = deployEngine.run();
    }

    function testName() public view {
        console2.log(stableCoin.name());
    }
}
