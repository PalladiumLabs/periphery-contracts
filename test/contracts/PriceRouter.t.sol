/*command Sequence
* anvil -f https://node.botanixlabs.dev --mnemonic ".secret mnemonic"  --port 3000

* yarn deploy --network botonixFork --gas-price 1

* forge test --match-path test/palladium/PlayaroundBotanix.t.sol --fork-url http://127.0.0.1:3000/ -vvv
*/

pragma solidity ^0.8.4;
import "forge-std/Test.sol";
import "@openzeppelin/token/ERC20/IERC20.sol";

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "../../src/PriceRouter.sol";
import "../../src/PriceOracle.sol";

interface token{
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

contract PriceRouterTest is Test {
    PriceRouter routerContract;
    PriceOracle oracleContract;
    uint256 user1PrivateKey;
    uint256 user2PrivateKey;
    address user1;
    address user2;
    address owner;
    

    function setUp() public {
        string memory seedPhrase = vm.readFile(".secret");

        uint256 _user1PrivateKey = vm.deriveKey(seedPhrase, 0);
        user1PrivateKey=_user1PrivateKey;
        user1 = vm.addr(user1PrivateKey);

        uint256 _user2PrivateKey = vm.deriveKey(seedPhrase, 1);
        user2PrivateKey=_user2PrivateKey;
        user2 = vm.addr(user2PrivateKey);
        vm.startPrank(user2);
        oracleContract=new PriceOracle(60000e18);
        routerContract=new PriceRouter(address(oracleContract));
        vm.stopPrank();
        owner=user2;


    }
    function test_getPrice() public {
        uint price=routerContract.getPrice();
        console.log("price",price/1e18);
    }

    function test_setPrice() public {
        uint price=routerContract.getPrice();
        console.log("price before",price/1e18);
        vm.prank(owner);
        oracleContract.setPrice(68000e18);
        price=routerContract.getPrice();
        console.log("price after",price/1e18);
    }

    function test_upgradeOracle() public {
        uint price=routerContract.getPrice();
        console.log("price before",price/1e18);
        PriceOracle neworacle=new PriceOracle(65000e18);
        vm.prank(owner);
        routerContract.upgradeOracle(address(neworacle));
        price=routerContract.getPrice();
        console.log("price after",price/1e18);
    }
}