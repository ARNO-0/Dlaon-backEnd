// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BasicNft is ERC721, Ownable {
    uint256 private s_tokenCounter;
    mapping(bytes32 => bool) public tokenIds;
    mapping(address => uint256[]) public tokensByAddress;

    constructor() ERC721("ARNO", "ARN") {
        uint256 tokenId = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))) %
            100000;
        _safeMint(msg.sender, tokenId);
        tokenIds[bytes32(tokenId)] = true;
        tokensByAddress[msg.sender].push(tokenId);
        s_tokenCounter = 1;
    }

    function safeMint() public {
        uint256 tokenId = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))) %
            100000;
        _safeMint(msg.sender, tokenId);
        tokenIds[bytes32(tokenId)] = true;
        tokensByAddress[msg.sender].push(tokenId);
        s_tokenCounter = s_tokenCounter + 1;
    }

    function getTokenIds(address _owner) public view returns (uint256[] memory) {
        return tokensByAddress[_owner];
    }

    function updateInfo(address from, address to, uint256 tokenId) public {
        require(tokenIds[bytes32(tokenId)], "Token ID not found");
        require(ownerOf(tokenId) == from, "Only the owner can transfer the NFT");
        uint256[] storage fromTokens = tokensByAddress[from];
        for (uint256 i = 0; i < fromTokens.length; i++) {
            if (fromTokens[i] == tokenId) {
                fromTokens[i] = fromTokens[fromTokens.length - 1];
                fromTokens.pop();
            }
        }
        tokensByAddress[to].push(tokenId);
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }

    function transferNft(address from, address _to, uint256 _tokenId) public {
        updateInfo(from, _to, _tokenId);
        safeTransferFrom(from, _to, _tokenId);
    }

    function ownerOfNft(uint256 tokenId) public view returns (address) {
        return ownerOf(tokenId);
    }

    function giveApproval(address to, uint256 tokenId) public {
        approve(to, tokenId);
    }
}
