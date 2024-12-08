import { defineChain } from "viem";

// Base chain
export const nft7500 = defineChain({
  id: 31337,
  name: "info7500-test1",
  nativeCurrency: { name: "Ether", symbol: "ETH", decimals: 18 },
  rpcUrls: {
    default: {
      http: ["https://virtual.mainnet.rpc.tenderly.co/53082d50-a540-4e30-8697-c1beaad4c3c5"],
    },
  },
  blockExplorers: {
    default: {
      name: "Tenderly Explorer",
      url: "https://dashboard.tenderly.co/",
    },
  },
});