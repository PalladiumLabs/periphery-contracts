// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../../src/TokenFaucet.sol";

contract ClaimFromFaucet is Script {
    address _user1;
    uint256 _privateKey1;
    address _faucet=0x4721ec6d9409648b7f03503b3db4eFe2dE1C57c3;
    
    function setUp() public {
        string memory seedPhrase = vm.readFile(".secret");
        uint256 privateKey1 = vm.deriveKey(seedPhrase, 0);
        _privateKey1 = privateKey1;
        _user1 = vm.addr(privateKey1);
    }

    function run() external {
        vm.startBroadcast(_privateKey1);
        // Replace this address with your deployed faucet address
        TokenFaucet faucet = TokenFaucet(_faucet);
        IERC20 token = IERC20(faucet.token());
        uint256 claimThreshold = faucet.claimThreshold();
        uint256 amountPerClaim = faucet.amountPerClaim();
        console.log("Claim threshold:", claimThreshold);
        console.log("Amount per claim:", amountPerClaim);
        console.log("Token balance before:", token.balanceOf(_user1));
        faucet.claimTokens();
        console.log("Token balance after:", token.balanceOf(_user1));
        console.log("Claimed tokens for address:", _user1);
        vm.stopBroadcast();
    }
}

/*
forge script script/gravita/ClaimFromFaucet.s.sol:ClaimFromFaucet --rpc-url http://127.0.0.1:8545/ --broadcast -vvv --legacy --slow 
forge script script/gravita/ClaimFromFaucet.s.sol:ClaimFromFaucet --rpc-url https://rpc.test.btcs.network --broadcast -vvv --legacy --slow 
forge script script/gravita/ClaimFromFaucet.s.sol:ClaimFromFaucet --rpc-url https://testnet.bitfinity.network --broadcast -vvv --legacy --slow 
forge script script/gravita/ClaimFromFaucet.s.sol:ClaimFromFaucet --rpc-url https://node.botanixlabs.dev --broadcast -vvv --legacy --slow --with-gas-price 7
*/