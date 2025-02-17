// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "./IDeposit.sol";

interface ITimelockTester {

	function queueTransaction(
		address target,
		uint value,
		string memory signature,
		bytes memory data,
		uint eta
	) external  returns (bytes32);

    function executeTransaction(
		address target,
		uint value,
		string memory signature,
		bytes memory data,
		uint eta
	) external payable returns (bytes memory);

	function setSoftening(
		address target,
		string memory signature,
		bytes memory data
	) external  returns (bytes memory) ;
}
