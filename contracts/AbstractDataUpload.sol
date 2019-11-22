pragma solidity ^0.5.0;

contract AbstractDataUpload {
	function checkFileExist(address _owner, string memory _fileId) public view returns(bool);
}
