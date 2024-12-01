import { defineChain } from "viem";

// Base chain
export const nft7500 = defineChain({
  id: 31337,
  name: "nft7500-testnet",
  nativeCurrency: { name: "Ether", symbol: "ETH", decimals: 18 },
  rpcUrls: {
    default: {
      http: ["https://virtual.mainnet.rpc.tenderly.co/876990d4-38d6-4869-b68c-c442366a6f15"],
    },
  },
  blockExplorers: {
    default: {
      name: "Tenderly Explorer",
      url: "https://dashboard.tenderly.co/",
    },
  },
});