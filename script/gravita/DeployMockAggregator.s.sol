pragma solidity ^0.8.4;
import "forge-std/Script.sol";
import "../../src/MockAggregator.sol";

contract DeployMockAggregator is Script {

    address _user1;
    uint256 _privateKey1;

    function setUp() public {
        string memory seedPhrase = vm.readFile(".secret");
        uint256 privateKey1 = vm.deriveKey(seedPhrase, 0);  
        _privateKey1 = privateKey1;
        _user1 = vm.addr(privateKey1);
    }


    function run() external {
        int256 initialAnswer = 95000e8;/// 2000e8; // Example initial answer
        uint8 decimals = 8; // Example decimals
        uint80 initialRoundId = 1; // Example initial round ID

        vm.startBroadcast(_privateKey1);
        MockAggregator mockAggregator = new MockAggregator(initialAnswer, decimals, initialRoundId);
        console.log("MockAggregator deployed at:", address(mockAggregator));
        vm.stopBroadcast();
    }
}

/*
forge script script/gravita/DeployMockAggregator.s.sol:DeployMockAggregator --rpc-url http://127.0.0.1:8545/ --broadcast -vvv --legacy --slow --with-gas-price 7
forge script script/gravita/DeployMockAggregator.s.sol:DeployMockAggregator --rpc-url https://rpc.test.btcs.network --broadcast -vvv --legacy --slow 
forge script script/gravita/DeployMockAggregator.s.sol:DeployMockAggregator --rpc-url https://testnet.bitfinity.network --broadcast -vvv --legacy --slow 
forge script script/gravita/DeployMockAggregator.s.sol:DeployMockAggregator --rpc-url https://node.botanixlabs.dev --broadcast -vvv --legacy --slow --with-gas-price 7
*/