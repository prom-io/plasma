pragma solidity ^0.5.0;

contract AbstractWallet {
	function deposit(
		string memory _lambdaAddress, 
		string memory _txHash,
		uint256 _amount
	) public returns (bool);
	function newWallet (
		address _ethAddress, 
		string memory _lambdaAddress
	) public returns(bool res);
	function balancePlusByEthereumAddress (
		address _ethAddress,
		uint256 _amount
	) public returns(bool);
	function balanceMinusByEthereumAddress (
		address _ethAddress,
		uint256 _amount
	) public returns(bool);
	function balancePlus (
		address _ethAddress,
		string memory _lambdaAddress,
		uint256 _amount
	) public returns(bool);
	function balanceMinus (
		address _ethAddress,
		string memory _lambdaAddress,
		uint256 _amount
	) public returns(bool);
	function addValidator (address _validator) public returns(bool res);
	function removeValidator (address _validator) public returns(bool res);
	function balanceOf(string memory _lambdaAddress) public view returns (uint256);
}
