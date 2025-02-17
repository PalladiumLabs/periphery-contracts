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

contract OpenTrove is Script {
    uint256 userPrivateKey;
    address user;


    address borrowerOperations =0xE0774dA339FA29bAf646B57B00644deA48fCaE23;
    address troveManager = 0xc014933c805825D335e23Ef12eB92d2471D41DA7;
    address hintHelpers=0x59356e69d4447D1225482f966C984Bcc62C3Ef1b;
    address sortedTroves=0x34C3C2DBe369c23d07fCB7dBf1c6472faf2232Bd;
    address priceFeed=0x104cA4C9415fbcCE53b5f522a1aBC96b3731aEB6;
    address collSurplusPool=0xFaf22DfDD47C6fe48d8dCD53A029C296023C69A3;
    address stabilityPool=0x8FBa9ab010923d3E1c60eD34DAE255A2E7b98Edc;
    address pusd= 0xEaB76Bb6f8E5f6f880Ea36e51b5D7520a60AfFCF;

    // // //fork
    // address borrowerOperations =0xE4040b417c7B555Fc9C16A91e9400fA0E8A657Dd;
    // address troveManager = 0x2f8825523A0F2A4275582ed334438FF66E7edF3c;
    // address hintHelpers=0xCB6a0936237e11d629216FF2215d98bbC5a51F28;
    // address sortedTroves=0xe6B2751575B6FE9eF77e7bEa2B32EEAE1e83Eba7;
    // address priceFeed=0x061EeDE6fa01306c75a0A549E0C2D334fC7d2090;
    // address collSurplusPool=0x8D24BC92b7E77880b8e0071E10D6e3ffb15B51bD;
    // address stabilityPool=0x9f49351F5803507b5fB515015236AE6b3C28a6E3;
    // address pusd= 0xcC8886b82190F00c84d113078ab5Ef6223E6cFC4;
    // address pdm=0xe7B02Dd4592627b867eC994bA721d582Aa29714d;
    // address communityIssuance=0xB7ab7086C34033723E0D756FB6736f677Bc28617;
    // address unipool=0x38cd889db746A67D77e531E80CA552853dCfDDF9;
    // address uniToken=0x43c71f0D0b1Ad3B116D09A5B3eC4a89B81AB69d1;


    //temp
    // uint256 pusdAmount = 510e18 ;// borrower wants to withdraw 2500 pusd
    // uint256 btcColl = 15000000000000000; // borrower wants to lock 5 ETH collateral 0.06

    uint256 pusdAmount = 16e18 ;// borrower wants to withdraw 2500 pusd
    // uint256 btcColl = 5e15; // borrower wants to lock 5 ETH collateral 0.06
    uint256 btcColl = 1e16; // borrower wants to lock 5 ETH collateral 0.06
    uint256 _1e20 = 100e18;
    function setUp() public {
        string memory seedPhrase = vm.readFile(".secret");
        uint256 _userPrivateKey = vm.deriveKey(seedPhrase, 2);
        userPrivateKey=_userPrivateKey;
        user = vm.addr(userPrivateKey);
        console.log("user",user);
    }
    function run() public {
        IBorrowerOperations BorrowerOperations = IBorrowerOperations(borrowerOperations);
        IHintHelpers HintHelpers = IHintHelpers(hintHelpers);
        ITroveManager TroveManager = ITroveManager(troveManager);
        ISortedTroves SortedTroves = ISortedTroves(sortedTroves);
        // uint CCR=TroveManager.CCR();
        // uint MCR=TroveManager.MCR();
        // console.log("MCR",MCR);
        // console.log("balance user",user.balance);

        vm.startBroadcast(userPrivateKey);
        // Call deployed TroveManager contract to read the liquidation reserve and latest borrowing fee
        uint256 liquidationReserve = TroveManager.LUSD_GAS_COMPENSATION();
        console.log("liquidationReserve",liquidationReserve);
        uint256 expectedFee =  TroveManager.getBorrowingFeeWithDecay(pusdAmount);
        // Total debt of the new trove = pusd amount drawn, plus fee, plus the liquidation reserve
        uint256 totalDebt=pusdAmount+liquidationReserve+expectedFee;
        console.log("total DEbt",totalDebt);
        uint256 NICR =( btcColl*_1e20)/totalDebt;
        console.log("NICR",NICR);
        uint256 numTroves = SortedTroves.getSize();
        uint256 numTrials = numTroves*15;
        (address hintAddress,, )=HintHelpers.getApproxHint(NICR, numTrials, 42);
        (address upperHint,address lowerHint ) = SortedTroves.findInsertPosition(NICR, hintAddress, hintAddress);
        uint256 maxFee = 1e16; // Slippage protection: 5%
        console.log("pusd balance before ",IERC20(pusd).balanceOf(user));
        BorrowerOperations.openTrove{ value: btcColl }(maxFee, pusdAmount, upperHint, lowerHint);
        // BorrowerOperations.openTrove{ value: btcColl }(maxFee, pusdAmount, 0x150CC4F90516C23e64231D2B92d737893DBb2515, 0x150CC4F90516C23e64231D2B92d737893DBb2515);
        console.log("pusd balance after ",IERC20(pusd).balanceOf(user));
       
    }

}
    
/*
forge script script/palladium/OpenTrove.s.sol:OpenTrove --rpc-url http://127.0.0.1:3000/ --broadcast -vvv --legacy --slow

forge script script/palladium/OpenTrove.s.sol:OpenTrove --rpc-url https://sepolia.infura.io/v3/ad9cef41c9c844a7b54d10be24d416e5 --broadcast -vvv --legacy --slow

forge script script/palladium/OpenTrove.s.sol:OpenTrove --rpc-url https://node.botanixlabs.dev --broadcast -vvv --legacy --slow --with-gas-price 15
*/
