pragma solidity ^0.5.0;

import "./AbstractTransaction.sol";
import "./AbstractWallet.sol";
import "./AbstractDataUpload.sol";
import "./AbstractAccountManage.sol";

contract DataUpload is AbstractDataUpload {

	uint256 public fileCount = 0;
	mapping (address => mapping(string => File)) public files;
	mapping (string => UploadedData) public uploadedData;
	mapping (uint256 => File) public fileList;
	

	AbstractTransaction public transaction;
	AbstractWallet public wallet;
	AbstractAccountManage public accountManage;

	struct File {
		string id;
		string name;
		uint256 size;
		string file_extension;
		string mime_type;
		address owner;
		bool exist;
	}

	struct UploadedData {
		string  id;
		address serviceNodeAddress;
		address dataOwnerAddress;
		uint256 serviceNodeAmount;
		uint256 dataOwnerAmount; 
		uint256 assessedValue;
		uint256 sum;
	}

	event DataUploaded(
		string id,
		address serviceNodeAddress,
		address dataOwner,
		uint serviceNodeAmount,
		uint dataOwnerAmount,
		uint assessedValue,
		uint sum
	);

	constructor(address _transaction, address _wallet, address _accountManage) public {
		wallet = AbstractWallet(_wallet);
		transaction = AbstractTransaction(_transaction);
		accountManage = AbstractAccountManage(_accountManage);
	}

	function upload (
		string memory _id,
		string memory _name,
		uint256 _size,
		string memory _file_extension,
		string memory _mime_type,
		address _owner,
		address _serviceNodeAddress,
		address _dataOwner,
		uint _dataPrice,
		uint _sum
	) public {
		require (_sum > 0, "Sum less zero");
		require (_sum == _dataPrice, "Data price and sum not equal");
		require (accountManage.isDataOwner(_dataOwner) == true, "Invalid address: Is not Data Owner");
		require (accountManage.isServiceNode(_serviceNodeAddress) == true, "Invalid address: Is not Service Node");
		require (accountManage.isDataValidator(_owner) == true, "Invalid address: Is not Data Validator");
		
		fileCount += 1;
		uint256 _dataOwnerAmount = _sum / 2;
		uint256 _serviceNodeAmount = _sum / 2;
		wallet.balanceReplenishment(_serviceNodeAddress, _dataOwnerAmount);
		wallet.balanceReplenishment(_dataOwner, _serviceNodeAmount);
		wallet.balanceConsumption(_owner, _sum);
		uploadedData[_id] = UploadedData(
			_id, 
			_serviceNodeAddress, 
			_dataOwner, 
			_dataOwnerAmount, 
			_serviceNodeAmount, 
			_dataPrice, 
			_sum
		);
		File memory _file = File(
			_id, 
			_name, 
			_size, 
			_file_extension, 
			_mime_type,
			_owner,
			true
		);
		fileList[fileCount] = _file;
		files[_owner][_id] = _file;
		transaction.newTransaction(_id, 'dataUpload');
		emit DataUploaded(
			_id, 
			_serviceNodeAddress, 
			_dataOwner, 
			_dataOwnerAmount, 
			_serviceNodeAmount, 
			_dataPrice, 
			_sum
		);
	}
	
	function checkFileOwner(address _owner, string memory _id) public view returns(bool) {
		File memory _file = files[_owner][_id];
		if(_file.owner == _owner) {
			return true;
		}
		return false;
	}

	function checkFileExist(address _owner, string memory _fileId) public view returns(bool) {
		return files[_owner][_fileId].exist;
	}

	function getOwnerFile(address _owner, string memory _id) 
		public 
		view 
		returns(
			string memory,
			string memory,
			uint256,
			string memory,
			string memory
		) {
		File memory _file = files[_owner][_id];
		return (
			_file.id,
			_file.name,
			_file.size,
			_file.file_extension,
			_file.mime_type
		);
	}
}
