const Web3 = require('web3');

const TruffleConfig = require('../truffle-config');

const Migrations = artifacts.require("Migrations");

module.exports = async function(deployer, network, addresses) {
	const config = TruffleConfig.networks[network];
  	await deployer.deploy(Migrations)
};
