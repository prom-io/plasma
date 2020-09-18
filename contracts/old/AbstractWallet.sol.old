pragma solidity ^0.5.0;

contract AbstractWallet {
	function initWallet(address _owner, uint256 _sum) external;
	function balanceReplenishment (address _owner, uint _sum) public;	
	function balanceConsumption(address _owner, uint _sum) public;
	function checkExists(address _owner) public view returns (bool);
	function swapToken(address _from, address _to, uint256 _sumEther, uint256 _sumSia, bytes memory _sig, bytes32 _message) public;
}
