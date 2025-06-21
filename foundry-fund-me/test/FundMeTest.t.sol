// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    function setUp() external {
        fundMe = new FundMe(0x89Fe3AA7844D3954846003AB3284f3D3320f0a1E);
    }
    function test2() public {
        uint256 version = fundMe.
    }
}
