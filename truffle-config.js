const HDWalletProvider = require("@truffle/hdwallet-provider");

const mnemonic =
  "candy maple cake sugar testing cream honey cool smooth crumble sweet treat";

module.exports = {
  networks: {
    evmos: {
      provider: () =>
        new HDWalletProvider(mnemonic, "https://eth.bd.evmos.dev:8545"),
      network_id: 9000,
      chain_id: 9000,
    },
  },

  // Set default mocha options here, use special reporters etc.
  mocha: {
    // timeout: 100000
  },

  // Configure your compilers
  compilers: {
    solc: {
      version: "0.8.21", // Fetch exact
    },
  },
};
