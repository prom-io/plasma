pragma solidity ^0.5.0;

import "./AbstractTransaction.sol";
import "./AbstractWallet.sol";
import "./AbstractDataUpload.sol";
import "./AbstractAccountManage.sol";
import "./lib/signValidator.sol";


contract DataUpload is AbstractDataUpload {

	uint256 public fileCount = 0;
	mapping (address => mapping(string => File)) public files;
	mapping (string => UploadedData) public uploadedData;
	mapping (uint256 => File) public fileList;

	mapping (address => uint256) public fileUploadedCount;
	mapping (address => mapping(uint256 => File)) public fileUploaded; 
	

	AbstractTransaction public transaction;
	AbstractWallet public wallet;
	AbstractAccountManage public accountManage;

	struct File {
		string id;
		string name;
		uint256 size;
		string file_extension;
		string mime_type;
		string meta_data;
		address owner;
		bool exist;
	}

	struct UploadedData {
		string  id;
		uint256 sum;
		address serviceNodeAddress;
		address dataOwner;
	}

	event DataUploaded(
		string id,
		address serviceNodeAddress,
		address dataOwner,
		uint256 sum
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
		string memory _meta_data,
		address _owner,
		address _serviceNodeAddress,
		address _dataOwner,
		uint256 _amount,
		bytes memory _sig,
		bytes32 _message
	) public {
		address signer = ECDSA.recover(_message, _sig);
		require(signer == _owner, 'Signer address is not valid');
		require (accountManage.isDataOwner(_dataOwner) == true, "Invalid address: Is not Data Owner");
		require (accountManage.isServiceNode(_serviceNodeAddress) == true, "Invalid address: Is not Service Node");
		require (accountManage.isDataValidator(_owner) == true, "Invalid address: Is not Data Validator");
		
		fileCount += 1;
		uint256 amount = _amount / 2;
		wallet.balancePlusByEthereumAddress(_serviceNodeAddress, amount);
		wallet.balanceMinusByEthereumAddress(_owner, amount);
		fileList[fileCount] = File(_id, _name, _size, _file_extension, _mime_type, _meta_data, _owner, true);
		files[_owner][_id] = File(_id, _name, _size, _file_extension, _mime_type, _meta_data, _owner, true);
		fileUploadedCount[_owner] += 1;
		fileUploaded[_owner][fileUploadedCount[_owner]] = File(_id, _name, _size, _file_extension, _mime_type, _meta_data, _owner, true);
		uploadedData[_id] = UploadedData(_id, amount, _serviceNodeAddress, _dataOwner);
		emit DataUploaded(_id, _serviceNodeAddress, _dataOwner, amount);
	}

	function uploadFile (
		string memory _id,
		string memory _name,
		uint256 _size,
		string memory _file_extension,
		string memory _mime_type,
		string memory _meta_data,
		address _owner
	) public {

		File memory _file = File(
			_id, 
			_name, 
			_size, 
			_file_extension, 
			_mime_type,
			_meta_data,
			_owner,
			true
		);
		fileList[fileCount] = _file;
		files[_owner][_id] = _file;

		fileUploadedCount[_owner] += 1;
		fileUploaded[_owner][fileUploadedCount[_owner]] = _file;
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
