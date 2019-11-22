const Web3 = require('web3');
var Web3IpcProvider = require('web3-providers-ipc');
var net = require('net');

module.exports = {

  networks: {
    development: {
      // provider: () => new Web3IpcProvider("/home/aibek/private_net/storage/geth.ipc", net),
      provider: () => new Web3.providers.HttpProvider("http://localhost:7545"),
      network_id: "*",
    }
  },

  mocha: {
  },
  contracts_directory: './contracts/',
  contracts_build_directory: './builds/',
  compilers: {
  }
}
