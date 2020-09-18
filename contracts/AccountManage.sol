pragma solidity ^0.5.0;

import "./AbstractWallet.sol";
import "./AbstractAccountManage.sol";

contract AccountManage is AbstractAccountManage {
	uint private DATA_VALIDATOR = 1;
	uint private DATA_MART = 2;
	uint private SERVICE_NODE = 3;
	uint private DATA_OWNER = 4;

	AbstractWallet public wallet;

	struct Account {
		address owner;
		uint role;
		bool registered;
	}
	
	mapping(address => Account) public accounts;
	mapping(address => address[]) public dataOwners;
	mapping(address => uint256) public dataOwnersCount;
	

	modifier checkRegistered(address _owner) { 
		require (accounts[_owner].registered == false);
		_; 
	}

	constructor(address _wallet) public {
		wallet = AbstractWallet(_wallet);
	}
	
	event Registered(
		address owner,
		uint role
	);

	event RegisteredSum(
		address owner,
		uint256 sum
	);

	event ChildChainDeposit(
		address owner, 
		uint256 sum
	);
	

	function initAccount(address _owner, uint256 _sum) public {
		accounts[_owner] = Account(_owner, 0, false);
	}

	function registerDataMart(address _owner) public checkRegistered(_owner) {
		register(_owner, DATA_MART);
	}

	function registerServiceNode(address _owner) public checkRegistered(_owner) {
		register(_owner, SERVICE_NODE);
	}

	function registerDataValidator (address _owner) public checkRegistered(_owner) {
		register(_owner, DATA_VALIDATOR);
	}

	function registerDataOwner (address _owner) public checkRegistered(_owner) {
		register(_owner, DATA_OWNER);
	}

	function registerOwner(address _dataValidator, address _dataOwner) public checkRegistered(_dataOwner) {
		require(isRegistered(_dataValidator) == true);
		require(isDataValidator(_dataValidator) == true);
		accounts[_dataOwner] = Account(_dataOwner, DATA_OWNER, true);
	 	dataOwners[_dataValidator].push(_dataOwner);	
	 	dataOwnersCount[_dataValidator] = dataOwnersCount[_dataValidator] + 1;
	 	emit Registered(_dataOwner, DATA_OWNER);
	}

	function register(address _owner, uint _role) private {
		accounts[_owner] = Account(_owner, _role, true);		
	 	emit Registered(_owner, _role);
	}

	function getRole(address _owner) public view returns(uint) {
		return accounts[_owner].role;
	}

	function isRegistered (address _owner) public view returns(bool) {
		return accounts[_owner].registered;
	}
	
	function isDataValidator (address _owner) public view returns(bool) {
		return accounts[_owner].role == DATA_VALIDATOR;
	}

	function isDataOwner (address _owner) public view returns(bool) {
		return accounts[_owner].role == DATA_OWNER;
	}

	function isDataMart (address _owner) public view returns(bool) {
		return accounts[_owner].role == DATA_MART;
	}

	function isServiceNode (address _owner) public view returns(bool) {
		return accounts[_owner].role == SERVICE_NODE;
	}
}
