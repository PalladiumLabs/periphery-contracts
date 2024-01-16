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

    // address borrowerOperations =0x46ECf770a99d5d81056243deA22ecaB7271a43C7;
    // address troveManager = 0x84400014b6bFA5b76d2feb4F460AEac8dd84B656;
    // address hintHelpers=0xA7B88e482d3C9d17A1b83bc3FbeB4DF72cB20478;
    // address sortedTroves=0x6AB8c9590bD89cBF9DCC90d5efEC4F45D5d219be;
    // address priceFeed=0xDC63FB38FDB04B7e2A9A01f1792a4e021538fc57;
    // address collSurplusPool=0xAbaf80156857E05b1EB162552Bea517b25F29aD9;
    // address stabilityPool=0x25ADF247aC836D35be924f4b701A0787A30d46a9;
    // address pusd= 0x55FD5B67B115767036f9e8af569B281A8A544a12;

    // //fork

    address borrowerOperations =0x3C3292B2370fD06eD99b28ABdA1FB4fFBB985a2b;
    address troveManager = 0x01E2460982658069A2Ce288d65d981432762B216;
    address hintHelpers=0x793771C01509fa19aBA55a2bd4D18a167E4D96F9;
    address sortedTroves=0x7348CE8dd1510E7D96A2D044Dc47d86385A6f1d6;
    address priceFeed=0x9DC46D3bb1f305A2326F390756D3fbE37fBc6421;
    address collSurplusPool=0x28422bDab84A2623e2b4B8C74C0064540D45a6B7;
    address stabilityPool=0x6C7ca3D5d0CE8C7ecc3a6d52e9d266e25Fa6f424;
    address pusd= 0xF3A418bc8882aC406c9032D949D29a4e5a18fbBf;



    uint256 pusdAmount = 2500e18 ;// borrower wants to withdraw 2500 pusd
    uint256 btcColl = 5e18; // borrower wants to lock 5 ETH collateral 0.06
    uint256 _1e20 = 100e18;
    function setUp() public {
        string memory seedPhrase = vm.readFile(".secret");
        uint256 _userPrivateKey = vm.deriveKey(seedPhrase, 0);
        userPrivateKey=_userPrivateKey;
        user = vm.addr(userPrivateKey);
        console.log("user",user);
    }
    function run() public {
        IBorrowerOperations BorrowerOperations = IBorrowerOperations(borrowerOperations);
        IHintHelpers HintHelpers = IHintHelpers(hintHelpers);
        ITroveManager TroveManager = ITroveManager(troveManager);
        ISortedTroves SortedTroves = ISortedTroves(sortedTroves);
        vm.startBroadcast(userPrivateKey);
        // Call deployed TroveManager contract to read the liquidation reserve and latest borrowing fee
        uint256 liquidationReserve = TroveManager.LUSD_GAS_COMPENSATION();
        uint256 expectedFee =  TroveManager.getBorrowingFeeWithDecay(pusdAmount);
        // Total debt of the new trove = pusd amount drawn, plus fee, plus the liquidation reserve
        uint256 totalDebt=pusdAmount+liquidationReserve+expectedFee;
        uint256 NICR =( btcColl*_1e20)/totalDebt;
        uint256 numTroves = SortedTroves.getSize();
        uint256 numTrials = numTroves*15;
        (address hintAddress,, )=HintHelpers.getApproxHint(NICR, numTrials, 42);
        (address upperHint,address lowerHint ) = SortedTroves.findInsertPosition(NICR, hintAddress, hintAddress);
        uint256 maxFee = 1e16; // Slippage protection: 5%
        BorrowerOperations.openTrove{ value: btcColl }(maxFee, pusdAmount, upperHint, lowerHint);
        console.log("pusd balance after ",IERC20(pusd).balanceOf(user));
    }
    
}