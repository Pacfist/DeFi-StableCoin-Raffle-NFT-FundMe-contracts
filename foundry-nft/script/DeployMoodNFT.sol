// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {Script} from "forge-std/Script.sol";
import {MoodNFT} from "../src/MoodNft.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {console2} from "forge-std/console2.sol";

contract DeployMoodNft is Script {
    function run() external returns (MoodNFT) {
        string memory sadSvg = vm.readFile("./img/sad.svg");
        string memory happySvg = vm.readFile("./img/happy.svg");

        address owner = 0x89Fe3AA7844D3954846003AB3284f3D3320f0a1E;
        vm.startBroadcast();
        MoodNFT moodNft = new MoodNFT(
            svgToImgURI(sadSvg),
            svgToImgURI(happySvg),
            owner
        );
        vm.stopBroadcast();
        return moodNft;
    }

    function svgToImgURI(
        string memory svg
    ) public pure returns (string memory) {
        string memory baseUrl = "data:image/svg+xml;base64,";
        return
            string(
                abi.encodePacked(
                    baseUrl,
                    (Base64.encode(bytes(string(abi.encodePacked(svg)))))
                )
            );
    }
}
