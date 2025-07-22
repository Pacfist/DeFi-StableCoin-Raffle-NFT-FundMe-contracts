// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract BasicNFT is ERC721 {
    uint256 private s_tokenCounter;
    mapping(uint256 => string) private s_idToUri;

    constructor() ERC721("BasicNFT", "APL") {
        s_tokenCounter = 0;
    }

    function mintNft(string memory tokenUri) public {
        s_idToUri[s_tokenCounter] = tokenUri;
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenCounter++;
    }

    function tokenURI(
        uint256 tokenID
    ) public view override returns (string memory) {
        return s_idToUri[tokenID];
    }
}
