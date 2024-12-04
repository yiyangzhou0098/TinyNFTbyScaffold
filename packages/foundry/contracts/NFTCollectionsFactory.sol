// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./MyNFTCollection.sol";

contract NFTCollectionsFactory {
    event CollectionCreated(address indexed owner, address indexed collectionAddress, string name, string symbol);

    struct CollectionInfo {
        address collectionAddress;
    }

    mapping(address => CollectionInfo[]) public userCollections;
    /**
     * @dev Deploy a new NFT collection.
     * @param name The name of the NFT collection.
     * @param symbol The symbol of the NFT collection.
     */
    function createYourCollection(string memory name, string memory symbol) public {
        MyNFTCollection collection = new MyNFTCollection(name, symbol, msg.sender);

        userCollections[msg.sender].push(CollectionInfo({
            collectionAddress: address(collection)
        }));

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
