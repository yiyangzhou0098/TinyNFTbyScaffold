// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./MyNFTCollection.sol";

contract NFTCollectionFactory {
    event CollectionCreated(address indexed owner, address collectionAddress, string name, string symbol);

    mapping(address => address[]) public userCollections; // Track collections per user

    /**
     * @dev Deploy a new NFT collection.
     * @param name The name of the NFT collection.
     * @param symbol The symbol of the NFT collection.
     */
    function createCollection(string memory name, string memory symbol) public {
        MyNFTCollection collection = new MyNFTCollection(name, symbol, msg.sender);
        // collection.transferOwnership(msg.sender); // Transfer ownership to the caller

        userCollections[msg.sender].push(address(collection)); // Track user's collection
        emit CollectionCreated(msg.sender, address(collection), name, symbol);
    }

    /**
     * @dev Get all collections created by a user.
     * @param user The address of the user.
     * @return An array of collection addresses.
     */
    function getUserCollections(address user) public view returns (address[] memory) {
        return userCollections[user];
    }
}
