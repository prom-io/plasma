const Web3 = require('web3');

const TruffleConfig = require('../truffle-config');

const DataUpload = artifacts.require("DataUpload");
const DataSell = artifacts.require("DataSell");
const Wallet = artifacts.require("Wallet");
const Transaction = artifacts.require("Transaction");
const AccountManage = artifacts.require("AccountManage");


module.exports = function(deployer, network, addresses) {
	const config = TruffleConfig.networks[network];
	var a
	deployer.deploy(Transaction, {overwrite: true});
	deployer.deploy(Wallet)
		.then((instance) => {
			a = instance
			return deployer.deploy(AccountManage, Wallet.address);
		})
		.then(() => {
			return deployer.deploy(DataUpload, Transaction.address, Wallet.address, AccountManage.address)
		})
		.then(() => {
			return deployer.deploy(DataSell, Wallet.address, DataUpload.address, AccountManage.address)
		})
		.then(() => {
			a.setWhiteList(DataSell.address, DataUpload.address, AccountManage.address)
		});
};

// module.exports = function(deployer) {
//   deployer.deploy(Transaction)
//   	.then(function() {
//   		wallet = Wallet.deployed();
//   		return deployer.deploy(DataUpload, Transaction.address, Wallet.address);
//   	})
//   	.then(function() {
//   		return deployer.deploy(DataSell, Transaction.address, Wallet.address);		
//   	});
// };
