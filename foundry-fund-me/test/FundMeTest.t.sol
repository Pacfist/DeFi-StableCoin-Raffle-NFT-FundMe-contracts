// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";
contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    function setUp() external {
        // fundMe = new FundMe(0x89Fe3AA7844D3954846003AB3284f3D3320f0a1E, 0x694AA1769357215DE4FAC081bf1f309aDC325306);

        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        console.log(msg.sender);
        vm.deal(USER, 10 ether);
    }
    function test1() public {
        uint256 version = fundMe.getVersion();
        console.log(version);
        assertEq(version, 4);
    }

    function testgetMinimumDeposit() public {
        uint256 minDep = fundMe.getMinimumDeposit();
        console.log(minDep);
        assertEq(minDep, 2.5e15);
    }

    function testGetPrice() public {
        console.log(fundMe.getPriceFundMe());
    }

    function testFund() public {
        vm.prank(USER);
        uint256 valueToCheck = 10e18;
        fundMe.fund{value: valueToCheck}();
        console.log(fundMe.balanceOfContract());
        console.log(msg.sender);
        console.log(address(this));
        //console.log(balanceOf(USER));
        console.log(fundMe.owner());
        assertEq(fundMe.balanceOfContract(), valueToCheck);
    }

    function testWithdraw() public {
        vm.prank(USER);
        console.log(USER.balance);
        uint256 valueToCheck = 10e18;
        fundMe.fund{value: valueToCheck}();
        console.log(fundMe.balanceOfContract());

        vm.startPrank(fundMe.owner());
        fundMe.withdraw();
        console.log(fundMe.balanceOfContract());

        assertEq(address(fundMe).balance, 0);
    }
}
