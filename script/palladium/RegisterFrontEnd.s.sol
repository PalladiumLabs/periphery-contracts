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

    
contract RegisterFrontEnd is Script {
    uint256 userPrivateKey;
    address user;
    address frontEnd=0x2aCC49a84919Ab9Cf0eb6576432E9b09D78650E6; //third user of temp account
    // address stabilityPool=0x25ADF247aC836D35be924f4b701A0787A30d46a9;
    // //fork
    address stabilityPool=0x3519030725d177362f4aC3066274E6bc73B3788A;
    function setUp() public {
        string memory seedPhrase = vm.readFile(".secret");
        uint256 _userPrivateKey = vm.deriveKey(seedPhrase, 2);
        userPrivateKey=_userPrivateKey;
        user = vm.addr(userPrivateKey);
        console.log("user",user);
    }
    function run() public {
        IStabilityPool StabilityPool = IStabilityPool(stabilityPool);
        vm.startBroadcast(userPrivateKey);
        /*Provide To Stability Pool*/
        StabilityPool.registerFrontEnd(990000000000000000);//99%
    }
}