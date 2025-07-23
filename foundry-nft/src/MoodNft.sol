// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract MoodNFT is ERC721 {
    uint256 private s_tokenCounter;
    string private s_sadSvg;
    string private s_happySvg;
    constructor(
        string memory _sadSvgImgUri,
        string memory _happySvgImgUri
    ) ERC721("MoodNFT", "MOD") {
        s_tokenCounter = 0;
        s_sadSvg = _sadSvgImgUri;
        s_happySvg = _happySvgImgUri;
    }

    function mintNft() public {
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenCounter++;
    }

    function tokenURI(
        uint256 tokenID
    ) public view override returns (string memory) {
        string memory tokenMetada = string.concat('{"name": "', name(), '"}');
    }
}
