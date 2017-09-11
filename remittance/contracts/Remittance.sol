pragma solidity ^0.4.6;

import "./Stoppable.sol";

contract Remittance is Stoppable {
	address public owner;
	uint public fee;

	function Remittance() {
		owner = msg.sender;
		// transaction cost 43058 gas
		// gas price 4 Gwei
		fee = 4000000000 *  100000; // gas price * gas
	}

	struct Lock {
		uint remittanceAmount;
		bytes32 key;
	}

	mapping (address => Lock) public remittances;
	mapping (address => uint) public availableBalances;

	event LogRemittanceSent(address sender, uint amount, bytes32 key);
	event LogRemittanceUnlocked(address sender, address receiver, uint amount);
	event LogRemittanceWithdrawn(address receiver, uint amount);

	function sendRemittance(bytes32 _key) 
		public
		payable
		returns (bool success)
	{
		if (_key == 0) throw;
		if ((msg.value - fee) <= 0) throw;
		remittances[msg.sender].remittanceAmount += (msg.value - fee);
		remittances[msg.sender].key = _key;
		LogRemittanceSent(msg.sender, (msg.value - fee), _key);
		return true;
	}

	function unlockRemittance(bytes32 _hash1, bytes32 _hash2, address _sender)
		public
		returns (bool success)
	{
		bytes32 _key = keccak256(_hash1, _hash2);
		if (remittances[_sender].remittanceAmount <= 0) throw;
		if (remittances[_sender].key != _key) throw;
		uint remittanceAmount = remittances[_sender].remittanceAmount;
		remittances[_sender].remittanceAmount = 0;
		availableBalances[msg.sender] += remittanceAmount;
		LogRemittanceUnlocked(_sender, msg.sender, remittanceAmount);
		return true;
	}

	function withdrawBalance(uint withdrawAmount)
		public
		returns (bool success) 
		{
			if (withdrawAmount == 0) throw;
			if (availableBalances[msg.sender] < withdrawAmount) throw;
			availableBalances[msg.sender] -= withdrawAmount;
			if (!msg.sender.send(withdrawAmount)) throw;
			LogRemittanceWithdrawn(msg.sender, withdrawAmount);
			return true;
		}
}
