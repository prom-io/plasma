pragma solidity ^0.5.0;

import "./AbstractTransaction.sol";

contract Transaction is AbstractTransaction {

	uint256 public queueNumber = 0;
	uint256 public lastSyncQueue = 0;
	mapping (uint256 => PendingTransaction) public pendingTransactions;

	struct PendingTransaction {
		string uuid;
		string txType;
		string hash;
		uint256 queueNumber;
	}

	event PendingTransactionEvent(
		string uuid,
		string txType,
		uint256 queueNumber
	);

	function newTransaction (string memory _uuid, string memory _type) public {
		queueNumber += 1;
		pendingTransactions[queueNumber] = PendingTransaction(_uuid, _type, '', queueNumber);
		emit PendingTransactionEvent(_uuid, _type, queueNumber);
	}

	function setTransaction (string memory _hash, uint _queueNumber) public {
		PendingTransaction memory _pendingTransaction = pendingTransactions[_queueNumber];
		_pendingTransaction.hash = _hash;
		pendingTransactions[_queueNumber] = _pendingTransaction;
	}

	function setLastSyncQueue(uint256 lastQueue) public {
		lastSyncQueue = lastQueue;
	}

	function getTransaction(uint _queueNumber) view public returns(
			string memory, 
			string memory,
			string memory,
			uint256
		) {
		PendingTransaction memory _item = pendingTransactions[_queueNumber];
		return (_item.uuid, _item.txType, _item.hash, _item.queueNumber);
	}

	function getQueue() external view returns(uint256) {
		return queueNumber;
	}
}
