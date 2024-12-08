import MyNFTCollectionJSON from "./MyNFTCollection.json";

// const MyNFTCollectionABI = MyNFTCollectionJSON.abi; 

const externalContracts = {
    31337: {
        MyNFTCollection: {
            // for test
            address: "", // Replace with the deployed contract address when known
            abi: MyNFTCollectionJSON.abi, // Ensure this is the flat ABI array
        },
      },
} as const;


/**
 * @example
 * const externalContracts = {
 *   1: {
 *     DAI: {
 *       address: "0x...",
 *       abi: [...],
 *     },
 *   },
 * } as const;
 */
// const externalContracts = {} as const;



export default externalContracts;
