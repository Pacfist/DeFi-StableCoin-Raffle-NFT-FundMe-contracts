// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";
import {FundFundMe} from "../script/Interactions.s.sol";
contract InteractionsTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, 10 ether);
    }

    function testFundInt() public {
        FundFundMe fundFundMe = new FundFundMe();
        vm.prank(USER);

        fundFundMe.fundFundMe(address(fundMe));

        address funder = fundMe.getFunder(0);
        console.log(funder);
        console.log(USER);
        assertEq(funder, USER);
    }
}
