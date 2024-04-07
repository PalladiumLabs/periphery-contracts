pragma solidity ^0.8.4;
import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "../../src/PriceRouter.sol";
import "../../src/PriceOracle.sol";
import "@openzeppelin/token/ERC20/IERC20.sol";

contract DeployRouter is Script {
    address priceOracle=0x9080325bA305953c0Dae207da8d424991DDf8186;
    address _user1;
    uint256 _privateKey1;



    function setUp() public {
        string memory seedPhrase = vm.readFile(".secret");
        uint256 privateKey1 = vm.deriveKey(seedPhrase, 0);  
        _privateKey1=privateKey1;
        _user1 = vm.addr(privateKey1);

    }

    function run() public {
        vm.startBroadcast(_privateKey1);
        PriceRouter priceRouter = new PriceRouter(address(priceOracle));
        console.log("priceRouter",address(priceRouter));
        vm.stopBroadcast(); 
    }
}

