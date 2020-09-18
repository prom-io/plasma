const Web3 = require('web3');
var Web3IpcProvider = require('web3-providers-ipc');
var net = require('net');

module.exports = {

  networks: {
    development: {
      // provider: () => new Web3IpcProvider("/home/aibek/private_net/storage/geth.ipc", net),
      provider: () => new Web3.providers.HttpProvider("http://localhost:8545"),
      network_id: "*",
    },
    stoa: {
      host: "64.227.70.213",
      network_id: 817718719871,   // This network is yours, in the cloud.
      // gas: 0x47b760,
      from: '0x4B37428f825fe94dbF6d3415D8344Fe1FF5aDD7A',
      port: 7545,
    }
  },

  mocha: {
  },
  contracts_directory: './contracts/',
  contracts_build_directory: './builds/',
  compilers: {
  }
}
