// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC721URIStorage, ERC721} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract MyNFTCollection is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
    uint256 public _nextTokenId;

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

    /**
     * @dev Override `_increaseBalance` to explicitly call ERC721's implementation.
     */
    function _increaseBalance(address account, uint128 amount) internal override(ERC721, ERC721Enumerable) {
        unchecked {
            super._increaseBalance(account, amount); // Call ERC721 implementation
        }
    }

    /**
     * @dev Override `_update` to resolve conflicts and delegate to `ERC721`.
     */
    function _update(address to, uint256 tokenId, address auth)
        internal
        virtual
        override(ERC721, ERC721Enumerable)
        returns (address)
    {
        return ERC721Enumerable._update(to, tokenId, auth); // Use ERC721Enumerable's implementation
    }

    function supportsInterface(
		bytes4 interfaceId
	)
		public
		view
		override(ERC721, ERC721URIStorage, ERC721Enumerable)
		returns (bool)
	{
		return super.supportsInterface(interfaceId);
	}

}