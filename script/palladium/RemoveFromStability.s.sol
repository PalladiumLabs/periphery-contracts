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
    address pusd= 0xA505CFC9480b82320D57c863B69418D66D297803;
    address stabilityPool=0x3519030725d177362f4aC3066274E6bc73B3788A;
    function setUp() public {
        string memory seedPhrase = vm.readFile(".secret");
        uint256 _userPrivateKey = vm.deriveKey(seedPhrase, 0);
        userPrivateKey=_userPrivateKey;
        user = vm.addr(userPrivateKey);
        console.log("user",user);
    }
    function run() public {
        IStabilityPool StabilityPool = IStabilityPool(stabilityPool);
        vm.startBroadcast(userPrivateKey);
        /*Provide To Stability Pool*/
        uint256 withdrawAmount =200e18 ;  
        uint256 getCompoundedLUSDDeposit=StabilityPool.getCompoundedLUSDDeposit(user);
        console.log("getCompoundedLUSDDeposit ",getCompoundedLUSDDeposit);
        console.log("pusd balance before Provide To Stability Pool ",IERC20(pusd).balanceOf(user));
        StabilityPool.withdrawFromSP(withdrawAmount);
        console.log("pusd balance after Provide To Stability Pool ",IERC20(pusd).balanceOf(user));
        getCompoundedLUSDDeposit=StabilityPool.getCompoundedLUSDDeposit(user);
        console.log("getCompoundedLUSDDeposit ",getCompoundedLUSDDeposit);
    }
    
}