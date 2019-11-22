pragma solidity ^0.5.0;

import "./AbstractTransaction.sol";
import "./AbstractWallet.sol";
import "./AbstractDataSell.sol";
import "./AbstractDataUpload.sol";
import "./AbstractAccountManage.sol";

contract DataSell is AbstractDataSell {

	struct SelledData {
		string fileId;
		address dataValidator;
		address owner;
		uint256 sum;
	}

	modifier sumMoreZero(uint _sum) { 
		require (_sum > 0); 
		_; 
	}

	mapping (string => SelledData) public selledData;

	AbstractWallet public wallet;
	AbstractDataUpload public dataUpload;
	AbstractTransaction public transaction;
	AbstractAccountManage public accountManage;

	event SelledDataEvent(
		string fileId, 
		address dataValidator, 
		address owner, 
		uint256 sum
	);

	event SelledDataEventPay(
		address dataValidator
	);
	
	constructor(address _transaction, address _wallet, address _dataUpload, address _accountManage) public {
		wallet = AbstractWallet(_wallet);
		dataUpload = AbstractDataUpload(_dataUpload);
		transaction = AbstractTransaction(_transaction);
		accountManage = AbstractAccountManage(_accountManage);
	}

	function sell (
		string memory _fileId, 
		address _owner,
		address _dataValidator, 
		uint256 _sum
	) public sumMoreZero(_sum) {
		require(dataUpload.checkFileExist(_owner, _fileId));
		require(accountManage.isDataMart(_owner));
		require(accountManage.isDataValidator(_dataValidator));
		selledData[_fileId] = SelledData(_fileId, _dataValidator, _owner, _sum);
		transaction.newTransaction(_fileId, 'dataSell');
		wallet.balanceReplenishment(_dataValidator, _sum);
		wallet.balanceConsumption(_owner, _sum);
		emit SelledDataEvent(_fileId, _dataValidator, _owner, _sum);
	}

	function getSellData(string memory _fileId) view public returns (string memory, address, address, uint256) {
		SelledData memory _item = selledData[_fileId];
		return (_item.fileId, _item.dataValidator, _item.owner, _item.sum);
	}
}

