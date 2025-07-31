// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract StableCoin is ERC20Burnable, Ownable {
    error StableCoint__MustBeMoreThanZero();
    error StableCoint__BurnAmountExceedsBalance();
    error StableCoint__NotZeroAddress();

    constructor(address _owner) ERC20("StableCoint", "SCT") Ownable(_owner) {}

    function burn(uint256 _amount) public override onlyOwner {
        uint256 balance = balanceOf(msg.sender);
        if (_amount <= 0) {
            revert StableCoint__MustBeMoreThanZero();
        }
        if (balance < _amount) {
            revert StableCoint__BurnAmountExceedsBalance();
        }
        super.burn(_amount);
    }

    function mint(
        address _to,
        uint256 _amount
    ) external onlyOwner returns (bool) {
        if (_to == address(0)) {
            revert StableCoint__NotZeroAddress();
        }
        if (_amount <= 0) {
            revert StableCoint__MustBeMoreThanZero();
        }
        _mint(_to, _amount);
        return true;
    }
}
