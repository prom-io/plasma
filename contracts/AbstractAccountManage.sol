pragma solidity ^0.5.0;

contract AbstractAccountManage {

	function isDataValidator (address _owner) public view returns(bool);
	
	function isDataOwner (address _owner) public view returns(bool);

	function isDataMart (address _owner) public view returns(bool);

	function isServiceNode (address _owner) public view returns(bool);
}
