// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../contracts/NFTCollectionsFactory.sol";
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

        // Save deployment info
        deployments.push(Deployment({
            name: "NFTCollectionFactory",
            addr: address(factory)
        }));
    }
}

// pragma solidity ^0.8.19;

// import "../contracts/YourContract.sol";
// import "./DeployHelpers.s.sol";

// contract DeployYourContract is ScaffoldETHDeploy {
//   // use `deployer` from `ScaffoldETHDeploy`
//   function run() external ScaffoldEthDeployerRunner {
//     YourContract yourContract = new YourContract(deployer);
//     console.logString(
//       string.concat(
//         "YourContract deployed at: ", vm.toString(address(yourContract))
//       )
//     );
//   }
// }
