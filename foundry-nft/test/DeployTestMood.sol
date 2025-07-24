// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.8;

// import {Test} from "forge-std/Test.sol";
// import {MoodNFT} from "../src/MoodNft.sol";
// import {DeployMoodNft} from "../script/DeployMoodNFT.sol";
// import {console2} from "forge-std/console2.sol";

// contract MoodNFTtest is Test {
//     MoodNFT moodNft;
//     DeployMoodNft public deployer;
//     function setUp() public {
//         deployer = new DeployMoodNft();
//     }

//     function testSvgToUri() public {
//         string memory uri = deployer.svgToImgURI(
//             '<svg xmlns="http://www.w3.org/2000/svg" width="50" height="50"><circle cx="25" cy="25" r="20" fill="yellow"/><circle cx="18" cy="20" r="2" fill="black"/><circle cx="32" cy="20" r="2" fill="black"/><path d="M18 30 Q25 35 32 30" stroke="black" fill="none"/></svg>'
//         );
//         console2.log(uri);
//     }
// }
