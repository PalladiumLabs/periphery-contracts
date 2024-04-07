pragma solidity ^0.8.4;
import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "../../src/PriceRouter.sol";
import "../../src/PriceOracle.sol";
import "@openzeppelin/token/ERC20/IERC20.sol";

contract DeployOracle is Script {
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
        PriceOracle priceOracle = new PriceOracle(66000e18);
        console.log("priceOracle",address(priceOracle));
        vm.stopBroadcast(); 
    }
}

