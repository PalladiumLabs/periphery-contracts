pragma solidity ^0.8.4;
import "forge-std/Test.sol";
import "@openzeppelin/token/ERC20/IERC20.sol";

import "../../src/MockAggregator.sol";
import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "./interfaces/IDebtToken.sol";


interface IPair{
   function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external ;
}

    
contract WhiteList is Script {
    uint256 userPrivateKey;
    address user;
  
    function setUp() public {
        string memory seedPhrase = vm.readFile(".secret");
        uint256 _userPrivateKey = vm.deriveKey(seedPhrase, 0);
        userPrivateKey=_userPrivateKey;
        user = vm.addr(userPrivateKey);
    }
    function run() public {
        IDebtToken DebtToken=IDebtToken(0x034B5b6F6759347F6Aa7176fB1425BC80D1a12F4);
        vm.startBroadcast(userPrivateKey);
        DebtToken.addWhitelist(0xF5FF801Af656a9184EC05973B0E35c2f1ECC844E);
        vm.stopBroadcast();
    }
    
}

/*
forge script script/gravita/WhiteList.s.sol:WhiteList --rpc-url https://rpc.test.btcs.network --broadcast -vvv --legacy --slow
forge script script/gravita/WhiteList.s.sol:WhiteList --rpc-url http://127.0.0.1:8545 --broadcast -vvv --legacy --slow
*/