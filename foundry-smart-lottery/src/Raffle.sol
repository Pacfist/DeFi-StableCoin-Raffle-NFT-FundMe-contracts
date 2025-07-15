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
    error TransferFailed();
    error RaffleNotOpen();
    error UpkeepNotNeeded(
        uint256 balance,
        uint256 playersLength,
        uint256 state
    );

    enum STATUS {
        OPEN,
        CALCULATING
    }

    uint256 private immutable i_entranceFee;
    uint256 public immutable i_interval;
    uint256 private lastTimeStamp;
    bytes32 private immutable i_keyHash;
    uint256 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    STATUS private s_lotteryState;

    mapping(address => uint256) public senderToAmount;
    address payable[] private players;
    address payable recentWinner;

    event RaffleEnter(address indexed player);
    event WinnerPicked(address indexed winner);
    event RequestedRaffleWinner(uint256 indexed requestID);

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
        s_lotteryState = STATUS.OPEN;
    }

    function enterRaffle() public payable {
        //require(msg.value >= i_entranceFee, NotEnoughtEthSent());
        if (s_lotteryState != STATUS.OPEN) {
            revert RaffleNotOpen();
        }
        if (msg.value < i_entranceFee) {
            revert NotEnoughtEthSent();
        }

        players.push(payable(msg.sender));
        senderToAmount[msg.sender] += msg.value;
        emit RaffleEnter(msg.sender);
    }

    function checkUpkeep(
        bytes memory /* checkData */
    ) public view returns (bool upkeepNeeded, bytes memory /* performData */) {
        bool timeHasPassed = (block.timestamp - lastTimeStamp) >= i_interval;
        bool isOpen = s_lotteryState == STATUS.OPEN;
        bool isMoney = address(this).balance > 0;
        bool arePlayers = players.length > 0;
        upkeepNeeded = timeHasPassed && isOpen && isMoney && arePlayers;
        return (upkeepNeeded, hex"");
    }

    function performUpkeep(bytes calldata /*perofrmData*/) external {
        (bool upkeepNeeded, ) = checkUpkeep("");
        if (!upkeepNeeded) {
            revert UpkeepNotNeeded(
                address(this).balance,
                players.length,
                uint256(s_lotteryState)
            );
        }
        s_lotteryState = STATUS.CALCULATING;
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

        emit RequestedRaffleWinner(requestID);
    }

    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }

    function fulfillRandomWords(
        uint256 /*requestId*/,
        uint256[] calldata randomWords
    ) internal override {
        uint256 indexOfWinner = randomWords[0] % players.length;
        recentWinner = players[indexOfWinner];

        players = new address payable[](0);
        s_lotteryState = STATUS.OPEN;
        lastTimeStamp = block.timestamp;

        (bool callSuc, ) = recentWinner.call{value: address(this).balance}("");
        if (!callSuc) {
            revert TransferFailed();
        }

        emit WinnerPicked(recentWinner);
    }

    //GET FUNCTIONS

    function getState() public view returns (STATUS) {
        return s_lotteryState;
    }

    function getPlayers() external view returns (address payable[] memory) {
        return players;
    }

    function getLastTimeStamp() public view returns (uint256) {
        return lastTimeStamp;
    }

    function getRecentWinner() public view returns (address) {
        return recentWinner;
    }
}
