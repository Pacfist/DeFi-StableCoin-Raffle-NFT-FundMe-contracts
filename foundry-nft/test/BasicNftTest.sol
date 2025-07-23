// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {Test} from "forge-std/Test.sol";
import {BasicNFT} from "../src/BasicNFT.sol";
import {DeployNft} from "../script/DeployBasicNft.sol";
import {console2} from "forge-std/console2.sol";

contract BasicNFTtest is Test {
    BasicNFT public basicNft;
    string public constant apple =
        "https://bafybeiglgrgcvbbmqd2irhjguhooedv62k23pxhcajlbq7d5xzliuc3j6e.ipfs.dweb.link?filename=apple.jpg";
    address public USER = makeAddr("user");

    function setUp() public {
        DeployNft deployNFT = new DeployNft();
        basicNft = deployNFT.run();
    }

    function testName() public view {
        string memory actualName = basicNft.name();
        console2.log(actualName);
        assert(
            keccak256(abi.encodePacked(actualName)) ==
                keccak256(abi.encodePacked("BasicNFT"))
        );
    }

    function testCanMint() public {
        vm.prank(USER);
        basicNft.mintNft(apple);

        assert(basicNft.balanceOf(USER) == 1);
        assert(
            keccak256(abi.encodePacked(apple)) ==
                keccak256(abi.encodePacked(basicNft.tokenURI(0)))
        );
    }
}
