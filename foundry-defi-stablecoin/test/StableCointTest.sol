// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {Test} from "forge-std/Test.sol";
import {StableCoin} from "../src/StableCoin.sol";
import {console2} from "forge-std/console2.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {DeployEngine} from "../script/DeployEngine.sol";
import {DSCEngine} from "../src/DSCEngine.sol";

contract BasicNFTtest is Test {
    error OwnableUnauthorizedAccount(address);
    StableCoin public stableCoin;
    Ownable public ownable;
    DSCEngine public engine;
    address public USER = makeAddr("user");
    address public owner;

    function setUp() public {
        vm.deal(USER, 10 ether);
        DeployEngine dp = new DeployEngine();

        (engine, stableCoin, ) = dp.run();
        owner = address(engine);
    }

    function testName() public view {
        console2.log(stableCoin.name());
    }

    function testMintRevertNotOwner() public {
        vm.prank(USER);
        vm.expectRevert(
            abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, USER)
        );
        stableCoin.mint(USER, 5);
    }

    function testMint() public {
        vm.prank(owner);
        stableCoin.mint(owner, 5);
        assertEq(stableCoin.balanceOf(owner), 5);
    }

    function testMintRevertAmountLess() public {
        vm.prank(owner);
        vm.expectRevert();
        stableCoin.mint(owner, 0);
    }

    function testBurn() public {
        vm.prank(owner);
        stableCoin.mint(owner, 10);
        vm.prank(owner);
        stableCoin.burn(5);
        assertEq(stableCoin.balanceOf(owner), 5);
    }
}
