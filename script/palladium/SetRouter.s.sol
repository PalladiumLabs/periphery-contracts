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


contract SetRouter is Script {
    // //testnet
    // address priceFeed=0xDC63FB38FDB04B7e2A9A01f1792a4e021538fc57;
    // //fork
    address priceFeed=0xbA42bA670a8966F21708eEE4324DafDa1225B1CC;
    address _priceRouterAddress=0x77b713201dDA5805De0F19f4B8a127Cc55f6dac6;
    uint256 ownerPrivateKey;
    address user1;//owner of feed
    function setUp() public {
        string memory seedPhrase = vm.readFile(".secret");
        uint256 _ownerPrivateKey = vm.deriveKey(seedPhrase, 0);
        ownerPrivateKey=_ownerPrivateKey;
        user1 = vm.addr(ownerPrivateKey);
    }
    function run() public {
        IPriceFeed PriceFeed = IPriceFeed(priceFeed);
        vm.broadcast(ownerPrivateKey);
        PriceFeed.setAddresses(_priceRouterAddress);
    }
}