// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {console2} from "forge-std/console2.sol";
contract MoodNFT is ERC721, Ownable {
    enum Mood {
        HAPPY,
        SAD
    }

    mapping(uint256 => Mood) private s_tokenIdToMood;

    uint256 private s_tokenCounter;
    string private s_sadSvg;
    string private s_happySvg;

    constructor(
        string memory _sadSvgImgUri,
        string memory _happySvgImgUri,
        address _initialOwner
    ) ERC721("MoodNFT", "MOD") Ownable(_initialOwner) {
        s_tokenCounter = 0;
        s_sadSvg = _sadSvgImgUri;
        s_happySvg = _happySvgImgUri;
    }

    function mintNft() public {
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenIdToMood[s_tokenCounter] = Mood.HAPPY;
        s_tokenCounter++;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function flipMood(uint256 tokenId) public onlyOwner {
        if (s_tokenIdToMood[tokenId] == Mood.HAPPY) {
            console2.log("Flip to SAD");
            s_tokenIdToMood[tokenId] = Mood.SAD;
        } else {
            console2.log("Flip to HAPPY");
            s_tokenIdToMood[tokenId] = Mood.HAPPY;
        }
    }

    function tokenURI(
        uint256 tokenID
    ) public view override returns (string memory) {
        string memory imageURI;

        if (s_tokenIdToMood[tokenID] == Mood.HAPPY) {
            imageURI = s_happySvg;
        } else {
            imageURI = s_sadSvg;
        }

        return
            string(
                abi.encodePacked(
                    _baseURI(),
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                name(),
                                '", "description":"An NFT that reflects the mood of the owner, 100% on Chain!", ',
                                '"attributes": [{"trait_type": "moodiness", "value": 100}], "image":"',
                                imageURI,
                                '"}'
                            )
                        )
                    )
                )
            );
    }
}
