pragma solidity ^0.8.4;
import "forge-std/Test.sol";
import "@openzeppelin/token/ERC20/IERC20.sol";

import "forge-std/Script.sol";
import "forge-std/console2.sol";

import "./interfaces/IBorrowerOperations.sol";
import "./interfaces/IAdminContract.sol";
import "./interfaces/ISortedVessels.sol";
import "./interfaces/IPriceFeed.sol";
import "./interfaces/IVesselManagerOperations.sol";
import "./interfaces/IVesselManager.sol";
import "./interfaces/ICollSurplusPool.sol";
import "./interfaces/IStabilityPool.sol";
import "./interfaces/IPriceFeed.sol";
import "./interfaces/ITimelockTester.sol";

contract UpdateMintCap is Script {
    uint256 userPrivateKey;
    address user;

    // Update these values as needed
    address collToken = 0x321f90864fb21cdcddD0D67FE5e4Cbc812eC9e64; //wbtc
    uint256 newMintCap = 500000000e18; // Set your desired mint cap here

    address borrowerOperations =0x6f7b404474D551D70d0D30b3ed113a671eF44970;
    address vesselManager = 0x2Fef509fA966B614483B411f8cA3208C26da3c4b;
    address vesselManagerOperations = 0xd4B76b6e5E56F1DAD86c96D275831dEfdB9473c1;
    address adminContract=0x36F40faDe724ECd183b6E93F2448de65207b08A2;
    address sortedVessels=0x494A934864c4c040B5Fa1b7f6e7Ff6a7A6900BfB;
    address priceFeed=0x800755300090fFE065437fe12751910c96452aA4;
    address collSurplusPool=0x14466C44e49AcEd47c5FDdB0cA28b8aac66cd63D;
    address stabilityPool=0x56984Cc217B0a72DE3f641AF387EdD21164BbE78;
    address debtToken= 0xe19cE0aCF70DBD7ff9Cb80715f84aB0Fd72B57AC;
    address timelockTester=0xF9ca0da3FA8376449c6f189F5c5d929BDFAa20F8;
    address feeCollector=0x1bD155E6bE9b6E50B6ea0E956AcC84129538b782;

    function setUp() public {
        string memory seedPhrase = vm.readFile(".secret");
        uint256 _userPrivateKey = vm.deriveKey(seedPhrase, 1);
        userPrivateKey = _userPrivateKey;
        user = vm.addr(userPrivateKey);
    }

    function run() public {
        IAdminContract AdminContract = IAdminContract(adminContract);
        ITimelockTester TimelockTester = ITimelockTester(timelockTester);

        vm.startBroadcast(userPrivateKey);

        // Get current mint cap
        uint256 currentMintCap = AdminContract.getMintCap(collToken);
        console.log("Current mint cap:", currentMintCap);

        // Encode the setMintCap function call
        bytes memory data = abi.encode(
            collToken,
            newMintCap
        );

        //check if isSetupInitialized
        bool isSetupInitialized = AdminContract.isSetupInitialized();
        console.log("isSetupInitialized:", isSetupInitialized);

        if(isSetupInitialized){    
            // Call setSoftening with the encoded setMintCap parameters
            TimelockTester.setSoftening(
                address(AdminContract),
                "setMintCap(address,uint256)",
                data
            );
        }else{
           //direct call
           AdminContract.setMintCap(collToken, newMintCap);
        }   


        // Get updated mint cap
        uint256 updatedMintCap = AdminContract.getMintCap(collToken);
        console.log("Updated mint cap:", updatedMintCap);

        vm.stopBroadcast();
    }
}

/*
forge script script/gravita/UpdateMintCap.s.sol:UpdateMintCap --rpc-url http://127.0.0.1:8545/ --broadcast -vvv --legacy --slow --with-gas-price 15

forge script script/gravita/UpdateMintCap.s.sol:UpdateMintCap --rpc-url https://rpc.test.btcs.network --broadcast -vvv --legacy --slow

forge script script/gravita/UpdateMintCap.s.sol:UpdateMintCap --rpc-url https://rpc.ankr.com/botanix_testnet --broadcast -vvv --legacy --slow --with-gas-price 45
*/