pragma solidity ^0.8.4;
import "forge-std/Test.sol";
import "@openzeppelin/token/ERC20/IERC20.sol";

import "forge-std/Script.sol";
import "forge-std/console2.sol";

import "./interfaces/IBorrowerOperations.sol";
import "./interfaces/IAdminContract.sol";
// import "./interfaces/IHintHelpers.sol";
import "./interfaces/ISortedVessels.sol";
import "./interfaces/IPriceFeed.sol";
import "./interfaces/IVesselManagerOperations.sol";
import "./interfaces/IVesselManager.sol";
import "./interfaces/ICollSurplusPool.sol";
import "./interfaces/IStabilityPool.sol";
import "./interfaces/IPriceFeed.sol";
import "./interfaces/ITimelockTester.sol";


interface token{
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}


contract UpdateOracle is Script {
    uint256 userPrivateKey;
    address user;

    // address collToken=0x5FB4E66C918f155a42d4551e871AD3b70c52275d;//wcore
    // address oracleAddress=0xedcC1A9d285d6aB43f409c3265F4d67056B3f966;//wcore

    address collToken=0xFE38CACa0D06EA8D42A88E3AE1535Aa34F592bC2;//wbtc
    address oracleAddress=0xc014933c805825D335e23Ef12eB92d2471D41DA7;//wbtc




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


    /*BITFINITY*/
    // address borrowerOperations =0x9d4ecfC15D9FcfC804a838F495DEA21aAEaC5628;
    // address vesselManager = 0xE86ab03Faa7f0adf306163dA5c169b0EeeC427Cb;
    // address vesselManagerOperations = 0x10cECa9f1af2A4b907EF448c0Ce409c94BDE032C;
    // address adminContract=0x4223Dd9Dadc424b33b48cC0317FC39bc3C320D29;
    // address sortedVessels=0x4b4515E7400695Bfc2B84fF524921908837179D8;
    // address priceFeed=0x44311c7443E9C347E379100AEb29E3F0Cf1B4d4d;
    // address collSurplusPool=0xac7C181f566Ce91EEB17975702ed4405Abc715e9;
    // address stabilityPool=0x955494Ae78369d0A224D05d7DD5Bc8d9804bF082;
    // address debtToken= 0x67ce5fa8bef187fb54374f2dBF588dE013C96dc6;
    // address timelockTester=0x5b1d76a6F9859b9d25FA996a69592454fF9F5121;
    // address feeCollector=0x59A80F2c8d1000cC4B2580e64e8E1c4B71d6A750;
    

  


    function setUp() public {
        string memory seedPhrase = vm.readFile(".secret");
        uint256 _userPrivateKey = vm.deriveKey(seedPhrase, 0);
        userPrivateKey=_userPrivateKey;
        user = vm.addr(userPrivateKey);
        // console.log("user",user);
        // console.log("collToken balance before ",IERC20(collToken).balanceOf(user));
    }
    function run() public {
        IBorrowerOperations BorrowerOperations = IBorrowerOperations(borrowerOperations);
        IVesselManager VesselManager = IVesselManager(vesselManager);
        IVesselManagerOperations VesselManagerOperations = IVesselManagerOperations(vesselManagerOperations);
        ISortedVessels SortedVessels = ISortedVessels(sortedVessels);
        IAdminContract AdminContract=IAdminContract(adminContract);
        IPriceFeed PriceFeed=IPriceFeed(priceFeed);
        ITimelockTester TimelockTester=ITimelockTester(timelockTester);

        vm.startBroadcast(userPrivateKey);
        // Encode the setOracle function call
        IPriceFeed.OracleRecordV2 memory OR=PriceFeed.oracles(collToken);
        console.log("oracle before",OR.oracleAddress);
        bytes memory data = abi.encode(
            collToken,
            oracleAddress,
            IPriceFeed.ProviderType.API3,
            90000,
            false,
            false
        );

        // Call setSoftening with the encoded setOracle parameters
        TimelockTester.setSoftening(
            address(PriceFeed),
            "setOracle(address,address,uint8,uint256,bool,bool)",
            data
        );
        OR=PriceFeed.oracles(collToken);

        console.log("oracle after",OR.oracleAddress);
       
    }

}
    
/*
forge script script/gravita/UpdateOracle.s.sol:UpdateOracle --rpc-url http://127.0.0.1:8545/ --broadcast -vvv --legacy --slow

forge script script/gravita/UpdateOracle.s.sol:UpdateOracle --rpc-url https://rpc.test.btcs.network --broadcast -vvv --legacy --slow

forge script script/gravita/UpdateOracle.s.sol:UpdateOracle --rpc-url https://testnet.bitfinity.network --broadcast -vvv --legacy --slow

*/
