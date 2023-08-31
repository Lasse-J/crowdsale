// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./Token.sol";

contract Crowdsale {
	address public owner;
//	address public whitelisted;
	uint256 public timestamp;
	Token public token;
	uint256 public price;
	uint256 public maxTokens;
	uint256 public tokensSold;

	// 

	event Buy(uint256 amount, address buyer);
	event Finalize(uint256 tokensSold, uint256 ethRaised);

	constructor(
		Token _token,
		uint256 _price,
		uint256 _maxTokens
	) {
		owner = msg.sender;
		timestamp = block.timestamp;
		token = _token;
		price = _price;
		maxTokens = _maxTokens;
	}

	modifier onlyOwner() {
		require(msg.sender == owner, 'Caller is not the owner');
		_;
	}

	// Crowdsale open after 1 Sep 2023 0:00 GMT
	modifier whenOpen() {
//		require(timestamp > 1693526400, 'Crowdsale opens 1 Sep 2023 at 0:00 GMT');
		require(timestamp > 1693267200, 'Crowdsale opens 30 Aug 2023 at 0:00 GMT');
		_;
	}

//	modifier onlyWhitelisted() {
//		require(whitelistedAddresses[msg.sender], "User is not whitelisted");
//		_;
//	}

	// List of whitelisted addresses
//	mapping(address => bool) whitelistedAddresses;

	// Adding an address to the whitelist
//	function addUser(address _addressToWhitelist) public onlyOwner {
//		whitelistedAddresses[_addressToWhitelist] = true;
//	}

	receive() external payable whenOpen {
		uint256 amount = msg.value / price;
		buyTokens(amount * 1e18);
	}

	// remember to add onlyWhitelisted
	function buyTokens(uint256 _amount) public payable whenOpen {
		require(msg.value == (_amount / 1e18) * price);
		require(token.balanceOf(address(this)) >= _amount);
		require(token.transfer(msg.sender, _amount));

		tokensSold += _amount;

		emit Buy(_amount, msg.sender);
	}

	function setPrice(uint256 _price) public onlyOwner {
		price = _price;
	}

	function finalize() public onlyOwner {
		// Send remaining tokens (LASSE) to crowdsale creator
		require(token.transfer(owner, token.balanceOf(address(this))));

		// Send Ether to crowdsale creator
		uint256 value = address(this).balance;
		(bool sent, ) = owner.call{value: value }("");
		require(sent);

		emit Finalize(tokensSold, value);
	}

}
