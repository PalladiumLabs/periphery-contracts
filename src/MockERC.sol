// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/token/ERC20/ERC20.sol";
import "@openzeppelin/access/Ownable.sol";

contract MockERC is ERC20, Ownable {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function mint(address to, uint256 amount) public onlyOwner {
        require(totalSupply() + amount <= 10000 * (10 ** decimals()), "Minting would exceed max supply");
        _mint(to, amount);
    }
}