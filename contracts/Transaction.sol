pragma solidity ^0.5.0;

import "./AbstractTransaction.sol";

contract Transaction is AbstractTransaction {

	uint256 public lastSyncQueue = 0;
	uint256 public queueNumber = 0;
	uint256 public dataUploadTxCount = 0;
	uint256 public dataPurchaseTxCount = 0;
	mapping (address => mapping(uint256 => Tx)) public addressTx;
	mapping (address => uint256) public addressTxCount;
	mapping (uint256 => Tx) public transactions;
	mapping (string => Tx) public transactionByHash;
	mapping (string => TxPayData) public transactionPayDataByHash;
	mapping (string => mapping(uint256 => Tx)) transactionsByType;
	
	struct Tx {
		string fileUuid;
		string txType;
		string hash;
		uint256 queueNumber;
		address serviceNode;
		address dataValidator;
		address dataMart;
		address dataOwner;
		uint256 value;
		uint created_at;
	}

	struct TxPayData {
		uint256 valueInServiceNode;
		uint256 valueInDataValidator;
		uint256 valueInDataMart;
		uint256 valueInDataOwner;
		uint256 valueOutServiceNode;
		uint256 valueOutDataValidator;
		uint256 valueOutDataMart;
		uint256 valueOutDataOwner;
	}

	event TxDataUpload(
		string fileUuid,
		string hash,
		uint256 queueNumber,
		address serviceNode,
		address dataValidator,
		address dataOwner,
		uint256 value,
		uint created_at
	);

	event TxDataPurchase(
		string fileUuid,
		string hash,
		uint256 queueNumber,
		address serviceNode,
		address dataValidator,
		address dataMart,
		address dataOwner,
		uint256 value,
		uint created_at
	);

	event TxEvent(
		string fileUuid,
		string txType,
		address serviceNode,
		address from,
		address to,
		uint256 value
	);


	function transactionDataUpload(
		string memory _uuid,
		string memory _hash,
		address _serviceNode,
		address _dataValidator,
		address _dataOwner,
		uint256 _value
	) public {
		queueNumber += 1;
		dataUploadTxCount += 1;

		TxPayData memory _txPayData = TxPayData(_value, 0, 0, 0, 0, _value, 0, 0);

		Tx memory _tx = Tx(
			_uuid,
			'dataUpload',
			_hash,
			queueNumber,
			_serviceNode,
			_dataValidator,
			address(0),
			_dataOwner,
			_value,
			now
		);
		transactions[queueNumber] = _tx;
		transactionByHash[_hash] = _tx;
		transactionPayDataByHash[_hash] = _txPayData;
		transactionsByType['dataUpload'][dataUploadTxCount] = _tx;

		addressTxCount[_serviceNode] += 1;
		addressTxCount[_dataValidator] += 1;
		addressTxCount[_dataOwner] += 1;

		addressTx[_serviceNode][addressTxCount[_serviceNode]] = _tx;
		addressTx[_dataValidator][addressTxCount[_dataValidator]] = _tx;
		addressTx[_dataOwner][addressTxCount[_dataOwner]] = _tx;



		emit TxDataUpload(
			_uuid,
			_hash,
			queueNumber,
			_serviceNode,
			_dataValidator,
			_dataOwner,
			_value,
			now
		);
	}

	function transactionDataPurchase(
		string memory _uuid,
		string memory _hash,
		address _serviceNode,
		address _dataValidator,
		address _dataMart,
		address _dataOwner,
		uint256 _value
	) public {
		queueNumber += 1;
		dataPurchaseTxCount += 1;

		uint256 _amount = _value / 2;
		TxPayData memory _txPayData = TxPayData(0, _amount, 0, _amount, 0, 0, _value, 0);

		Tx memory _tx = Tx(
			_uuid,
			'dataPurchase',
			_hash,
			queueNumber,
			_serviceNode,
			_dataValidator,
			_dataMart,
			_dataOwner,
			_value,
			now
		);
		transactions[queueNumber] = _tx;
		transactionByHash[_hash] = _tx;
		transactionPayDataByHash[_hash] = _txPayData;
		transactionsByType['dataPurchase'][dataPurchaseTxCount] = _tx;

		addressTxCount[_serviceNode] += 1;
		addressTxCount[_dataValidator] += 1;
		addressTxCount[_dataMart] += 1;
		addressTxCount[_dataOwner] += 1;

		addressTx[_serviceNode][addressTxCount[_serviceNode]] = _tx;
		addressTx[_dataValidator][addressTxCount[_dataValidator]] = _tx;
		addressTx[_dataMart][addressTxCount[_dataMart]] = _tx;
		addressTx[_dataOwner][addressTxCount[_dataOwner]] = _tx;
		emit TxDataPurchase(
			_uuid,
			_hash,
			queueNumber,
			_serviceNode,
			_dataValidator,
			_dataMart,
			_dataOwner,
			_value,
			now
		);
	}

	function setLastSyncQueue(uint256 lastQueue) public {
		lastSyncQueue = lastQueue;
	}
}
