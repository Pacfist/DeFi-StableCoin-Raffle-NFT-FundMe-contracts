// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {Test, console} from "forge-std/Test.sol";
import {DeploySL} from "../script/DeploySmartLottery.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "../script/HelperConfig.sol";
import {console2} from "forge-std/console2.sol";
import {Vm} from "forge-std/Vm.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

contract RaffleTest is Test {
    Raffle public raffle;
    HelperConfig public helper;

    address vrfCoordinator;
    uint256 subId;
    address USER1 = makeAddr("user1");
    address USER2 = makeAddr("user2");

    function setUp() external {
        DeploySL deployer = new DeploySL();
        (raffle, helper) = deployer.deployContract();
        vrfCoordinator = helper.getConfig().vrfCoordinator;
        subId = helper.getConfig().subscriptionId;
        vm.deal(USER1, 10 ether);
        vm.deal(USER2, 10 ether);
    }

    function testRaffleOpenState() public view {
        assert(raffle.getState() == Raffle.STATUS.OPEN);
    }

    function testEnterRafflePositive() public {
        vm.prank(USER1);

        raffle.enterRaffle{value: 1000000000000000000}();
        console.log(raffle.getPlayers()[0]);
        assert(raffle.getPlayers()[0] == USER1);
    }

    function testEnterRaffleNegative() public {
        vm.prank(USER1);

        vm.expectRevert(Raffle.NotEnoughtEthSent.selector);
        raffle.enterRaffle{value: 100000}();
    }

    event RaffleEnter(address indexed player);

    function testEnterEmit() public {
        vm.prank(USER1);

        vm.expectEmit(true, false, false, false, address(raffle));
        emit RaffleEnter(USER1);

        raffle.enterRaffle{value: 1000000000000000000}();
    }

    function testEnterRaffleCalculatingState() public {
        vm.prank(USER1);
        raffle.enterRaffle{value: 1000000000000000000}();
        vm.warp(block.timestamp + 31);
        vm.roll(block.number + 1);

        raffle.performUpkeep("");

        vm.expectRevert(Raffle.RaffleNotOpen.selector);
        vm.prank(USER2);
        raffle.enterRaffle{value: 1000000000000000000}();
    }

    function testCheckUpkeepNoBalance() public {
        vm.warp(block.timestamp + 31);
        vm.roll(block.number + 1);
        (bool needed, ) = raffle.checkUpkeep("");

        assert(!needed);
    }

    function testCheckRaffleNotOpen() public {
        vm.prank(USER1);
        raffle.enterRaffle{value: 1000000000000000000}();
        vm.warp(block.timestamp + 31);
        vm.roll(block.number + 1);
        raffle.performUpkeep("");

        (bool needed, ) = raffle.checkUpkeep("");

        assert(!needed);
    }
    //

    function testPerformUpkeepRunIfTrue() public {
        vm.prank(USER1);
        raffle.enterRaffle{value: 1000000000000000000}();
        vm.warp(block.timestamp + 30);
        vm.roll(block.number + 1);

        raffle.performUpkeep("");
    }

    function testPerformUpkeepRunIfFalseTime() public {
        Raffle.STATUS state = raffle.getState();
        console2.log("State as uint:", uint256(state));
        vm.prank(USER1);
        raffle.enterRaffle{value: 1000000000000000000}();
        console2.log("State as uint 2:", uint256(state));
        vm.expectRevert(
            abi.encodeWithSelector(
                Raffle.UpkeepNotNeeded.selector,
                1000000000000000000,
                1,
                state
            )
        );

        raffle.performUpkeep("");
    }

    function testPerformUpkeepCheckRequID() public {
        vm.prank(USER1);
        raffle.enterRaffle{value: 1000000000000000000}();
        vm.warp(block.timestamp + 30);
        vm.roll(block.number + 1);

        //console2.log("!!!!!!!!!!!!!!!", vrfCoordinator);

        vm.recordLogs();
        raffle.performUpkeep("");
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 reqquestId = entries[1].topics[1];

        Raffle.STATUS state = raffle.getState();
        assert(uint256(reqquestId) > 0);
        assert(uint256(state) == 1);
    }

    function testFulfilRandomWordsAfterPU(uint256 randomRequestId) public {
        console2.log("!!!!!!!!!!!!!!!", vrfCoordinator);
        vm.prank(USER1);
        raffle.enterRaffle{value: 1000000000000000000}();
        vm.warp(block.timestamp + 30);
        vm.roll(block.number + 1);

        vm.expectRevert(VRFCoordinatorV2_5Mock.InvalidRequest.selector);
        VRFCoordinatorV2_5Mock(vrfCoordinator).fulfillRandomWords(
            randomRequestId,
            address(raffle)
        );
    }

    function testFull() public {
        vm.prank(USER1);
        raffle.enterRaffle{value: 1000000000000000000}();
        vm.warp(block.timestamp + 30);
        vm.roll(block.number + 1);

        address expectedWinner = address(1);

        for (uint256 i = 1; i < 4; i++) {
            console2.log("New player created", i);
            address newPlayer = address(uint160(i));
            hoax(newPlayer, 3 ether);
            raffle.enterRaffle{value: 1000000000000000000}();
        }

        uint256 startTS = raffle.getLastTimeStamp();
        uint256 winnerSB = expectedWinner.balance;
        vm.recordLogs();
        raffle.performUpkeep("");
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 requestId = entries[1].topics[1];
        console2.log("Req id (as uint):", uint256(requestId));
        console2.log("Contract balance:", address(raffle).balance);
        console2.log("SUb id", subId);
        (uint96 balance, uint96 nativeBalance, , , ) = VRFCoordinatorV2_5Mock(
            vrfCoordinator
        ).getSubscription(
                7570848181127581986339189052072122886913734678723205985508750752041200654908
            );
        console2.log("LINK balance: ", balance);
        console2.log("ETH/native balance: ", nativeBalance);
        VRFCoordinatorV2_5Mock(vrfCoordinator).fulfillRandomWords(
            uint256(requestId),
            address(raffle)
        );

        address recentWinner = raffle.getRecentWinner();
        Raffle.STATUS state = raffle.getState();
        uint256 winnerBalance = recentWinner.balance;
        uint256 endingTimeStamp = raffle.getLastTimeStamp();
        uint256 prize = 1000000000000000000 * 4;

        console2.log("Ex winner: ", expectedWinner);
        console2.log("Recent winner: ", recentWinner);

        assert(recentWinner == expectedWinner);
        assert(winnerBalance == prize + winnerSB);
    }
}
