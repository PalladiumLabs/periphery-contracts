// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../../src/WBTC.sol";

interface IMintToken{
    function mint(address to, uint256 amount) external;
    function balanceOf(address account) external view  returns (uint256);
    function transferOwnership(address newOwner) external;
}
contract MintTokens is Script {

    address _user1;
    uint256 _privateKey1;
    uint256 _privateKey2;
    address _user2;
    address token=0x321f90864fb21cdcddD0D67FE5e4Cbc812eC9e64;
    // address token=0x4CE937EBAD7ff419ec291dE9b7BEc227e191883f;
    address mintTo=0x4721ec6d9409648b7f03503b3db4eFe2dE1C57c3;
    
    function setUp() public {
        string memory seedPhrase = vm.readFile(".secret");
        uint256 privateKey1 = vm.deriveKey(seedPhrase, 1);  
        _privateKey1=privateKey1;
        _user1 = vm.addr(privateKey1);

        //fetch the private key from the file .secret2
        string memory seedPhrase2 = vm.readFile(".secret2");
        uint256 privateKey2 = vm.deriveKey(seedPhrase2, 1);  
        _privateKey2=privateKey2;
        _user2 = vm.addr(privateKey2);



    }

    function run() external {

        vm.startBroadcast(_privateKey2);
        WBTC Token=WBTC(token);
        // Mint some tokens to mintTo
        uint256 amountToMint = 200e18; // Example amount to mint
        Token.mint(mintTo, amountToMint);
        console.log("Minted", amountToMint, "tokens to mintTo at address:", mintTo);
        // // Print the balance of mintUSer
        uint256 mintToBalance = Token.balanceOf(mintTo);
        console.log("Balance of mintTo:", mintToBalance);
        // vm.stopBroadcast();
    }
}

/*
forge script script/gravita/MintTokens.s.sol:MintTokens --rpc-url http://127.0.0.1:8545/ --broadcast -vvv --legacy --slow 
forge script script/gravita/MintTokens.s.sol:MintTokens --rpc-url https://rpc.test.btcs.network --broadcast -vvv --legacy --slow 
forge script script/gravita/MintTokens.s.sol:MintTokens --rpc-url https://testnet.bitfinity.network --broadcast -vvv --legacy --slow

forge script script/gravita/MintTokens.s.sol:MintTokens --rpc-url https://node.botanixlabs.dev --broadcast -vvv --legacy --slow --with-gas-price 50
*/