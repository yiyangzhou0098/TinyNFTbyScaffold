// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./MyNFTCollection.sol";

contract NFTCollectionsFactory {
    event CollectionCreated(address indexed owner, address indexed collectionAddress, string name, string symbol);

    struct CollectionInfo {
        address collectionAddress;
        string name;
        string symbol;
        address owner;
    }

    address public latestCollection;

    mapping(address => CollectionInfo[]) public userCollections;
    /**
     * @dev Deploy a new NFT collection.
     * @param name The name of the NFT collection.
     * @param symbol The symbol of the NFT collection.
     */
    function createYourCollection(string memory name, string memory symbol) public {
        MyNFTCollection collection = new MyNFTCollection(name, symbol, msg.sender);

        CollectionInfo memory newCollection = CollectionInfo({
            collectionAddress: address(collection),
            name: name,
            symbol: symbol,
            owner: msg.sender
        });
        
        userCollections[msg.sender].push(
            newCollection
        );

        emit CollectionCreated(msg.sender, address(collection), name, symbol);
    }

    /**
     * @dev Get all collections created by a user.
     * @param user The address of the user.
     * @return An array of collection addresses.
     */
    function getUserCollections(address user) public view returns (CollectionInfo[] memory) {
        return userCollections[user];
    }


}
