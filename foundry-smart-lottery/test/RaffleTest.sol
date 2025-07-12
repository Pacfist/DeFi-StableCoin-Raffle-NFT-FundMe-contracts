// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {Test, console} from "forge-std/Test.sol";
import {DeploySL} from "../script/DeploySmartLottery.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "../script/HelperConfig.sol";

contract RaffleTest is Test {
    Raffle public raffle;
    HelperConfig public helper;

    address USER1 = makeAddr("user1");
    address USER2 = makeAddr("user2");
    function setUp() external {
        DeploySL deployer = new DeploySL();
        (raffle, helper) = deployer.deployContract();
        vm.deal(USER1, 10 ether);
        vm.deal(USER2, 10 ether);
    }

    // function testRaffleOpenState() public view {
    //     assert(raffle.getState() == Raffle.STATUS.OPEN);
    // }

    // function testEnterRafflePositive() public {
    //     vm.prank(USER1);

    //     raffle.enterRaffle{value: 1000000000000000000}();
    //     console.log(raffle.getPlayers()[0]);
    //     assert(raffle.getPlayers()[0] == USER1);
    // }

    // function testEnterRaffleNegative() public {
    //     vm.prank(USER1);

    //     vm.expectRevert(Raffle.NotEnoughtEthSent.selector);
    //     raffle.enterRaffle{value: 100000}();
    // }

    // event RaffleEnter(address indexed player);

    // function testEnterEmit() public {
    //     vm.prank(USER1);

    //     vm.expectEmit(true, false, false, false, address(raffle));
    //     emit RaffleEnter(USER1);

    //     raffle.enterRaffle{value: 1000000000000000000}();
    // }

    // function testEnterRaffleCalculatingState() public {
    //     vm.prank(USER1);
    //     raffle.enterRaffle{value: 1000000000000000000}();
    //     vm.warp(block.timestamp + 31);
    //     vm.roll(block.number + 1);

    //     raffle.performUpkeep("");

    //     vm.expectRevert(Raffle.RaffleNotOpen.selector);
    //     vm.prank(USER2);
    //     raffle.enterRaffle{value: 1000000000000000000}();
    // }

    // function testCheckUpkeepNoBalance() public {
    //     vm.warp(block.timestamp + 31);
    //     vm.roll(block.number + 1);
    //     (bool needed, ) = raffle.checkUpkeep("");

    //     assert(!needed);
    // }

    function testCheckRaffleNotOpen() public {
        vm.prank(USER1);
        raffle.enterRaffle{value: 1000000000000000000}();
        vm.warp(block.timestamp + 31);
        vm.roll(block.number + 1);
        raffle.performUpkeep("");

        (bool needed, ) = raffle.checkUpkeep("");

        assert(!needed);
    }
}
