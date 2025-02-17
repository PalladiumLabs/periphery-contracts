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

contract OpenVessel is Script {
    uint256 userPrivateKey;
    address user;

    address collToken=0xFE38CACa0D06EA8D42A88E3AE1535Aa34F592bC2;

    /*BOTANIX*/
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
    

  

    // uint256 debtTokenAmount = 1000e18 ;// borrower wants to withdraw 2500 debtToken
    uint256 debtTokenAmount = 100e18 ;// borrower wants to withdraw 2500 debtToken
    // uint256 collAmount = 2000e18; // borrower wants to lock 5 ETH collateral 0.06
    uint256 collAmount = 2000000000000000; // borrower wants to lock 5 ETH collateral 0.06
    uint256 _1e20 = 100e18;
    uint256 liquidationReserve ;
    uint256 totalDebt;
    uint256 NICR ;
    uint256 numTroves;
    uint256 numTrials;


    function setUp() public {
        string memory seedPhrase = vm.readFile(".secret");
        uint256 _userPrivateKey = vm.deriveKey(seedPhrase, 4);
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

        vm.startBroadcast(userPrivateKey);
        // user=0x0f2a16D4290AC0d91eDFBD533a192E1D0f86b257;
        // vm.startPrank(user);
        liquidationReserve =AdminContract.getDebtTokenGasCompensation(collToken);
        totalDebt=debtTokenAmount;
        NICR =( collAmount*_1e20)/totalDebt;
        numTroves = SortedVessels.getSize(collToken);
        numTrials = numTroves*15;
        // (address hintAddress,, )=VesselManagerOperations.getApproxHint(collToken,NICR, numTrials, 42);
        // (address upperHint,address lowerHint ) = SortedVessels.findInsertPosition(collToken,NICR, hintAddress, hintAddress);
        // console.log("collToken balance before ",IERC20(collToken).balanceOf(user));
        uint price =PriceFeed.fetchPrice(collToken);
        console.log("price",price);
        // console.log("colllateral ratio",_calculateCollateralRatio(price,collAmount,debtTokenAmount));
        IERC20(collToken).approve(address(BorrowerOperations), collAmount);
        console.log("collToken balance before ",IERC20(collToken).balanceOf(user));
        console.log("debtToken balance before ",IERC20(debtToken).balanceOf(user));
        // console.log("decimals balance before ",IERC20(collToken).totalSupply());
        // console.log("collToken balance before ",IERC20(collToken).balanceOf(user));
        // BorrowerOperations.openVessel(collToken, collAmount, debtTokenAmount, upperHint, lowerHint);
        address upperHint = 0x0000000000000000000000000000000000000000;
        address lowerHint = 0x0000000000000000000000000000000000000000;
        BorrowerOperations.openVessel(collToken, collAmount, debtTokenAmount, upperHint, lowerHint);
        console.log("collToken balance after ",IERC20(collToken).balanceOf(user));
        console.log("debtToken balance after ",IERC20(debtToken).balanceOf(user));
        // console.log("debtToken balance after ",5);
       
    }


    function _calculateCollateralRatio (uint price,uint coll,uint debt) internal returns(uint ratio) {
        ratio=coll*price/debt;
    }

}
    
/*
forge script script/gravita/OpenVessel.s.sol:OpenVessel --rpc-url http://127.0.0.1:8545/ --broadcast -vvv --legacy --slow --with-gas-price 100 --evm-version shanghai

forge script script/gravita/OpenVessel.s.sol:OpenVessel --rpc-url https://rpc.test.btcs.network --broadcast -vvv --legacy --slow

forge script script/gravita/OpenVessel.s.sol:OpenVessel --rpc-url https://testnet.bitfinity.network --broadcast -vvv --legacy --slow
forge script script/gravita/OpenVessel.s.sol:OpenVessel --rpc-url https://rpc.ankr.com/botanix_testnet --broadcast -vvv --legacy --slow --with-gas-price 10
forge script script/gravita/OpenVessel.s.sol:OpenVessel --rpc-url https://node.botanixlabs.dev --broadcast -vvv --legacy --slow --with-gas-price 100 --evm-version shanghai


*/
