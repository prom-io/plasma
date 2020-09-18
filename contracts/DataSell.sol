pragma solidity ^0.5.0;

import "./AbstractWallet.sol";
import "./AbstractDataSell.sol";
import "./AbstractDataUpload.sol";
import "./AbstractAccountManage.sol";
import "./lib/signValidator.sol";


contract DataSell is AbstractDataSell {

	struct SelledData {
		string fileId;
		address dataValidator;
		address dataMart;
		address dataOwner;
		uint256 sum;
	}

	modifier sumMoreZero(uint _sum) { 
		require (_sum > 0); 
		_; 
	}

	mapping (string => SelledData) public selledData;

	AbstractWallet public wallet;
	AbstractDataUpload public dataUpload;
	AbstractAccountManage public accountManage;

	event SelledDataEvent(
		string fileId, 
		address dataValidator, 
		address dataMart, 
		address dataOwner, 
		uint256 sum
	);

	event SelledDataEventPay(
		address dataValidator
	);
	
	constructor(address _wallet, address _dataUpload, address _accountManage) public {
		wallet = AbstractWallet(_wallet);
		dataUpload = AbstractDataUpload(_dataUpload);
		accountManage = AbstractAccountManage(_accountManage);
	}

	function sell (
		string memory _fileId, 
		address _dataMart,
		address _dataValidator, 
		address _serviceNode, 
		address _dataOwner,
		uint256 _sum,
		bytes memory _sig,
		bytes32 _message
	) public sumMoreZero(_sum) {
		address signer = ECDSA.recover(_message, _sig);
		require(signer == _dataMart, 'Signer address is not valid');
		require(dataUpload.checkFileExist(_dataValidator, _fileId));
		require(accountManage.isDataMart(_dataMart));
		require(accountManage.isDataValidator(_dataValidator));
		require(accountManage.isServiceNode(_serviceNode));

		selledData[_fileId] = SelledData(_fileId, _dataValidator, _dataMart, _dataOwner, _sum);
		wallet.balancePlusByEthereumAddress(_dataValidator, _sum);
		wallet.balanceMinusByEthereumAddress(_dataMart, _sum);
		emit SelledDataEvent(_fileId, _dataValidator, _dataMart, _dataOwner, _sum);
	}

	function getSellData(string memory _fileId) view public returns (string memory, address, address, uint256) {
		SelledData memory _item = selledData[_fileId];
		return (_item.fileId, _item.dataValidator, _item.dataMart, _item.sum);
	}
}

