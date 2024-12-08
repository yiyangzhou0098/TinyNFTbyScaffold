import { defineChain } from "viem";

// Base chain
export const nft7500 = defineChain({
  id: 31337,
  name: "info7500-test1",
  nativeCurrency: { name: "VETH", symbol: "ETH", decimals: 18 },
  rpcUrls: {
    default: {
      http: ["https://virtual.mainnet.rpc.tenderly.co/53082d50-a540-4e30-8697-c1beaad4c3c5"],
    },
  },
  blockExplorers: {
    default: {
      name: "Tenderly Explorer",
      url: "https://virtual.mainnet.rpc.tenderly.co/e2972ac8-2f4b-4aef-94d7-54fdc0d4242f",
    },
  },
});