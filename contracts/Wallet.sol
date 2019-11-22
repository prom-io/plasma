pragma solidity ^0.5.0;

import "./AbstractWallet.sol";

contract Wallet is AbstractWallet {

	address owner;
	mapping (address => bool) public isWhiteListed;

	constructor() public {
		owner = msg.sender;
	}

	struct Balance {
		address owner;
		uint256 balance;
		bool exists;
	}
	mapping (address => Balance) public wallets;

	event BalanceCreated(
		address owner,
		uint256 sum
	);

	event DepositCreated(
		address owner,
		uint256 sum
	);

	event BalanceEvent(
		address owner, 
		uint256 currentSum, 
		uint256 replenishmentSum
	);
	
	modifier checkSum(uint256 _sum) { 
		require (_sum > 0); 
		_; 
	}

	modifier checkSender(address _sender) { 
		require (isWhiteListed[_sender] == true);
		_; 
	}

	function initWallet(address _owner, uint256 _sum) external checkSender(msg.sender) {
		Balance memory _wallet = wallets[_owner];
		require (_wallet.exists == false);
		wallets[_owner] = Balance(_owner, _sum, true);
		emit BalanceEvent(_owner, _sum, _sum);
	}

	function balanceReplenishment (address _owner, uint256 _sum) public checkSender(msg.sender) checkSum(_sum) {
		Balance memory _wallet = wallets[_owner];
		_wallet.balance += _sum;
		_wallet.exists = true;
		wallets[_owner] = _wallet;
		emit BalanceEvent(_owner, _wallet.balance, _sum);
	}

	function balanceConsumption(address _owner, uint256 _sum) public checkSender(msg.sender) checkSum(_sum) {
		Balance memory _wallet = wallets[_owner];
		require (_wallet.balance > 0);
		require (_wallet.balance >= _sum);
		_wallet.balance -= _sum;
		_wallet.exists = true;
		wallets[_owner] = _wallet;
		emit BalanceEvent(_owner, _wallet.balance, _sum);
	}

	function setWhiteList(
		address _dataSell, 
		address _dataUpload,
		address _accountManage
	) public {
		require (msg.sender == owner);
		isWhiteListed[_dataSell] = true;
		isWhiteListed[_dataUpload] = true;
		isWhiteListed[_accountManage] = true;
	}

	function checkExists(address _owner) public view returns (bool) {
		return wallets[_owner].exists;
	}

	function balanceOf(address _owner) public view returns (uint256) {
		return wallets[_owner].balance;
	}
	
}
