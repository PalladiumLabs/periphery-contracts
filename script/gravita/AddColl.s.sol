// SPDX-License-Identifier: MIT
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
import "./interfaces/ITimelockTester.sol";

contract AddColl is Script {
    uint256 userPrivateKey;
    address user;

    // Update these addresses for your specific collateral
    address collToken =0xFE38CACa0D06EA8D42A88E3AE1535Aa34F592bC2;  // Your collateral token address
    address oracleAddress = 0xc014933c805825D335e23Ef12eB92d2471D41DA7;  // Your oracle address

    // System contract addresses (same as UpdateOracle.s.sol)
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
        userPrivateKey = vm.deriveKey(seedPhrase, 1);
        user = vm.addr(userPrivateKey);
    }

    function run() public {
        IPriceFeed PriceFeed = IPriceFeed(priceFeed);
        IAdminContract AdminContract = IAdminContract(adminContract);
        ITimelockTester TimelockTester = ITimelockTester(timelockTester);

        vm.startBroadcast(userPrivateKey);

        bool isSetupInitialized = AdminContract.isSetupInitialized();
        console.log("isSetupInitialized:", isSetupInitialized);

        // 1. Set Oracle
        if (isSetupInitialized) {
            bytes memory setOracleData = abi.encode(
                collToken,
                oracleAddress,
                IPriceFeed.ProviderType.Chainlink,
                1440,
                false,
                false
            );
            TimelockTester.setSoftening(
                address(PriceFeed),
                "setOracle(address,address,uint8,uint256,bool,bool)",
                setOracleData
            );
        } else {
            PriceFeed.setOracle(collToken, oracleAddress, IPriceFeed.ProviderType.Chainlink, 1440, false, false);
        }
        
        //fetych and print price
        uint256 price = PriceFeed.fetchPrice(collToken);
        console.log("price:", price);

        
        // 2. Add New Collateral
        if (isSetupInitialized) {
            bytes memory addCollateralData = abi.encode(
                collToken,
                10e18,
                18
            );
            TimelockTester.setSoftening(
                address(AdminContract),
                "addNewCollateral(address,uint256,uint256)",
                addCollateralData
            );
        } else {
            AdminContract.addNewCollateral(collToken, 10e18, 18);
        }

        // 3. Set Collateral Parameters
        if (isSetupInitialized) {
            bytes memory setParamsData = abi.encode(
                collToken,
                0.025 ether,
                1.3 ether,
                1.1 ether,
                100e18,
                5000000e18,
                200,
                0.005 ether
            );
            TimelockTester.setSoftening(
                address(AdminContract),
                "setCollateralParameters(address,uint256,uint256,uint256,uint256,uint256,uint256,uint256)",
                setParamsData
            );
        } else {
            AdminContract.setCollateralParameters(
                collToken,
                0.025 ether,
                1.3 ether,
                1.1 ether,
                100e18,
                5000000e18,
                200,
                0.005 ether
            );
        }

        // 4. Set Redemption Block Timestamp
        uint256 blockTimestamp = 1736162894;
        if (isSetupInitialized) {
            bytes memory setRedemptionData = abi.encode(
                collToken,
                blockTimestamp
            );
            TimelockTester.setSoftening(
                address(AdminContract),
                "setRedemptionBlockTimestamp(address,uint256)",
                setRedemptionData
            );
        } else {
            AdminContract.setRedemptionBlockTimestamp(collToken, blockTimestamp);
        }
        

        //check copllateral is active
        bool isActive = AdminContract.getIsActive(collToken);
        console.log("isActive:", isActive);

        uint256 price1 = PriceFeed.fetchPrice(collToken);
        console.log("price:", price1);

        // uint256 mcr = AdminContract.getMcr(collToken);
        // console.log("mcr:", mcr);


        vm.stopBroadcast();
    }
}


/*
forge script script/gravita/AddColl.s.sol:AddColl --rpc-url http://127.0.0.1:8545/ --broadcast -vvv --legacy --slow --with-gas-price 100 --evm-version shanghai

forge script script/gravita/AddColl.s.sol:AddColl --rpc-url https://rpc.test.btcs.network --broadcast -vvv --legacy --slow

forge script script/gravita/AddColl.s.sol:AddColl --rpc-url https://rpc.ankr.com/botanix_testnet --broadcast -vvv --legacy --slow --with-gas-price 100 --evm-version shanghai
*/