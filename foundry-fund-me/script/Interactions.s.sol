// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";
contract FundFundMe is Script {
    uint256 constant SEND_VAL = 0.01 ether;

    function fundFundMe(address contractAddress) public {
        FundMe(payable(contractAddress)).fund{value: SEND_VAL}();

        console.log("Funded FundMe with %s", SEND_VAL);
    }

    function run() external {
        address contractAddress = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        vm.startBroadcast();
        fundFundMe(contractAddress);
        vm.stopBroadcast();
        // FundMe fundMe = FundMe(contractAddress);
        // fundMe.doSomething();
    }
}

contract WithdrawFundMe is Script {}
