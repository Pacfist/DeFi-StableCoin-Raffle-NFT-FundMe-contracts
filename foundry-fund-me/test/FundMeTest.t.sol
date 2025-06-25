// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";
contract FundMeTest is Test {
    FundMe fundMe;

    function setUp() external {
        // fundMe = new FundMe(0x89Fe3AA7844D3954846003AB3284f3D3320f0a1E, 0x694AA1769357215DE4FAC081bf1f309aDC325306);

        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }
    function test1() public {
        uint256 version = fundMe.getVersion();
        console.log(version);
        assertEq(version, 4);
    }

    // function test2() public {
    //     uint256 price = fundMe.getPriceFundMe();
    //     console.log(price);
    // }
}
