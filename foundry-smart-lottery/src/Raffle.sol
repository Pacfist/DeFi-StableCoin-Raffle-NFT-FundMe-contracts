// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
/**
 * @title A sample Raffle contarct
 * @author Matvey Knyazev
 */
contract Raffle {
    error NotEnoughtEthSent();

    uint256 private immutable i_entranceFee;
    mapping(address => uint256) public senderToAmount;
    constructor(uint256 _entranceFee) {
        i_entranceFee = _entranceFee;
    }

    function enterRaffle() public payable {
        require(msg.value >= i_entranceFee, NotEnoughtEthSent());
    }

    function pickWinner() public {}

    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}
