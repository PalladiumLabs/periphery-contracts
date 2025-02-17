// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/token/ERC20/ERC20.sol";
import "@openzeppelin/access/Ownable.sol";

contract WBTC is ERC20, Ownable {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    // function deposit() public payable {
    //     require(msg.value > 0, "Must send BTC");
    //     _mint(msg.sender, msg.value);
    // }

    // function withdraw(uint256 amount) public {
    //     require(amount > 0, "Amount must be greater than 0");
    //     require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        
    //     _burn(msg.sender, amount);
    //     (bool success, ) = payable(msg.sender).call{value: amount}("");
    //     require(success, "Transfer failed");
    // }

    // receive() external payable {
    //     deposit();
    // }
}