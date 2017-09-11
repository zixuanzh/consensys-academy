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
	
	function getBalance(address _address)
	    public
	    constant
	    returns (uint balance) 
    {
        return balances[_address];   
	}

	function split(address _receiver1, address _receiver2)
		public
		payable
		returns (bool success) 
	{
		// not sure how to check validity of _receiver1 and _receiver2
		if (msg.value == 0) throw;

		uint amountToReceive;
		uint remainder;

		if (msg.value % 2 == 0) {
			amountToReceive = msg.value / 2;
			remainder = 0;
		} else {
			amountToReceive = (msg.value - 1) / 2;
			remainder = 1;
		}

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

	function terminate()
		public
	{
		if (msg.sender != owner) throw;
		suicide(owner);
	}
}
