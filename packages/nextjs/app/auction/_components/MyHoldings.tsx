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

  highestBid: bigint;
  endAt: number;
  auctionId: bigint;
  isOwner: boolean
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

  // first get all active Auctions
  const { data: activeAuctions } = useScaffoldReadContract({
    contractName: "EnglishAuction",
    functionName: "getActiveAuctions",
  });

  // TODO only render once
  useEffect(() => {
    const updateMyCollectibles = async (): Promise<void> => {
      if (connectedAddress === undefined || activeAuctions === undefined){
        return;
      }

      setAllCollectiblesLoading(true);
      // setMyAllCollections([...allCollections]);

      const collectibleUpdate: Collectible[] = [];
      for(const auction of activeAuctions) {
        console.log("auction's contract:" +auction.nft);

        const myNFTCollectionContract = getContract({
          address: auction.nft,
          abi: MyNFTCollectionJson.abi,
          client, // Use walletClient for writes, fallback to publicClient
        });
        console.log("能获取到auction's contract")

        try {

          const tokenURI = String(await myNFTCollectionContract.read.tokenURI([auction.nftId]));
          console.log("能获取到tokenURI" + tokenURI)

          const ipfsHash = tokenURI.replace("https://ipfs.io/ipfs/", "");

          const nftMetadata: NFTMetaData = await getMetadataFromIPFS(ipfsHash);

          collectibleUpdate.push({
            id: parseInt(auction.nftId.toString()),
            uri: tokenURI,
            owner: auction.seller,
            collectionAddress: auction.nft,

            auctionId: auction.auctionId,
            highestBid: auction.highestBid,
            endAt: auction.endAt,

            isOwner: auction.seller === connectedAddress ? true : false,

            ...nftMetadata,
          });

        } catch (e) {
          notification.error("Error fetching all collectibles");
          setAllCollectiblesLoading(false);
          console.log(e);
        }
        
      }
      collectibleUpdate.sort((a, b) => a.id - b.id);
      setMyAllCollectibles(collectibleUpdate);
      setAllCollectiblesLoading(false);
    };

    updateMyCollectibles();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [activeAuctions]);

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
          <div className="text-2xl text-primary-content">No Auction found</div>
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
