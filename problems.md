# InSecureAndMessy contract

It's actually not clear (since contract has too many bugs in it) what was initial idea about adding shareholders. Does owner of contract meant that anybody may attend in contract, or shareholders need to be added first by owner of contract? I will assume first.

However, if idea was in second point - we'll need to replace `tx.origin` to `msg.sender` in `addShareholder` method and throw an exception if `msg.sender` in fallback function is unknown.

After reading original code I will assume following:

- Any user(address) is allowed to attend in shares.
- Idea of contract allow users to take part in shares. After owner of contract calls `dispense` function users should get their shares back.


## Bugs and mistakes:

- `addShareHolder` and `fallback function` may be called separately. Actually, separating `addShareholder` doesn't make sense and needs to be moved fallback function.

```
   function () payable {
      shares[msg.sender] = msg.value;
   }
```

Needs to changed to

```
   function () payable {
      shares[msg.sender] = msg.value;
	  shareholders.push(msg.sender);
   }
```

- Adding shareholder check `tx.origin` instead of `msg.sender`. Since we can call `send` or `transfer` - we probably may execute untrusted contract function, which may call `addShareholder` function - and this context `tx.origin` == `owner` always. So, attacker address may be added to list of shareholders
So, replacing `tx.origin` with `msg.sender` fixes trivial bug, however removing this method match better.

- `withdraw` function has re-entrancy bug in it. Since we execute `send` before we decrease amount in shares. Attacker contract may call `withdraw` again in it's fallback function. See suggested solution, idea is just allow withdraw amount of funds available in `pendingShares` mapping. Calling `send` happens only if any amount present for send.

Original code:
```
   /// Withdraw your share.
   function withdraw() {
     if (msg.sender.send(shares[msg.sender])) {
         shares[msg.sender] = 0;
      } else {
         FailedSend(msg.sender, shares[msg.sender]);
      }
   }
```

Needs to changed to something close to:

```
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
```

- In `dispense` method `for` statement declares `i` as `uint8` by default. Need to explicitly define `uint`. Otherwise in number if shareholders more than 255, it will never end.

```
      for (var i = 0; i < shareholders.length; i++) {
```

change to:

```
      for (uint i = 0; i < shareholders.length; i++) {
```

- Current implementation of `dispence` makes optimistic assumption that every `send` will successfully passed. Which is incorrect. If `send` function will return false, we should at least return back funds to shares. I said at least, because as I mentioned above I guess we should just make funds available for retrieve for users.

Better implementation from my point of view, would be:

```
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
```


## Example of attacker contract which will empty InSecureAndMessy funds

See attached file `contracts/Attacker.sol'`. It will simply use re-entrancy attack mentioned above. We assume that we can predict number of iteration to empty victim's address. In real world, probably we will need make number of iterations slightly lower, in case somebody else withdraw funds at the same moment.
