// SPDX-License-Identifier: MIT
// pragma solidity ^0.8.19;

// import "forge-std/Test.sol";
// import "../contracts/NFTCollectionFactory.sol";
// import "../contracts/MyNFTCollection.sol";

// contract NFTCollectionFactoryTest is Test {
//     NFTCollectionFactory factory; // Instance of NFTCollectionFactory
//     address deployer; // Deployer account
//     address user1; // User1 for testing

//     function setUp() public {
//         deployer = address(1); // Assign a test account for deployer
//         user1 = address(2); // Assign a test account for user1

//         vm.startPrank(deployer); // Use deployer as the msg.sender
//         factory = new NFTCollectionFactory(); // Deploy the factory
//         vm.stopPrank();
//     }

//     function testFactoryDeployment() public view{
//         // Ensure factory address is not zero
//         assert(address(factory) != address(0));
//     }

//     function testCreateCollection() public {
//         // User1 creates a new NFT collection
//         vm.startPrank(user1);
//         factory.createCollection("TestCollection", "TST");
//         vm.stopPrank();

//         // Fetch the deployed collection address
//         address[] memory collections = factory.getUserCollections(user1);
//         assertEq(collections.length, 1); // Ensure the user has 1 collection
//         assert(address(collections[0]) != address(0)); // Ensure the collection address is valid

//         // Verify the collection name and symbol
//         MyNFTCollection collection = MyNFTCollection(collections[0]);
//         assertEq(collection.name(), "TestCollection");
//         assertEq(collection.symbol(), "TST");

//         // Verify the owner of the collection
//         assertEq(collection.owner(), user1);
//     }

//     function testMintNFT() public {
//         // User1 creates a new NFT collection
//         vm.startPrank(user1);
//         factory.createCollection("TestCollection", "TST");
//         address[] memory collections = factory.getUserCollections(user1);
//         MyNFTCollection collection = MyNFTCollection(collections[0]);

//         // Mint an NFT
//         string memory tokenURI = "ipfs://QmTestTokenURI";
//         uint256 tokenId = collection.mintNFT(user1, tokenURI);

//         // Verify the token exists
//         assertEq(collection.ownerOf(tokenId), user1);
//         assertEq(collection.tokenURI(tokenId), tokenURI);
//         vm.stopPrank();
//     }

//     function testTransferOwnership() public {
//         // User1 creates a new NFT collection
//         vm.startPrank(user1);
//         factory.createCollection("TestCollection", "TST");
//         address[] memory collections = factory.getUserCollections(user1);
//         MyNFTCollection collection = MyNFTCollection(collections[0]);

//         // Transfer ownership to deployer
//         collection.transferOwnership(deployer);

//         // Verify ownership transfer
//         assertEq(collection.owner(), deployer);
//         vm.stopPrank();
//     }

//     function testRenounceOwnership() public {
//         // User1 creates a new NFT collection
//         vm.startPrank(user1);
//         factory.createCollection("TestCollection", "TST");
//         address[] memory collections = factory.getUserCollections(user1);
//         MyNFTCollection collection = MyNFTCollection(collections[0]);

//         // Renounce ownership
//         collection.renounceOwnership();

//         // Verify the contract no longer has an owner
//         assertEq(collection.owner(), address(0));
//         vm.stopPrank();
//     }
// }
