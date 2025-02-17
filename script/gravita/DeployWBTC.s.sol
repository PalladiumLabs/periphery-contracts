// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../../src/WBTC.sol";

contract DeployWBTC is Script {

    address _user1;
    uint256 _privateKey1;
    function setUp() public {
        string memory seedPhrase = vm.readFile(".secret");
        uint256 privateKey1 = vm.deriveKey(seedPhrase, 1);  
        _privateKey1=privateKey1;
        _user1 = vm.addr(privateKey1);

    }

    function run() external {
        vm.startBroadcast(_privateKey1);
        // Deploy the WETH token
        WBTC wbtc = new WBTC("Wrapped BTC","WBTC");
        console.log("WBTC deployed at:", address(wbtc));
        // Mint some tokens to user1
        uint256 amountToMint = 10e18; // Example amount to mint
        wbtc.mint(_user1, amountToMint);
        console.log("Minted", amountToMint, "tokens to user1 at address:", _user1);
        // Print the balance of user1
        uint256 user1Balance = wbtc.balanceOf(_user1);
        console.log("Balance of user1:", user1Balance);
        vm.stopBroadcast();
    }
}

/*
forge script script/gravita/DeployWBTC.s.sol:DeployWBTC --rpc-url http://127.0.0.1:8545/ --broadcast -vvv --legacy --slow  --with-gas-price 7
forge script script/gravita/DeployWBTC.s.sol:DeployWBTC --rpc-url https://rpc.test.btcs.network --broadcast -vvv --legacy --slow 
forge script script/gravita/DeployWBTC.s.sol:DeployWBTC --rpc-url https://node.botanixlabs.dev --broadcast -vvv --legacy --slow --with-gas-price 7
*/