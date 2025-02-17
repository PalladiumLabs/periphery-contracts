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

    
contract ProvideToStability is Script {
    uint256 userPrivateKey;
    address user;
    // address userTemp=0x9FDA00A2AEFbE11af8e767FF7f90a56DB502D12b;
    // address pusd= 0x55FD5B67B115767036f9e8af569B281A8A544a12;
    // address stabilityPool=0x25ADF247aC836D35be924f4b701A0787A30d46a9;
    // //fork
    address pusd= 0xB7d7027B5dD0c50946dE98c26e5969b37D588c32;
    address stabilityPool=0xb5d2f71f2B1506Ec243D0B232EB15492d685B689;
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
        uint256 stablePoolDepAmount =500e18 ;  
        console.log("pusd balance before Provide To Stability Pool ",IERC20(pusd).balanceOf(user));
        StabilityPool.provideToSP(IERC20(pusd).balanceOf(user)/10, address(0));
        console.log("pusd balance after Provide To Stability Pool ",IERC20(pusd).balanceOf(user));
        uint256 getCompoundedLUSDDeposit=StabilityPool.getCompoundedLUSDDeposit(user);
        console.log("getCompoundedLUSDDeposit ",getCompoundedLUSDDeposit);
        
    }
}