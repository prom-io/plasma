pragma solidity ^0.5.0;

import "./AbstractWallet.sol";
import "./lib/signValidator.sol";
import "./lib/SafeMath.sol";

contract WalletLambda is AbstractWallet {

	using SafeMath for uint256;

	address public owner;

	uint8 public decimals = 8;
	mapping (string => bool) public processedRequests;
	mapping (string => LambdaWallet) public lambdaWalletByLambdaAddress;
	mapping (address => LambdaWallet) public lambdaWalletByEthAddress;
	mapping (address => bool) public validators;
	mapping (string => bool) public registeredWallet;

	constructor() public {
		owner = msg.sender;
		validators[msg.sender] = true;
	}

	struct LambdaWallet {
		address ethAddress;
		string lambdaAddress;
		uint256 amount;
	}

	event ValidatorAdded(address validator);
	event ValidatorRemoved(address validator);
	event BalanceIncreased(address ethAddress, string lambdaAddress, uint256 amount);
	event BalanceDecreased(address ethAddress, string lambdaAddress, uint256 amount);
	
	modifier isOwner() { 
		require (msg.sender == owner); 
		_; 
	}

	modifier isValidator() { 
		require (validators[msg.sender] == true, 'You not validator!'); 
		_; 
	}

	modifier isNotRegistered(string memory lambdaAddress) { 
		require (registeredWallet[lambdaAddress] == false, 'This account is registered!'); 
		_; 
	}

	modifier isRegistered(string memory lambdaAddress) {
		require (registeredWallet[lambdaAddress] == true, 'This account not registered!'); 
		_; 
	}

	modifier isNotProcessed(string memory txHash) {
		require (processedRequests[txHash] == false, 'This request is processed!');
		_;
	}

	function deposit(
		string memory _lambdaAddress, 
		string memory _txHash,
		uint256 _amount
	) public isValidator() isRegistered(_lambdaAddress) isNotProcessed(_txHash) returns (bool) {
		processedRequests[_txHash] = true;
		LambdaWallet memory _lambdaWallet = lambdaWalletByLambdaAddress[_lambdaAddress];
		_lambdaWallet.amount += _amount;
		lambdaWalletByEthAddress[_lambdaWallet.ethAddress] = _lambdaWallet;
		lambdaWalletByLambdaAddress[_lambdaAddress] = _lambdaWallet;
		return true;
	}

	function newWallet (address _ethAddress, string memory _lambdaAddress) public isValidator() isNotRegistered(_lambdaAddress) returns(bool res) {
		registeredWallet[_lambdaAddress] = true;
		LambdaWallet memory _lambdaWallet = LambdaWallet(_ethAddress, _lambdaAddress, 0);
		lambdaWalletByEthAddress[_ethAddress] = _lambdaWallet;
		lambdaWalletByLambdaAddress[_lambdaAddress] = _lambdaWallet;
		return true;
	}

	function balancePlusByEthereumAddress (address _ethAddress, uint256 _amount) public isValidator() returns(bool) {
		require (_amount > 0, 'Amount less zero!');
		LambdaWallet memory _lambdaWallet = lambdaWalletByEthAddress[_ethAddress];
		require (registeredWallet[_lambdaWallet.lambdaAddress] == true, 'This account is not registered!');
		_lambdaWallet.amount += _amount;
		lambdaWalletByEthAddress[_ethAddress] = _lambdaWallet;
		lambdaWalletByLambdaAddress[_lambdaWallet.lambdaAddress] = _lambdaWallet;
		emit BalanceIncreased(_ethAddress, _lambdaWallet.lambdaAddress, _amount);
		return true;
	}

	function balanceMinusByEthereumAddress (address _ethAddress, uint256 _amount) public isValidator() returns(bool) {
		require (_amount > 0, 'Amount less zero!');
		LambdaWallet memory _lambdaWallet = lambdaWalletByEthAddress[_ethAddress];
		require (registeredWallet[_lambdaWallet.lambdaAddress] == true, 'This account is not registered!');
		require (_lambdaWallet.amount >=_amount, 'Not enough funds on the balance sheet!');
		_lambdaWallet.amount -= _amount;
		lambdaWalletByEthAddress[_ethAddress] = _lambdaWallet;
		lambdaWalletByLambdaAddress[_lambdaWallet.lambdaAddress] = _lambdaWallet;
		emit BalanceDecreased(_ethAddress, _lambdaWallet.lambdaAddress, _amount);
		return true;
	}
	

	function balancePlus (address _ethAddress, string memory _lambdaAddress, uint256 _amount) public isValidator() returns(bool) {
		require (_amount > 0, 'Amount less zero!');
		LambdaWallet memory _lambdaWallet = lambdaWalletByLambdaAddress[_lambdaAddress];
		_lambdaWallet.amount += _amount;
		lambdaWalletByEthAddress[_ethAddress] = _lambdaWallet;
		lambdaWalletByLambdaAddress[_lambdaAddress] = _lambdaWallet;
		emit BalanceIncreased(_ethAddress, _lambdaAddress, _amount);
		return true;
	}

	function balanceMinus (address _ethAddress, string memory _lambdaAddress, uint256 _amount) public isValidator() returns(bool) {
		require (_amount > 0, 'Amount less zero!');
		LambdaWallet memory _lambdaWallet = lambdaWalletByLambdaAddress[_lambdaAddress];
		require (_lambdaWallet.amount >= _amount);
		_lambdaWallet.amount -= _amount;
		lambdaWalletByEthAddress[_ethAddress] = _lambdaWallet;
		lambdaWalletByLambdaAddress[_lambdaAddress] = _lambdaWallet;
		emit BalanceDecreased(_ethAddress, _lambdaAddress, _amount);
		return true;
	}

	function addValidator (address _validator) public isOwner() returns(bool res) {
		validators[_validator] = true;
		emit ValidatorAdded(_validator);
		return true;
	}

	function removeValidator (address _validator) public isOwner() returns(bool res) {
		validators[_validator] = false;
		emit ValidatorRemoved(_validator);
		return true;
	}

	function balanceOf(string memory _lambdaAddress) public view returns (uint256) {
		return lambdaWalletByLambdaAddress[_lambdaAddress].amount;
	}
}
