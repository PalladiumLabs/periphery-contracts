pragma solidity ^0.8.4;
import "forge-std/Test.sol";
import "@openzeppelin/token/ERC20/IERC20.sol";

import "../../src/PriceRouter.sol";
import "../../src/PriceOracle.sol";
import "forge-std/Script.sol";
import "forge-std/console2.sol";

interface IPair{
   function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external ;
}

    
contract UpdatePrice is Script {
    uint256 userPrivateKey;
    address user;
    address priceOracle=0x9080325bA305953c0Dae207da8d424991DDf8186;
    uint updatedPRice=70000e18;
    address priceRouter=0x77b713201dDA5805De0F19f4B8a127Cc55f6dac6;
  
    function setUp() public {
        string memory seedPhrase = vm.readFile(".secret");
        uint256 _userPrivateKey = vm.deriveKey(seedPhrase, 0);
        userPrivateKey=_userPrivateKey;
        user = vm.addr(userPrivateKey);
    }
    function run() public {
        vm.startBroadcast(userPrivateKey);
        uint price=PriceRouter(priceRouter).getPrice();
        console.log("priceBefore",price/1e18);
        PriceOracle(priceOracle).setPrice(updatedPRice);
        price=PriceRouter(priceRouter).getPrice();
        console.log("priceAfter",price/1e18);
        vm.stopBroadcast();
    }
    
}