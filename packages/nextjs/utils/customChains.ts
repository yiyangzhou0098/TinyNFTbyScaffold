import { defineChain } from "viem";

// Base chain
export const nft7500 = defineChain({
  id: 31337,
  name: "info7500-test3",
  nativeCurrency: { name: "VETH", symbol: "ETH", decimals: 18 },
  rpcUrls: {
    default: {
      http: ["https://virtual.mainnet.rpc.tenderly.co/6c3d4f3e-3760-46ea-baf4-2bf0f069bf14"],
    },
  },
  blockExplorers: {
    default: {
      name: "Tenderly Explorer",
      url: "https://dashboard.tenderly.co/explorer/vnet/61456318-8904-4b29-b360-53758647d6e4/transactions",
    },
  },
});