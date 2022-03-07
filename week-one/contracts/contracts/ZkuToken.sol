// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

interface MerkleTree {
    function addLeave(bytes32 newLeave) external;
}

/// @custom:security-contact holtzs.william@gmail.com
contract ZkuToken is ERC721, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    MerkleTree merkleTreeContract;

    constructor(address merkleTreeAddress_) ERC721("ZkuToken", "ZKU") {
        merkleTreeContract = MerkleTree(merkleTreeAddress_);
    }

    function changeMerkleAddress(address merkleTreeAddress_) public onlyOwner {
        merkleTreeContract = MerkleTree(merkleTreeAddress_);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        if (!_exists(tokenId)) revert("ERC721: token does not exist");

        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "ZKU #',
            Strings.toString(tokenId),
            '", ',
            '"description": "ERC721 ZKU Optimized token #',
            Strings.toString(tokenId),
            '"',
            "}"
        );

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(dataURI)
                )
            );
    }

    function mint() public {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        merkleTreeContract.addLeave(
            keccak256(abi.encodePacked(from, to, tokenId, tokenURI(tokenId)))
        );
    }

    function safeMint(address to) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }
}
