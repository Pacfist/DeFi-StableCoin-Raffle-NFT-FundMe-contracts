// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TempToken is ERC20 {
    constructor(uint256 _initialSupply) ERC20("TempToken", "TTK") {
        _mint(msg.sender, _initialSupply);
    }
}
