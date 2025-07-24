// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {Test} from "forge-std/Test.sol";
import {MoodNFT} from "../src/MoodNft.sol";
import {DeployMoodNft} from "../script/DeployMoodNFT.sol";
import {console2} from "forge-std/console2.sol";

contract MoodNFTtest is Test {
    MoodNFT moodNft;
    address public USER = makeAddr("user");
    DeployMoodNft public deployer;

    string public constant HAPPY_SVG_URI =
        "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAwIiBoZWlnaHQ9IjIwMCIgdmlld0JveD0iMCAwIDIwMCAyMDAiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CiAgPGRlZnM+CiAgICA8cmFkaWFsR3JhZGllbnQgaWQ9ImJnIiBjeD0iNTAlIiBjeT0iNTAlIiByPSI1MCUiPgogICAgICA8c3RvcCBvZmZzZXQ9IjAlIiBzdG9wLWNvbG9yPSIjZmRmNmUzIi8+CiAgICAgIDxzdG9wIG9mZnNldD0iMTAwJSIgc3RvcC1jb2xvcj0iI2ZmZTBlNiIvPgogICAgPC9yYWRpYWxHcmFkaWVudD4KICA8L2RlZnM+CgogIDxjaXJjbGUgY3g9IjEwMCIgY3k9IjEwMCIgcj0iOTUiIGZpbGw9InVybCgjYmcpIiBzdHJva2U9IiNmZmNhZDQiIHN0cm9rZS13aWR0aD0iNCIvPgoKICA8IS0tIEV5ZXMgLS0+CiAgPGNpcmNsZSBjeD0iNzAiIGN5PSI4MCIgcj0iOCIgZmlsbD0iIzMzMyIgLz4KICA8Y2lyY2xlIGN4PSIxMzAiIGN5PSI4MCIgcj0iOCIgZmlsbD0iIzMzMyIgLz4KCiAgPCEtLSBTbWlsZSAtLT4KICA8cGF0aCBkPSJNIDYwIDEyMCBRIDEwMCAxNjAgMTQwIDEyMCIgc3Ryb2tlPSIjMzMzIiBzdHJva2Utd2lkdGg9IjUiIGZpbGw9Im5vbmUiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgLz4KCiAgPCEtLSBEaW1wbGVzIC0tPgogIDxjaXJjbGUgY3g9IjU1IiBjeT0iMTIwIiByPSIyIiBmaWxsPSIjYWFhIi8+CiAgPGNpcmNsZSBjeD0iMTQ1IiBjeT0iMTIwIiByPSIyIiBmaWxsPSIjYWFhIi8+Cjwvc3ZnPg==";

    string public constant SAD_SVG_URI =
        "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMzAwIiBoZWlnaHQ9IjMwMCIgdmlld0JveD0iMCAwIDMwMCAzMDAiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CiAgPGRlZnM+CiAgICA8cmFkaWFsR3JhZGllbnQgaWQ9ImdyYWQiIGN4PSI1MCUiIGN5PSI1MCUiIHI9IjgwJSI+CiAgICAgIDxzdG9wIG9mZnNldD0iMCUiIHN0b3AtY29sb3I9IiNmZjlhOWUiIC8+CiAgICAgIDxzdG9wIG9mZnNldD0iNTAlIiBzdG9wLWNvbG9yPSIjZmFkMGM0IiAvPgogICAgICA8c3RvcCBvZmZzZXQ9IjEwMCUiIHN0b3AtY29sb3I9IiNmYWQwYzQiIC8+CiAgICA8L3JhZGlhbEdyYWRpZW50PgogICAgPGZpbHRlciBpZD0iYmx1ciIgeD0iLTIwJSIgeT0iLTIwJSIgd2lkdGg9IjE0MCUiIGhlaWdodD0iMTQwJSI+CiAgICAgIDxmZUdhdXNzaWFuQmx1ciBzdGREZXZpYXRpb249IjIwIiAvPgogICAgPC9maWx0ZXI+CiAgPC9kZWZzPgoKICA8Y2lyY2xlIGN4PSIxNTAiIGN5PSIxNTAiIHI9IjEwMCIgZmlsbD0idXJsKCNncmFkKSIgZmlsdGVyPSJ1cmwoI2JsdXIpIiAvPgogIDxwYXRoIGQ9Ik0xMjAgMTgwIFExNTAgMTAwIDE4MCAxODAgVDI0MCAxODAiIHN0cm9rZT0iI2ZmZiIgc3Ryb2tlLXdpZHRoPSI2IiBmaWxsPSJub25lIiAvPgogIDxjaXJjbGUgY3g9IjEyMCIgY3k9IjEzMCIgcj0iMTAiIGZpbGw9IiNmZmYiIC8+CiAgPGNpcmNsZSBjeD0iMTgwIiBjeT0iMTMwIiByPSIxMCIgZmlsbD0iI2ZmZiIgLz4KPC9zdmc+Cg==";

    function setUp() public {
        vm.deal(USER, 10 ether);
        deployer = new DeployMoodNft();
        moodNft = deployer.run();
    }

    function testViewTokenURI() public {
        vm.prank(USER);
        moodNft.mintNft();
        console2.log(moodNft.tokenURI(0));
    }

    function testFlipMood() public {
        vm.prank(USER);
        moodNft.mintNft();

        vm.prank(0x89Fe3AA7844D3954846003AB3284f3D3320f0a1E);
        moodNft.flipMood(0);

        assertEq(
            keccak256(abi.encodePacked(moodNft.tokenURI(0))),
            keccak256(abi.encodePacked(SAD_SVG_URI))
        );
    }
}
