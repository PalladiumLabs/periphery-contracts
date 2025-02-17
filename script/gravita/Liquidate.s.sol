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


interface token{
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

contract Liquidate is Script {
    uint256 userPrivateKey;
    address user;


    address borrowerOperations =0x6f7b404474D551D70d0D30b3ed113a671eF44970;
    address vesselManager = 0x2Fef509fA966B614483B411f8cA3208C26da3c4b;
    address vesselManagerOperations = 0xd4B76b6e5E56F1DAD86c96D275831dEfdB9473c1;
    address adminContract=0x36F40faDe724ECd183b6E93F2448de65207b08A2;
    address sortedVessels=0x494A934864c4c040B5Fa1b7f6e7Ff6a7A6900BfB;
    address priceFeed=0x800755300090fFE065437fe12751910c96452aA4;
    address collSurplusPool=0x14466C44e49AcEd47c5FDdB0cA28b8aac66cd63D;
    address stabilityPool=0x56984Cc217B0a72DE3f641AF387EdD21164BbE78;
    address debtToken= 0xe19cE0aCF70DBD7ff9Cb80715f84aB0Fd72B57AC;
    address TimelockTester=0xF9ca0da3FA8376449c6f189F5c5d929BDFAa20F8;
    

    // //fork

    // address borrowerOperations =0x793771C01509fa19aBA55a2bd4D18a167E4D96F9;
    // address troveManager = 0x4A313d60Ed48E792c6DD1cef1d5Db1C258562C48;
    // address hintHelpers=0x6C7ca3D5d0CE8C7ecc3a6d52e9d266e25Fa6f424;
    // address sortedTroves=0x26bE66407AD51a5220a91FB7bEc6bE70E75b8a19;
    // address priceFeed=0xF3A418bc8882aC406c9032D949D29a4e5a18fbBf;
    // address collSurplusPool=0x1F140eE1f078a982c1f0e9c22C65365cd9452A62;
    // address stabilityPool=0x3519030725d177362f4aC3066274E6bc73B3788A;
    // address pusd= 0xA505CFC9480b82320D57c863B69418D66D297803;

    uint debt;
    uint coll;
    uint256 liquidationReserve;


    function setUp() public {
        string memory seedPhrase = vm.readFile(".secret");
        uint256 _userPrivateKey = vm.deriveKey(seedPhrase, 0);
        userPrivateKey=_userPrivateKey;
        user = vm.addr(userPrivateKey);
        console.log("user",user);
    }
    function run() public {
        IBorrowerOperations BorrowerOperations = IBorrowerOperations(borrowerOperations);
        IVesselManager VesselManager = IVesselManager(vesselManager);
        IVesselManagerOperations VesselManagerOperations = IVesselManagerOperations(vesselManagerOperations);
        ISortedVessels SortedVessels = ISortedVessels(sortedVessels);
        IAdminContract AdminContract=IAdminContract(adminContract);
        IPriceFeed PriceFeed=IPriceFeed(priceFeed);
        vm.startBroadcast(userPrivateKey);
        VesselManagerOperations.liquidate(0x5FB4E66C918f155a42d4551e871AD3b70c52275d, 0x6C47DCbE1985B717488a2aA6Aeed209618d93c5E);
    }
}

/*
forge script script/gravita/Liquidate.s.sol:Liquidate --rpc-url http://127.0.0.1:8545/ --broadcast -vvv --legacy --slow

forge script script/gravita/Liquidate.s.sol:Liquidate --rpc-url https://rpc.test.btcs.network --broadcast -vvv --legacy --slow


forge script script/gravita/Liquidate.s.sol:Liquidate --rpc-url https://node.botanixlabs.dev --broadcast -vvv --legacy --slow --with-gas-price 10


*/