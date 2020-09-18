const Web3 = require('web3');

const TruffleConfig = require('../truffle-config');

const WalletLambda = artifacts.require("WalletLambda");
const DataUpload = artifacts.require("DataUpload");
const DataSell = artifacts.require("DataSell");
const Transaction = artifacts.require("Transaction");
const AccountManage = artifacts.require("AccountManage");


module.exports = function(deployer, network, addresses) {
	const config = TruffleConfig.networks[network];
	var a
	deployer.deploy(Transaction, {overwrite: true});
	deployer.deploy(WalletLambda)
		.then((instance) => {
			a = instance
			return deployer.deploy(AccountManage, WalletLambda.address);
		})
		.then(() => {
			return deployer.deploy(DataUpload, Transaction.address, WalletLambda.address, AccountManage.address)
		})
		.then(() => {
			return deployer.deploy(DataSell, WalletLambda.address, DataUpload.address, AccountManage.address)
		});
};

// module.exports = function(deployer) {
//   deployer.deploy(Transaction)
//   	.then(function() {
//   		walletLambda = WalletLambda.deployed();
//   		return deployer.deploy(DataUpload, Transaction.address, WalletLambda.address);
//   	})
//   	.then(function() {
//   		return deployer.deploy(DataSell, Transaction.address, WalletLambda.address);		
//   	});
// };
