// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {Test} from "forge-std/Test.sol";
import {StableCoin} from "../src/StableCoin.sol";
import {DeployStableCoin} from "../script/DeployStableCoin.sol";
import {console2} from "forge-std/console2.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract BasicNFTtest is Test {
    error OwnableUnauthorizedAccount(address);
    StableCoin public stableCoin;
    Ownable public ownable;
    address public USER = makeAddr("user");
    address public owner = 0x89Fe3AA7844D3954846003AB3284f3D3320f0a1E;
    function setUp() public {
        vm.deal(USER, 10 ether);
        DeployStableCoin deploySC = new DeployStableCoin();
        stableCoin = deploySC.run();
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
}
