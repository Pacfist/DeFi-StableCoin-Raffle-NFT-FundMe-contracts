// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ManualToken {
    error NotEnoughBalance();

    mapping(address => uint256) private s_addressToBalance;

    function name() public pure returns (string memory) {
        return "Manual Token";
    }
    function symbol() public pure returns (string memory) {
        return "KNZ";
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function totalSupply() public pure returns (uint256) {
        return 100 ether;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        balance = s_addressToBalance[_owner];
    }

    function transfer(
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(s_addressToBalance[msg.sender] >= _value, NotEnoughBalance());
        uint256 prevBalance = s_addressToBalance[_to] +
            s_addressToBalance[msg.sender];

        s_addressToBalance[msg.sender] -= _value;
        s_addressToBalance[_to] += _value;
        if (
            s_addressToBalance[_to] + s_addressToBalance[msg.sender] ==
            prevBalance
        ) {
            return true;
        }
        return false;
    }
}
