// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
/**
 * @title A sample Raffle contarct
 * @author Matvey Knyazev
 */
contract Raffle {
    error NotEnoughtEthSent();

    uint256 private immutable i_entranceFee;
    uint256 public immutable i_interval;
    uint256 private lastTimeStamp;
    address payable[] private players;
    mapping(address => uint256) public senderToAmount;

    event RaffleEnter(address indexed player);

    constructor(uint256 _entranceFee, uint256 _interval) {
        i_entranceFee = _entranceFee;
        i_interval = _interval;
        lastTimeStamp = block.timestamp;
    }

    function enterRaffle() public payable {
        //require(msg.value >= i_entranceFee, NotEnoughtEthSent());
        if (msg.value < i_entranceFee) {
            revert NotEnoughtEthSent();
        }
        players.push(payable(msg.sender));
        senderToAmount[msg.sender] += msg.value;
        emit RaffleEnter(msg.sender);
    }

    function pickWinner() public {
        if (block.timestamp - lastTimeStamp < i_interval) {
            revert();
        }
    }

    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}
