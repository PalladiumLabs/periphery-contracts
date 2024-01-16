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

contract ChangePrice is Script {
    // //testnet
    // address priceFeed=0xDC63FB38FDB04B7e2A9A01f1792a4e021538fc57;
    // //fork
    address priceFeed=0x9DC46D3bb1f305A2326F390756D3fbE37fBc6421;
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
        uint btcusdPrice=PriceFeed.fetchPrice();
        console.log("btcusdPrice",btcusdPrice);
        vm.startBroadcast(ownerPrivateKey);
        PriceFeed.setPrice(45000e18);
        btcusdPrice=PriceFeed.fetchPrice();
        console.log("btcusdPrice",btcusdPrice);
    }
}