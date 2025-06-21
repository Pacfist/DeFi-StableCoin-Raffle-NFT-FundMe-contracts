// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {PriceConverter} from "./PriceConverter.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";

contract FundMe is Ownable {
    using PriceConverter for uint256;

    uint256 public constant MINUSD = 5 * (10 ** 18);

    address[] public funders;
    mapping(address => uint256) public fundersAndMoney;

    uint256 public getMinimumDeposit = (1e36 * 5) / PriceConverter.getPrice();

    constructor(address initialOwner) Ownable(initialOwner) {}
    function fund() public payable {
        require(msg.value.getConversionRate() >= MINUSD, "Not enough eth!");
        funders.push(msg.sender);
        fundersAndMoney[msg.sender] += msg.value;
    }
    function withdraw() public onlyOwner {
        for (uint256 i = 0; i < funders.length; i++) {
            address funder = funders[i];
            fundersAndMoney[funder] = 0;
        }
        funders = new address[](0);
        //transfer
        //payable(msg.sender).transfer(address(this).balance);

        //send
        //bool sendSuccess =  payable(msg.sender).send(address(this).balance);
        //require(sendSuccess, "Error during sending");

        (bool callSuc, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuc, "Call failed");
    }

    function balanceOfContract() public view returns (uint256) {
        return address(this).balance;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}
