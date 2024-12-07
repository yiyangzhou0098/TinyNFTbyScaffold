import { useState } from "react";
import { Collectible } from "./MyHoldings";
import { Address, AddressInput, RainbowKitCustomConnectButton } from "~~/components/scaffold-eth";
import { useDeployedContractInfo } from "~~/hooks/scaffold-eth";
import { notification } from "~~/utils/scaffold-eth";


import nftsMetadata from "~~/utils/simpleNFT/nftsMetadata";
import { useAccount, usePublicClient, useWalletClient } from 'wagmi';
import MyNFTCollectionJson from "~~/contracts/MyNFTCollection.json";
import { getContract } from 'viem';
import { addToIPFS } from "~~/utils/simpleNFT/ipfs-fetch";

export const CollectionCard = ({ collection }: { collection: Collectible }) => {

  const { address: connectedAddress, isConnected, isConnecting } = useAccount();
  const publicClient = usePublicClient(); // For read-only operations
  const { data: walletClient } = useWalletClient(); // For write operations

  const client = walletClient || publicClient; 

  if (!client) {
    throw new Error('No valid client available');
  }

  const myNFTCollectionContract = getContract({
    address: collection.collectionAddress,
    abi: MyNFTCollectionJson.abi,
    client, // Use walletClient for writes, fallback to publicClient
  });


  const handleMintItem = async () => {
    // circle back to the zero item if we've reached the end of the array

    const tokenIdCounter = await myNFTCollectionContract.read._nextTokenId();
    const tokenIdCounterNumber = Number(tokenIdCounter);

    if (!(typeof tokenIdCounterNumber === 'number') && !(tokenIdCounterNumber >= 0)) return;

    const currentTokenMetaData = nftsMetadata[tokenIdCounterNumber % nftsMetadata.length];
    const notificationId = notification.loading("Uploading to IPFS");
    try {
      if(walletClient === undefined || connectedAddress == undefined) return

      const uploadedItem = await addToIPFS(currentTokenMetaData);

      // First remove previous loading notification and then show success notification
      notification.remove(notificationId);
      notification.success("Metadata uploaded to IPFS");

      await walletClient.writeContract({
        address: collection.collectionAddress,
        abi: MyNFTCollectionJson.abi,
        functionName: 'mintNFT',
        args: [connectedAddress, uploadedItem.path],
      })

    } catch (error) {
      notification.remove(notificationId);
      console.error(error);
    }
  };


  return (
    <div className="card card-compact bg-base-100 shadow-lg w-[300px] shadow-secondary">
      {/* <figure className="relative">
        <img src={nft.image} alt="NFT Image" className="h-60 min-w-full" />
        <figcaption className="glass absolute bottom-4 left-4 p-4 w-25 rounded-xl">
          <span className="text-white "># {collection.name}</span>
        </figcaption>
      </figure> */}
      <div className="card-body space-y-3">
        {/* <div className="flex items-center justify-center">
          <p className="text-xl p-0 m-0 font-semibold">{collection.collectionSymbol}</p>
          <div className="flex flex-wrap space-x-2 mt-1">
            {collection.attributes?.map((attr, index) => (
              <span key={index} className="badge badge-primary py-3">
                {attr.value}
              </span>
            ))}
          </div>
        </div> */}
        <div className="flex space-x-3 mt-1 items-center">
          <span className="text-lg font-semibold">Collection Name : </span>
          <p className="my-0 text-lg">{collection.name}</p>
        </div>
        <div className="flex space-x-3 mt-1 items-center">
          <span className="text-lg font-semibold">Symbol : </span>
          <p className="my-0 text-lg">{collection.symbol}</p>
        </div>
        <div className="flex space-x-3 mt-1 items-center">
          <span className="text-lg font-semibold">Owner : </span>
          <Address address={collection.owner} />
        </div>
        <div className="flex space-x-3 mt-1 items-center">
          <span className="text-lg font-semibold">Address : </span>
          <Address address={collection.collectionAddress} />
        </div>
        <div className="flex justify-center">
          <button className="btn btn-secondary" onClick={handleMintItem}>
            Mint NFT
          </button>
        </div>
        {/* <div className="flex flex-col my-2 space-y-1">
          <span className="text-lg font-semibold mb-1">Transfer To: </span>
          <AddressInput
            value={transferToAddress}
            placeholder="receiver address"
            onChange={newValue => setTransferToAddress(newValue)}
          />
        </div> */}
        {/* <div className="card-actions justify-end">
          <button
            className="btn btn-secondary btn-md px-8 tracking-wide"
            onClick={() => {
              try {
                writeContractAsync({
                  functionName: "transferFrom",
                  args: [nft.owner, transferToAddress, BigInt(nft.id.toString())],
                });
              } catch (err) {
                console.error("Error calling transferFrom function");
              }
            }}
          >
            Send
          </button>
        </div> */}
      </div>
    </div>
  );
};
