pragma solidity ^0.8.4;
import "forge-std/Test.sol";
import "@openzeppelin/token/ERC20/IERC20.sol";

import "../../src/MockAggregator.sol";
import "forge-std/Script.sol";
import "forge-std/console2.sol";

interface IPair{
   function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external ;
}

    
contract UpdatePriceMock is Script {
    uint256 userPrivateKey;
    address user;
    address mockAggregator=0xc014933c805825D335e23Ef12eB92d2471D41DA7;
    int256 updatedPRice=96500e8;

  
    function setUp() public {
        string memory seedPhrase = vm.readFile(".secret");
        uint256 _userPrivateKey = vm.deriveKey(seedPhrase, 2);
        userPrivateKey=_userPrivateKey;
        user = vm.addr(userPrivateKey);
    }
    function run() public {
        // vm.startBroadcast(userPrivateKey);
        console.log("herw");
        (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound) = MockAggregator(mockAggregator).latestRoundData();
        // uint price=PriceRouter(priceRouter).getPrice();
        console2.logInt(answer);
        MockAggregator(mockAggregator).setLatestAnswer(updatedPRice);
        ( roundId, answer,  startedAt,  updatedAt,  answeredInRound) = MockAggregator(mockAggregator).latestRoundData();
        console2.logInt(answer);
        // vm.stopBroadcast();
    }
    
}

/*
forge script script/gravita/UpdatePriceMock.s.sol:UpdatePriceMock --rpc-url https://rpc.test.btcs.network --broadcast -vvv --legacy --slow
forge script script/gravita/UpdatePriceMock.s.sol:UpdatePriceMock --rpc-url https://testnet.bitfinity.network --broadcast -vvv --legacy --slow
forge script script/gravita/UpdatePriceMock.s.sol:UpdatePriceMock --rpc-url http://127.0.0.1:8545 --broadcast -vvv --legacy --slow
forge script script/gravita/UpdatePriceMock.s.sol:UpdatePriceMock --rpc-url https://node.botanixlabs.dev --broadcast -vvv --legacy --slow --with-gas-price 7
*/