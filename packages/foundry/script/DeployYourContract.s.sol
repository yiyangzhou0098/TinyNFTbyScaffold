// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../contracts/NFTCollectionsFactory.sol";
import "../contracts/EnglishAuction.sol";
import "./DeployHelpers.s.sol";

contract DeployYourContract is ScaffoldETHDeploy {
    // Use `deployer` from `ScaffoldETHDeploy`
    function run() external ScaffoldEthDeployerRunner {
        NFTCollectionsFactory factory = new NFTCollectionsFactory(); // Deploy the factory
        console.logString(
            string.concat(
                "NFTCollectionFactory deployed at: ", vm.toString(address(factory))
            )
        );
    // Deploy the EnglishAuction contract
        EnglishAuction auction = new EnglishAuction();
        console.logString(
            string.concat(
                "EnglishAuction deployed at: ", vm.toString(address(auction))
            )
        );

        // Save deployment info
        deployments.push(Deployment({
            name: "NFTCollectionFactory",
            addr: address(factory)
        }));
        deployments.push(Deployment({
            name: "EnglishAuction",
            addr: address(auction)
        }));
    }
}
