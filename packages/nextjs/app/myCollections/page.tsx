"use client";

// import { MyHoldings } from "./_components";
import type { NextPage } from "next";
import { useAccount } from "wagmi";
import { RainbowKitCustomConnectButton } from "~~/components/scaffold-eth";
import { useScaffoldReadContract, useScaffoldWriteContract } from "~~/hooks/scaffold-eth";
import { notification } from "~~/utils/scaffold-eth";
import { useState } from "react";


const MyCollections: NextPage = () => {
  const { address: connectedAddress, isConnected, isConnecting } = useAccount();
  const [collectionName, setCollectionName] = useState("");
  const [symbol, setSymbol] = useState("");


  const { writeContractAsync } = useScaffoldWriteContract("NFTCollectionsFactory");


  const handleCreateCollections = async () => {

    const notificationId = notification.loading("Creating");
    try {
      // First remove previous loading notification and then show success notification
      notification.remove(notificationId);
      notification.success("Collection "+ collectionName +" Created");

      await writeContractAsync({
        functionName: "createYourCollection",
        args: [collectionName, symbol],
      });
    } catch (error) {
      notification.remove(notificationId);
      console.error(error);
    }
  };

  return (
    <>
      <div className="flex items-center flex-col pt-10">
        <div className="px-5">
          <h1 className="text-center mb-8">
            <span className="block text-4xl font-bold">My Collections</span>
          </h1>
        </div>
      </div>
      <div className="flex justify-center">
        {!isConnected || isConnecting ? (
          <RainbowKitCustomConnectButton />
        ) : (

          <form
          className="card bg-base-100 shadow-md shadow-secondary p-4 w-full max-w-xl"
          onSubmit={e => {
            e.preventDefault();
            handleCreateCollections();
          }}
        >
          <h1 className="font-bold text-2xl flex flex-col items-center mb-4">Create New Collection</h1>
          <label className="input input-bordered flex items-center gap-2 mx-2 mb-4">
            Name
            <input
              type="text"
              className="grow"
              placeholder="New Collection Name"
              value={collectionName}
              onChange={e => setCollectionName(e.target.value)}
              required={true}
            />
          </label>
          <label className="input input-bordered flex items-center gap-2 mx-2 mb-4">
            Symbol
            <input
              type="text"
              className="grow"
              placeholder="New Collection Symbol"
              value={symbol}
              onChange={e => setSymbol(e.target.value)}
            />
          </label>
          <div className="flex justify-center">
            <button className="btn btn-success btn-md">Create</button>
          </div>
        </form>


        )}
      </div>
      {/* <MyHoldings /> */}
    </>
  );
};

export default MyCollections;
