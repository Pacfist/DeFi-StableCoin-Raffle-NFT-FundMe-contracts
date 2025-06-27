// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {PriceConverter} from "./PriceConverter.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract FundMe is Ownable {
    using PriceConverter for uint256;

    uint256 public constant MINUSD = 5 * 1e18;

    address[] public funders;
    mapping(address => uint256) public fundersAndMoney;

    AggregatorV3Interface private immutable i_pricefeed;

    constructor(address initialOwner, address priceFeed) Ownable(initialOwner) {
        i_pricefeed = AggregatorV3Interface(priceFeed);
    }

    function getFunder(uint256 _index) public view returns (address) {
        return funders[_index];
    }

    function getMinimumDeposit() public view returns (uint256) {
        return
            (MINUSD * 1e18) /
            PriceConverter.getPrice(
                AggregatorV3Interface(address(i_pricefeed))
            );
    }

    function getVersion() public view returns (uint256) {
        return i_pricefeed.version();
    }

    function fund() public payable {
        require(
            msg.value.getConversionRate(i_pricefeed) >= MINUSD,
            "Not enough eth!"
        );
        funders.push(msg.sender);
        fundersAndMoney[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        uint256 fundersLenght = funders.length;
        for (uint256 i = 0; i < fundersLenght; i++) {
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

    function getPriceFundMe() public view returns (uint256) {
        return
            PriceConverter.getPrice(
                AggregatorV3Interface(address(i_pricefeed))
            );
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}
