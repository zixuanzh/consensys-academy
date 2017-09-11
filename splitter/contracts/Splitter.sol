pragma solidity ^0.4.6;

contract Splitter {

	address public owner;
	mapping (address => uint) public balances;

	event LogDeployedEvent(address creator);
	event LogSplitEvent(address sender, address receiver1, address receiver2, uint totalAmount, uint remainder);
	event LogWithdrawEvent(address withdrawer, uint withdrawAmount, uint remainder);

	function Splitter() {
		owner = msg.sender;
		LogDeployedEvent(msg.sender);
	}

	function split(address _receiver1, address _receiver2)
		public
		payable
		returns (bool success) 
	{
		if (msg.value == 0) throw;

		uint amountToReceive = msg.value / 2;
		uint remainder = msg.value - (2 * amountToReceive);

		balances[_receiver1] += amountToReceive;
		balances[_receiver2] += amountToReceive;
		balances[msg.sender] += remainder;

		LogSplitEvent(msg.sender, _receiver1, _receiver2, msg.value, remainder);
		return true;

	}

	function withdraw(uint withdrawAmount) 
		public
		returns (bool success)
	{
		if (withdrawAmount == 0) throw;
		if (balances[msg.sender] < withdrawAmount) throw;
		uint remainder = balances[msg.sender] - withdrawAmount;
		balances[msg.sender] -= withdrawAmount;
		if (!msg.sender.send(withdrawAmount)) throw;

		LogWithdrawEvent(msg.sender, withdrawAmount, remainder);
		return true;
		
	}
}