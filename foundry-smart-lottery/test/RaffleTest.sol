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

    function setUp() external {
        DeploySL deployer = new DeploySL();
        (raffle, helper) = deployer.deployContract();
        vm.deal(USER1, 10 ether);
    }

    function testRaffleOpenState() public view {
        assert(raffle.getState() == Raffle.STATUS.OPEN);
    }

    function testEnterRaffle() public {
        vm.prank(USER1);

        raffle.enterRaffle{value: 1000000000000000000}();
        console.log(raffle.getPlayers()[0]);
        assert(raffle.getPlayers()[0] == USER1);
    }
}
