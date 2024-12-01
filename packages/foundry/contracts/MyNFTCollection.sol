// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyNFTCollection is ERC721URIStorage, Ownable {
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

    /**
     * @dev Mint a new NFT.
     * @param recipient The address of the recipient.
     * @param tokenURI The metadata URI (e.g., IPFS URL).
     */
    function mintNFT(address recipient, string memory tokenURI) public onlyOwner returns (uint256) {
        uint256 tokenId = _nextTokenId;
        _nextTokenId++;
        _mint(recipient, tokenId);
        _setTokenURI(tokenId, tokenURI);
        return tokenId;
    }
}
