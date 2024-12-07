import { GenericContractsDeclaration } from "~~/utils/scaffold-eth/contract";

import MyNFTCollectionJSON from "./MyNFTCollection.json";

// const MyNFTCollectionABI = MyNFTCollectionJSON.abi; 

const externalContracts = {
    31337: {
        MyNFTCollection: {
            address: "0x281159378dBf9BC4D2154AB2DF8836BD86CbA7ef", // Replace with the deployed contract address when known
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
