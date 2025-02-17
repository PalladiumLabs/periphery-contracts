  // SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../../src/TokenFaucet.sol";

contract DeployFaucet is Script {

    address _user1;
    uint256 _privateKey1;
    function setUp() public {
        string memory seedPhrase = vm.readFile(".secret");
        uint256 privateKey1 = vm.deriveKey(seedPhrase, 0);
        _privateKey1=privateKey1;
        _user1 = vm.addr(privateKey1);

    }

    function run() external {
        vm.startBroadcast(_privateKey1);
        // Deploy the WETH token
        // TokenFaucet tokenFaucet = new TokenFaucet(IERC20(0x321f90864fb21cdcddD0D67FE5e4Cbc812eC9e64),10000000000000000);
        TokenFaucet tokenFaucet =TokenFaucet(0x4721ec6d9409648b7f03503b3db4eFe2dE1C57c3);
        tokenFaucet.setClaimThreshold(10000000000000000);
        console.log(tokenFaucet.claimThreshold());
        console.log("tokenFaucet deployed at:", address(tokenFaucet));
        vm.stopBroadcast();
    }
}

/*
forge script script/gravita/DeployFaucet.s.sol:DeployFaucet --rpc-url http://127.0.0.1:8545/ --broadcast -vvv --legacy --slow 
forge script script/gravita/DeployFaucet.s.sol:DeployFaucet --rpc-url https://rpc.test.btcs.network --broadcast -vvv --legacy --slow 
forge script script/gravita/DeployFaucet.s.sol:DeployFaucet --rpc-url https://testnet.bitfinity.network --broadcast -vvv --legacy --slow 
forge script script/gravita/DeployFaucet.s.sol:DeployFaucet --rpc-url https://node.botanixlabs.dev --broadcast -vvv --legacy --slow --with-gas-price 7
*/