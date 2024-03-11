pragma solidity ^0.8.4;
import "forge-std/Test.sol";
import "@openzeppelin/token/ERC20/IERC20.sol";

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "./interfaces/IBorrowerOperations.sol";
import "./interfaces/IHintHelpers.sol";
import "./interfaces/ISortedTroves.sol";
import "./interfaces/IPriceFeed.sol";
import "./interfaces/ITroveManager.sol";
import "./interfaces/ICollSurplusPool.sol";
import "./interfaces/IStabilityPool.sol";

interface token{
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

contract TroveDetails is Script {
    uint256 user1PrivateKey;
    address user1;
    uint256 user2PrivateKey;
    address user2;
    uint256 user3PrivateKey;
    address user3;

    // address borrowerOperations =0x46ECf770a99d5d81056243deA22ecaB7271a43C7;
    // address troveManager = 0x84400014b6bFA5b76d2feb4F460AEac8dd84B656;
    // address hintHelpers=0xA7B88e482d3C9d17A1b83bc3FbeB4DF72cB20478;
    // address sortedTroves=0x6AB8c9590bD89cBF9DCC90d5efEC4F45D5d219be;
    // address priceFeed=0xDC63FB38FDB04B7e2A9A01f1792a4e021538fc57;
    // address collSurplusPool=0xAbaf80156857E05b1EB162552Bea517b25F29aD9;
    // address stabilityPool=0x25ADF247aC836D35be924f4b701A0787A30d46a9;
    // address pusd= 0x55FD5B67B115767036f9e8af569B281A8A544a12;

    // //fork

    address borrowerOperations =0x793771C01509fa19aBA55a2bd4D18a167E4D96F9;
    address troveManager = 0x4A313d60Ed48E792c6DD1cef1d5Db1C258562C48;
    address hintHelpers=0x6C7ca3D5d0CE8C7ecc3a6d52e9d266e25Fa6f424;
    address sortedTroves=0x26bE66407AD51a5220a91FB7bEc6bE70E75b8a19;
    address priceFeed=0xF3A418bc8882aC406c9032D949D29a4e5a18fbBf;
    address collSurplusPool=0x1F140eE1f078a982c1f0e9c22C65365cd9452A62;
    address stabilityPool=0x3519030725d177362f4aC3066274E6bc73B3788A;
    address pusd= 0xA505CFC9480b82320D57c863B69418D66D297803;


    function setUp() public {
        string memory seedPhrase = vm.readFile(".secret");
        uint256 _user1PrivateKey = vm.deriveKey(seedPhrase, 0);
        user1PrivateKey=_user1PrivateKey;
        user1 = vm.addr(user1PrivateKey);
        // user1 = 0x9FDA00A2AEFbE11af8e767FF7f90a56DB502D12b;

        uint256 _user2PrivateKey = vm.deriveKey(seedPhrase, 1);
        user2PrivateKey=_user2PrivateKey;
        user2 = vm.addr(user2PrivateKey);

        uint256 _user3PrivateKey = vm.deriveKey(seedPhrase, 2);
        user3PrivateKey=_user3PrivateKey;
        user3 = vm.addr(user3PrivateKey);
    }
    function run() public {
        address user=user1;
        IBorrowerOperations BorrowerOperations = IBorrowerOperations(borrowerOperations);
        IHintHelpers HintHelpers = IHintHelpers(hintHelpers);
        ITroveManager TroveManager = ITroveManager(troveManager);
        IPriceFeed PriceFeed = IPriceFeed(priceFeed);
        ISortedTroves SortedTroves = ISortedTroves(sortedTroves);
        uint btcusdPrice=PriceFeed.fetchPrice();
        console.log("btcusdPrice",btcusdPrice);
        uint status=TroveManager.getTroveStatus(user);
        console.log("status",status);
        uint currentICR=TroveManager.getCurrentICR(user, btcusdPrice);
        console.log("currentICR",currentICR/1e16);
        uint protocolTCR=TroveManager.getTCR(btcusdPrice);
        console.log("protocolTCR",protocolTCR/1e16);
        ( uint256 debt,uint256 coll,,) = TroveManager.getEntireDebtAndColl(user);
        console.log("debt",debt);
        console.log("coll",coll);
        uint MIN_NET_DEBT=BorrowerOperations.MIN_NET_DEBT();
        console.log("MIN_NET_DEBT",MIN_NET_DEBT);
    }
    
}