// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC721URIStorage, ERC721} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyNFTCollection is ERC721, ERC721URIStorage, Ownable {
    uint256 private _nextTokenId;

    /**
     * @dev Constructor that initializes the contract with a `name` and `symbol` for the NFT collection
     * and sets the initial owner.
     * @param name The name of the NFT collection.
     * @param symbol The symbol of the NFT collection.
     * @param initialOwner The initial owner of the contract.
     */
    constructor(string memory name, string memory symbol, address initialOwner)
        ERC721(name, symbol)
        Ownable(initialOwner) // Pass the initial owner to the `Ownable` constructor
    {}

    function _baseURI() internal pure override returns (string memory) {
		return "https://ipfs.io/ipfs/";
	}

    /**
     * @dev Mint a new NFT.
     * @param recipient The address of the recipient.
     * @param tURI The metadata URI (e.g., IPFS URL).
     */
    function mintNFT(address recipient, string memory tURI) public onlyOwner returns (uint256) {
        uint256 tokenId = _nextTokenId;
        _nextTokenId++;
        _mint(recipient, tokenId);
        _setTokenURI(tokenId, tURI);
        return tokenId;
    }

    function tokenURI(
		uint256 tokenId
	) public view override(ERC721, ERC721URIStorage) returns (string memory) {
		return super.tokenURI(tokenId);
	}

    function supportsInterface(
		bytes4 interfaceId
	)
		public
		view
		override(ERC721, ERC721URIStorage)
		returns (bool)
	{
		return super.supportsInterface(interfaceId);
	}

}