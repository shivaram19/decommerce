import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

// hardhat.config.ts
const config: HardhatUserConfig = {
  solidity: "0.8.20",
  networks: {
    local :{
      url: 'http://127.0.0.1:8545/'
    },
    hardhat: {
      mining: {
        auto: true,
        interval: 0,
        mempool: {
          order: "fifo"
        }
      },
      loggingEnabled: true
    }
  }
};

export default config;