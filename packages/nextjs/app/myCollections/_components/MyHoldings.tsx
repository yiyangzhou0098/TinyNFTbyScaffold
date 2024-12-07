"use client";

import { useEffect, useState } from "react";
import { CollectionCard } from "./CollectionCard";
import { useAccount } from "wagmi";
import { useScaffoldContract, useScaffoldReadContract, useScaffoldWriteContract, useWatchBalance } from "~~/hooks/scaffold-eth";
import { notification } from "~~/utils/scaffold-eth";
import { getMetadataFromIPFS } from "~~/utils/simpleNFT/ipfs-fetch";
import { NFTMetaData } from "~~/utils/simpleNFT/nftsMetadata";

import { useReadContract } from 'wagmi';
import MyNFTCollectionABI from "~~/contracts/MyNFTCollection.json";

import { getContract } from "viem";

export type Collectible = {
  collectionAddress: string,
  name: string,
  symbol: string,
  owner: string;
}

export const MyHoldings = () => {
  const { address: connectedAddress } = useAccount();
  const [myAllCollectibles, setMyAllCollectibles] = useState<Collectible[]>([]);
  const [allCollectiblesLoading, setAllCollectiblesLoading] = useState(false);

  const { data: allCollections } = useScaffoldReadContract({
    contractName: "NFTCollectionsFactory",
    functionName: "getUserCollections",
    args: [connectedAddress],
    watch: true,
  });

  useEffect(() => {
    const updateMyCollectibles = async (): Promise<void> => {
      if (connectedAddress === undefined || allCollections === undefined)
        return;

      const filteredCollection = allCollections.filter((item) =>
       item.owner === connectedAddress);

      console.log("卡片上的address是" + filteredCollection.map(item => item.collectionAddress));

      setAllCollectiblesLoading(true);
      setMyAllCollectibles([...filteredCollection]);
      setAllCollectiblesLoading(false);
    };
    console.log("pause");
    updateMyCollectibles();
  }, [connectedAddress, allCollections]);

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
          <div className="text-2xl text-primary-content">No Collections found</div>
        </div>
      ) : (
        <div className="flex flex-wrap gap-4 my-8 px-5 justify-center">
          {myAllCollectibles.map(item => (
            <CollectionCard collection={item} key={item.collectionAddress} />
          ))}
        </div>
      )}
    </>
  );
};
