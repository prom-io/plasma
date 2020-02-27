pragma solidity ^0.5.0;

import "./AbstractWallet.sol";
import "./lib/signValidator.sol";

contract Wallet is AbstractWallet {

	address owner;

	mapping (address => bool) public isWhiteListed;
	mapping(uint256 => bool) usedNonces;

	constructor() public {
		owner = msg.sender;
	}

	struct Balance {
		address owner;
		uint256 balance;
		uint256 siaBalance;
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

	event ExtendFileStore(
		address dataValidator,
		address serviceNode,
		uint256 sum
	);

	event TransferTo(
		address from,
		address to,
		uint256 sum,
		bytes sig,
		bytes32 message
	);

	event TokenSwap(
		address from,
		address to,
		uint256 sumEther,
		uint256 sumSia,
		bytes sig,
		bytes32 message
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
		wallets[_owner] = Balance(_owner, _sum, 0, true);
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

	function extendFileStore(address _dataValidator, address _serviceNode, uint256 _sum) public checkSum(_sum) {
		Balance memory _dataValidatorBalance = wallets[_dataValidator];
		Balance memory _serviceNodeBalance = wallets[_serviceNode];
		require(_dataValidatorBalance.balance > 0, 'Funds in the account are over!');
		require(_dataValidatorBalance.balance >= _sum, 'Data validator not enough funds on the balance sheet');
		_dataValidatorBalance.balance -= _sum;
		_serviceNodeBalance.balance += _sum;
		wallets[_dataValidator] = _dataValidatorBalance;
		wallets[_serviceNode] = _serviceNodeBalance;
		emit ExtendFileStore(_dataValidator, _serviceNode, _sum);
	}

	function transferTo(address _from, address _to, uint256 _sum, bytes memory _sig, bytes32 _message) public checkSum(_sum) {
		address signer = ECDSA.recover(_message, _sig);
		require(signer == _from, 'Signer address is not valid');
		require(checkExists(_to), 'Reciever address is not registered');
		require(checkExists(_from), 'Address is not registered');
		Balance memory _fromBalance = wallets[_from];
		Balance memory _toBalance = wallets[_to];
		require(_fromBalance.balance > 0, 'Funds in the account are over!');
		require(_fromBalance.balance >= _sum, 'Not enough funds on the balance sheet');
		_fromBalance.balance -= _sum;
		_toBalance.balance += _sum;
		wallets[_from] = _fromBalance;
		wallets[_to] = _toBalance;	
		emit TransferTo(_from, _to, _sum, _sig, _message);
	}

	function swapToken(address _from, address _to, uint256 _sumEther, uint256 _sumSia, bytes memory _sig, bytes32 _message) public checkSum(_sumEther) checkSum(_sumSia) {
		address signer = ECDSA.recover(_message, _sig);
		require(signer == _from, 'Signer address is not valid');
		require(checkExists(_to), 'Reciever address is not registered');
		require(checkExists(_from), 'Address is not registered');
		Balance memory _fromBalance = wallets[_from];
		Balance memory _toBalance = wallets[_to];
		require(_fromBalance.balance > 0, 'Funds in the account are over!');
		require(_fromBalance.balance >= _sumEther, 'Not enough funds on the balance sheet');
		_fromBalance.balance -= _sumEther;
		_toBalance.balance += _sumEther;
		_toBalance.siaBalance += _sumSia;
		wallets[_from] = _fromBalance;
		wallets[_to] = _toBalance;
		emit TokenSwap(_from, _to, _sumEther, _sumSia, _sig, _message);
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
