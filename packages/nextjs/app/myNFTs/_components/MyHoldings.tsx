"use client";

import { useEffect, useState } from "react";
import { NFTCard } from "./NFTCard";
import { useScaffoldReadContract } from "~~/hooks/scaffold-eth";
import { notification } from "~~/utils/scaffold-eth";
import { getMetadataFromIPFS } from "~~/utils/simpleNFT/ipfs-fetch";
import { NFTMetaData } from "~~/utils/simpleNFT/nftsMetadata";
import { useAccount, usePublicClient, useWalletClient } from 'wagmi';
import MyNFTCollectionJson from "~~/contracts/MyNFTCollection.json";
import { getContract } from 'viem';

export interface Collectible extends Partial<NFTMetaData> {
  id: number;
  uri: string;
  owner: string;
  collectionAddress: string;
}

export const MyHoldings = () => {
  const { address: connectedAddress } = useAccount();
  const [myAllCollectibles, setMyAllCollectibles] = useState<Collectible[]>([]);
  // const [myAllCollections, setMyAllCollections] = useState<Collection[]>([]);

  const [allCollectiblesLoading, setAllCollectiblesLoading] = useState(false);

  const publicClient = usePublicClient(); // For read-only operations
  const { data: walletClient } = useWalletClient(); // For write operations

  const client = walletClient || publicClient; 

  if (!client) {
    throw new Error('No valid client available');
  }

  // first get all collection's address by allCollections
  const { data: allCollections } = useScaffoldReadContract({
    contractName: "NFTCollectionsFactory",
    functionName: "getUserCollections",
    args: [connectedAddress],
    watch: true,
  });

  // TODO only render once
  useEffect(() => {
    const updateMyCollectibles = async (): Promise<void> => {
      if (connectedAddress === undefined || allCollections === undefined){
        return;
      }

      setAllCollectiblesLoading(true);
      // setMyAllCollections([...allCollections]);

      const collectibleUpdate: Collectible[] = [];
      for(const collection of allCollections) {
        console.log(collection.collectionAddress)

        if(collection.owner !== connectedAddress) continue

        const myNFTCollectionContract = getContract({
          address: collection.collectionAddress,
          abi: MyNFTCollectionJson.abi,
          client, // Use walletClient for writes, fallback to publicClient
        });
        console.log("能获取到contract")

        const rawBalance = await myNFTCollectionContract.read.balanceOf([connectedAddress]);
        if (rawBalance === undefined || rawBalance == null) return
        const totalBalance = parseInt(rawBalance.toString());
        console.log("能获取balance"+totalBalance);

        for(let tokenIndex = 0; tokenIndex < totalBalance; tokenIndex++) {
          try {
            const tokenId = await myNFTCollectionContract.read.tokenOfOwnerByIndex([
              connectedAddress,
              BigInt(tokenIndex),
            ]);

            const tokenURI = String(await myNFTCollectionContract.read.tokenURI([tokenId]));

            const ipfsHash = tokenURI.replace("https://ipfs.io/ipfs/", "");
  
            const nftMetadata: NFTMetaData = await getMetadataFromIPFS(ipfsHash);
            collectibleUpdate.push({
              id: Number(tokenId),
              uri: tokenURI,
              owner: connectedAddress,
              collectionAddress: collection.collectionAddress,
              ...nftMetadata,
            });

          } catch (e) {
            notification.error("Error fetching all collectibles");
            setAllCollectiblesLoading(false);
            console.log(e);
          }
        }
      }
      collectibleUpdate.sort((a, b) => a.id - b.id);
      setMyAllCollectibles(collectibleUpdate);
      setAllCollectiblesLoading(false);
    };

    updateMyCollectibles();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [allCollections?.length]);

  if (allCollectiblesLoading)
    return (
      <div className="flex justify-center items-center mt-10">
        <span className="loading loading-spinner loading-lg"></span>
      </div>
    );

  return (
    <>
      {myAllCollectibles.length === 0 ? (
        <div className="flex justify-center items-center mt-10">
          <div className="text-2xl text-primary-content">No NFTs found</div>
        </div>
      ) : (
        <div className="flex flex-wrap gap-4 my-8 px-5 justify-center">
          {myAllCollectibles.map(item => (
            <NFTCard nft={item} key={item.id} />
          ))}
        </div>
      )}
    </>
  );
};
