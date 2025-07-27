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

    string public constant SAD_IMG_SVG_URI =
        "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMzAwIiBoZWlnaHQ9IjMwMCIgdmlld0JveD0iMCAwIDMwMCAzMDAiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CiAgPGRlZnM+CiAgICA8cmFkaWFsR3JhZGllbnQgaWQ9ImdyYWQiIGN4PSI1MCUiIGN5PSI1MCUiIHI9IjgwJSI+CiAgICAgIDxzdG9wIG9mZnNldD0iMCUiIHN0b3AtY29sb3I9IiNmZjlhOWUiIC8+CiAgICAgIDxzdG9wIG9mZnNldD0iNTAlIiBzdG9wLWNvbG9yPSIjZmFkMGM0IiAvPgogICAgICA8c3RvcCBvZmZzZXQ9IjEwMCUiIHN0b3AtY29sb3I9IiNmYWQwYzQiIC8+CiAgICA8L3JhZGlhbEdyYWRpZW50PgogICAgPGZpbHRlciBpZD0iYmx1ciIgeD0iLTIwJSIgeT0iLTIwJSIgd2lkdGg9IjE0MCUiIGhlaWdodD0iMTQwJSI+CiAgICAgIDxmZUdhdXNzaWFuQmx1ciBzdGREZXZpYXRpb249IjIwIiAvPgogICAgPC9maWx0ZXI+CiAgPC9kZWZzPgoKICA8Y2lyY2xlIGN4PSIxNTAiIGN5PSIxNTAiIHI9IjEwMCIgZmlsbD0idXJsKCNncmFkKSIgZmlsdGVyPSJ1cmwoI2JsdXIpIiAvPgogIDxwYXRoIGQ9Ik0xMjAgMTgwIFExNTAgMTAwIDE4MCAxODAgVDI0MCAxODAiIHN0cm9rZT0iI2ZmZiIgc3Ryb2tlLXdpZHRoPSI2IiBmaWxsPSJub25lIiAvPgogIDxjaXJjbGUgY3g9IjEyMCIgY3k9IjEzMCIgcj0iMTAiIGZpbGw9IiNmZmYiIC8+CiAgPGNpcmNsZSBjeD0iMTgwIiBjeT0iMTMwIiByPSIxMCIgZmlsbD0iI2ZmZiIgLz4KPC9zdmc+Cg==";
    string public constant SAD_SVG_URI =
        "data:application/json;base64,eyJuYW1lIjoiTW9vZE5GVCIsICJkZXNjcmlwdGlvbiI6IkFuIE5GVCB0aGF0IHJlZmxlY3RzIHRoZSBtb29kIG9mIHRoZSBvd25lciwgMTAwJSBvbiBDaGFpbiEiLCAiYXR0cmlidXRlcyI6IFt7InRyYWl0X3R5cGUiOiAibW9vZGluZXNzIiwgInZhbHVlIjogMTAwfV0sICJpbWFnZSI6ImRhdGE6aW1hZ2Uvc3ZnK3htbDtiYXNlNjQsUEhOMlp5QjNhV1IwYUQwaU16QXdJaUJvWldsbmFIUTlJak13TUNJZ2RtbGxkMEp2ZUQwaU1DQXdJRE13TUNBek1EQWlJSGh0Ykc1elBTSm9kSFJ3T2k4dmQzZDNMbmN6TG05eVp5OHlNREF3TDNOMlp5SStDaUFnUEdSbFpuTStDaUFnSUNBOGNtRmthV0ZzUjNKaFpHbGxiblFnYVdROUltZHlZV1FpSUdONFBTSTFNQ1VpSUdONVBTSTFNQ1VpSUhJOUlqZ3dKU0krQ2lBZ0lDQWdJRHh6ZEc5d0lHOW1abk5sZEQwaU1DVWlJSE4wYjNBdFkyOXNiM0k5SWlObVpqbGhPV1VpSUM4K0NpQWdJQ0FnSUR4emRHOXdJRzltWm5ObGREMGlOVEFsSWlCemRHOXdMV052Ykc5eVBTSWpabUZrTUdNMElpQXZQZ29nSUNBZ0lDQThjM1J2Y0NCdlptWnpaWFE5SWpFd01DVWlJSE4wYjNBdFkyOXNiM0k5SWlObVlXUXdZelFpSUM4K0NpQWdJQ0E4TDNKaFpHbGhiRWR5WVdScFpXNTBQZ29nSUNBZ1BHWnBiSFJsY2lCcFpEMGlZbXgxY2lJZ2VEMGlMVEl3SlNJZ2VUMGlMVEl3SlNJZ2QybGtkR2c5SWpFME1DVWlJR2hsYVdkb2REMGlNVFF3SlNJK0NpQWdJQ0FnSUR4bVpVZGhkWE56YVdGdVFteDFjaUJ6ZEdSRVpYWnBZWFJwYjI0OUlqSXdJaUF2UGdvZ0lDQWdQQzltYVd4MFpYSStDaUFnUEM5a1pXWnpQZ29LSUNBOFkybHlZMnhsSUdONFBTSXhOVEFpSUdONVBTSXhOVEFpSUhJOUlqRXdNQ0lnWm1sc2JEMGlkWEpzS0NObmNtRmtLU0lnWm1sc2RHVnlQU0oxY213b0kySnNkWElwSWlBdlBnb2dJRHh3WVhSb0lHUTlJazB4TWpBZ01UZ3dJRkV4TlRBZ01UQXdJREU0TUNBeE9EQWdWREkwTUNBeE9EQWlJSE4wY205clpUMGlJMlptWmlJZ2MzUnliMnRsTFhkcFpIUm9QU0kySWlCbWFXeHNQU0p1YjI1bElpQXZQZ29nSUR4amFYSmpiR1VnWTNnOUlqRXlNQ0lnWTNrOUlqRXpNQ0lnY2owaU1UQWlJR1pwYkd3OUlpTm1abVlpSUM4K0NpQWdQR05wY21Oc1pTQmplRDBpTVRnd0lpQmplVDBpTVRNd0lpQnlQU0l4TUNJZ1ptbHNiRDBpSTJabVppSWdMejRLUEM5emRtYytDZz09In0=";
    function setUp() public {
        vm.deal(USER, 10 ether);
        deployer = new DeployMoodNft();
        moodNft = deployer.run();
    }

    // function testViewTokenURI() public {
    //     vm.prank(USER);
    //     moodNft.mintNft();
    //     console2.log(moodNft.tokenURI(0));
    // }

    function testFlipMood() public {
        vm.prank(USER);
        moodNft.mintNft();

        vm.prank(0x89Fe3AA7844D3954846003AB3284f3D3320f0a1E);
        moodNft.flipMood(0);
        console2.log("TOKEN URI ---------------: ", moodNft.tokenURI(0));
        assertEq(
            keccak256(abi.encodePacked(moodNft.tokenURI(0))),
            keccak256(abi.encodePacked(SAD_SVG_URI))
        );
    }
}
