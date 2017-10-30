pragma solidity ^0.4.9;

contract SecureAndClean {

  /// Mapping of ether shares of the contract.
  mapping(address => uint) shares;
  // Funds available for withdraw for shareholders
  mapping(address => uint) pendingShares;
  address owner;
  address[] shareholders;

  event FailedSend(address, uint);

  function SecureAndClean() {
	owner = msg.sender;
  }

  function () payable {
	// Adding new shareholder, and it's shares.
	shares[msg.sender] = msg.value;
	shareholders.push(msg.sender);
  }

  /// Withdraw your available share.
  function withdraw() returns (bool) {
	uint amount = pendingShares[msg.sender];
	if (amount > 0) {
	  pendingShares[msg.sender] = 0;

	  if (msg.sender.send(amount)) {
		return true;
	  } else {
		FailedSend(msg.sender, amount);
		pendingShares[msg.sender] = amount;
		return false;
	  }
	}
  }

  function dispense() {
	require(msg.sender == owner);
	address shareholder;
	for (uint i = 0; i < shareholders.length; i++) {
	  shareholder = shareholders[i];

	  // Move funds from shares -> pendingShares
	  pendingShares[shareholder] += shares[shareholder];
	  shares[shareholder] = 0;
	}
  }

}
