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
import "./interfaces/ILQTYStaking.sol";

interface token{
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

    
contract StakePDM is Script {
    uint256 userPrivateKey;
    address user;
    // address pdm= ;
    // address pdmStaking=0x25ADF247aC836D35be924f4b701A0787A30d46a9;
    // //fork
    address pdm= 0xEbe79B0eF31aFB3c893e94FE8EbF11D5CB2231d5;
    address pdmStaking=0xbfAe7bA13712783Bb14877930Cb9b7579C39F43E;
    function setUp() public {
        string memory seedPhrase = vm.readFile(".secret");
        uint256 _userPrivateKey = vm.deriveKey(seedPhrase, 2);
        userPrivateKey=_userPrivateKey;
        user = vm.addr(userPrivateKey);
        console.log("user",user);
    }
    function run() public {
        ILQTYStaking PdmStaking = ILQTYStaking(pdmStaking);
        vm.startBroadcast(userPrivateKey);
        /*Provide To Staking Contract*/
        uint256 pdmStakeAmount =500e18 ;  
        PdmStaking.stake(pdmStakeAmount);
        uint stakeAmount=PdmStaking.stakes(user);
        console.log("stakeAmount",stakeAmount);
    }
    
}