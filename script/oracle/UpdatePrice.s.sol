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
    address priceOracle=0x5BCC7cf55D3ce55cF97E05776F8155b595D40a78;
    uint updatedPRice=70000e18;
    address priceRouter=0x48e8b294f36e68C9F7f2380A7d67CbD80E792eaB;
    address ownerOracle=0x961Ef0b358048D6E34BDD1acE00D72b37B9123D7;

  
    function setUp() public {
        string memory seedPhrase = vm.readFile(".secret");
        uint256 _userPrivateKey = vm.deriveKey(seedPhrase, 1);
        userPrivateKey=_userPrivateKey;
        user = vm.addr(userPrivateKey);
    }
    function run() public {
        vm.startBroadcast(userPrivateKey);
        uint price=PriceRouter(priceRouter).getPrice();
        console.log("priceBefore",price/1e18);
        // PriceOracle(priceOracle).setPrice(updatedPRice);
        // price=PriceRouter(priceRouter).getPrice();
        // console.log("priceAfter",price/1e18);
        vm.stopBroadcast();
    }
    
}

//forge script script/oracle/UpdatePrice.s.sol:UpdatePrice --rpc-url https://node.botanixlabs.dev --broadcast -vvv --legacy --slow --with-gas-price 7