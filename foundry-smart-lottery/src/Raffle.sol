// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

/**
 * @title A sample Raffle contarct
 * @author Matvey Knyazev
 */
contract Raffle is VRFConsumerBaseV2Plus {
    error NotEnoughtEthSent();

    uint256 private immutable i_entranceFee;
    uint256 public immutable i_interval;
    uint256 private lastTimeStamp;
    address payable[] private players;
    bytes32 private immutable i_keyHash;
    uint256 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    mapping(address => uint256) public senderToAmount;

    event RaffleEnter(address indexed player);

    constructor(
        uint256 _entranceFee,
        uint256 _interval,
        address _vrfCoordinator,
        bytes32 _gasLane,
        uint256 _subscriptionId,
        uint32 _callbackGasLimit
    ) VRFConsumerBaseV2Plus(_vrfCoordinator) {
        i_entranceFee = _entranceFee;
        i_interval = _interval;
        lastTimeStamp = block.timestamp;
        i_keyHash = _gasLane;
        i_subscriptionId = _subscriptionId;
        i_callbackGasLimit = _callbackGasLimit;
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

        uint256 requestID = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: i_keyHash, // Gas lane / key hash to use
                subId: i_subscriptionId, // Subscription ID or 0 for direct funding
                requestConfirmations: 3, // Recommended: at least 3
                callbackGasLimit: i_callbackGasLimit, // Adjust as needed for your callback
                numWords: 1, // Number of random words to request
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({
                        nativePayment: true // Set to true for gas-token (e.g., ETH) payment
                    })
                )
            })
        );
    }

    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] calldata randomWords
    ) internal override {}
}
