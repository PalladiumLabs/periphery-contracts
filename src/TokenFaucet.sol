// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/token/ERC20/IERC20.sol";
import "@openzeppelin/access/Ownable.sol";

contract TokenFaucet is Ownable {
    IERC20 public token;
    uint256 public amountPerClaim;
    uint256 public claimThreshold;

    event TokensClaimed(address indexed user, uint256 amount);

    constructor(IERC20 _token, uint256 _amountPerClaim) {
        token = _token;
        amountPerClaim = _amountPerClaim;
        claimThreshold = 100000000000000000; // 0.1 tokens (assuming 18 decimals)   
    }

    function claimTokens() external {
        require(token.balanceOf(msg.sender) < claimThreshold, "Balance too high to claim");
        require(token.balanceOf(address(this)) >= amountPerClaim, "Faucet is empty");

        bool success = token.transfer(msg.sender, amountPerClaim);
        require(success, "Token transfer failed");

        emit TokensClaimed(msg.sender, amountPerClaim);
    }

    function setAmountPerClaim(uint256 _newAmount) external onlyOwner {
        amountPerClaim = _newAmount;
    }

    function setClaimThreshold(uint256 _newThreshold) external onlyOwner {
        claimThreshold = _newThreshold;
    }

    function withdrawTokens(uint256 _amount) external onlyOwner {
        require(token.balanceOf(address(this)) >= _amount, "Insufficient balance");
        bool success = token.transfer(owner(), _amount);
        require(success, "Token transfer failed");
    }
}