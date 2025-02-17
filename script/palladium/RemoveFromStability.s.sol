pragma solidity ^0.8.4;
import "forge-std/Test.sol";
import "@openzeppelin/token/ERC20/IERC20.sol";

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "./interfaces/IBorrowerOperations.sol";
import "./interfaces/IHintHelpers.sol";
import "./interfaces/ISortedTroves.sol";
import "./interfaces/IPriceFeed.sol";
import "./interfaces/ITroveManager.sol";
import "./interfaces/ICollSurplusPool.sol";
import "./interfaces/IStabilityPool.sol";

interface token{
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

    
contract RemoveFromStability is Script {
    uint256 userPrivateKey;
    address user;
    // address pusd= 0x55FD5B67B115767036f9e8af569B281A8A544a12;
    // address stabilityPool=0x25ADF247aC836D35be924f4b701A0787A30d46a9;
    // //fork
    address pusd= 0xEaB76Bb6f8E5f6f880Ea36e51b5D7520a60AfFCF;
    address stabilityPool=0x8FBa9ab010923d3E1c60eD34DAE255A2E7b98Edc;
    function setUp() public {
        string memory seedPhrase = vm.readFile(".secret");
        uint256 _userPrivateKey = vm.deriveKey(seedPhrase, 0);
        userPrivateKey=_userPrivateKey;
        // user = vm.addr(userPrivateKey);
        user=0x2aCC49a84919Ab9Cf0eb6576432E9b09D78650E6;
        console.log("user",user);
    }
    function run() public {
        IStabilityPool StabilityPool = IStabilityPool(stabilityPool);
        // vm.startBroadcast(userPrivateKey);
        vm.startPrank(user);
        /*Provide To Stability Pool*/
        // uint256 withdrawAmount =200e18 ;  
        uint256 getCompoundedLUSDDeposit=StabilityPool.getCompoundedLUSDDeposit(user);
        console.log("getCompoundedLUSDDeposit ",getCompoundedLUSDDeposit);
        console.log("pusd balance before Provide To Stability Pool ",IERC20(pusd).balanceOf(user));
        StabilityPool.withdrawFromSP(getCompoundedLUSDDeposit);
        console.log("pusd balance after Provide To Stability Pool ",IERC20(pusd).balanceOf(user));
        getCompoundedLUSDDeposit=StabilityPool.getCompoundedLUSDDeposit(user);
        console.log("getCompoundedLUSDDeposit ",getCompoundedLUSDDeposit);
    }
    
}

/*
forge script script/palladium/RemoveFromStability.s.sol:RemoveFromStability --rpc-url http://127.0.0.1:3000/ --broadcast -vvv --legacy --slow

forge script script/palladium/RemoveFromStability.s.sol:RemoveFromStability --rpc-url https://sepolia.infura.io/v3/ad9cef41c9c844a7b54d10be24d416e5 --broadcast -vvv --legacy --slow

forge script script/palladium/RemoveFromStability.s.sol:RemoveFromStability --rpc-url https://node.botanixlabs.dev --broadcast -vvv --legacy --slow --with-gas-price 15
*/
