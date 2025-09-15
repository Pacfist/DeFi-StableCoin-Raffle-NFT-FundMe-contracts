// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {Test, console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {BagelToken} from "../src/BagelToken.sol";
import {ZkSyncChainChecker} from "foundry-devops/src/ZkSyncChainChecker.sol";
import {DeployMerkleAirdrop} from "../script/DeployMerkleAirdrop.sol";

contract MerkleAirdropTest is ZkSyncChainChecker, Test {
    MerkleAirdrop public merkleAirdrop;
    BagelToken public bagelToken;
    bytes32 public ROOT =
        0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;

    uint256 public AMOUNT = 25 * 1e18;

    bytes32 proof1 =
        0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 proof2 =
        0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;

    bytes32[] public proof = [proof1, proof2];

    address user;
    uint256 userPrivateKey;

    function setUp() public {
        if (!isZkSyncChain()) {
            DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
            (bagelToken, merkleAirdrop) = deployer.run();
        } else {
            vm.deal(user, 10 ether);
            bagelToken = new BagelToken();
            merkleAirdrop = new MerkleAirdrop(ROOT, bagelToken);
            bagelToken.mint(bagelToken.owner(), AMOUNT * 4);
            bagelToken.transfer(address(merkleAirdrop), AMOUNT * 4);
        }
        (user, userPrivateKey) = makeAddrAndKey("user");
    }

    function testUserCLaim() public {
        console.log("User address: ", user);

        vm.prank(user);
        merkleAirdrop.claim(user, AMOUNT, proof);

        uint256 endingBalance = bagelToken.balanceOf(user);
        console.log("Balance of user: ", endingBalance);
    }
}
