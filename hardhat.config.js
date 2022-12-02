require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
    solidity: "0.8.17",
    networks: {
        hardhat: {
            forking: {
                url: process.env.JSON_RPC_URL,
                blockNumber: 11846578,
            },
            allowUnlimitedContractSize: true,
        },
    },
};
