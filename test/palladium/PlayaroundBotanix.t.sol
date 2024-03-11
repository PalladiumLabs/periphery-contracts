/*command Sequence
* anvil -f https://node.botanixlabs.dev --mnemonic ".secret mnemonic"  --port 3000

* yarn deploy --network botonixFork --gas-price 1

* forge test --match-path test/palladium/PlayaroundBotanix.t.sol --fork-url http://127.0.0.1:3000/ -vvv
*/

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

contract PlayaroundBotanix is Test {
    IBorrowerOperations BorrowerOperations;
    IHintHelpers HintHelpers ;
    ITroveManager TroveManager ;
    ISortedTroves SortedTroves;
    IPriceFeed PriceFeed;
    ICollSurplusPool CollSurplusPool;
    IStabilityPool StabilityPool ;
    uint256 user1PrivateKey;
    uint256 user2PrivateKey;
    address user1;
    address user2;
    uint256 user3PrivateKey;
    address user3;
    uint256 user4PrivateKey;
    address user4;
    uint256 user5PrivateKey;
    address user5;
    uint256 user6PrivateKey;
    address user6;
    address owner=0x150CC4F90516C23e64231D2B92d737893DBb2515;

    // address borrowerOperations =0x46ECf770a99d5d81056243deA22ecaB7271a43C7;
    // address troveManager = 0x84400014b6bFA5b76d2feb4F460AEac8dd84B656;
    // address hintHelpers=0xA7B88e482d3C9d17A1b83bc3FbeB4DF72cB20478;
    // address sortedTroves=0x6AB8c9590bD89cBF9DCC90d5efEC4F45D5d219be;
    // address priceFeed=0xDC63FB38FDB04B7e2A9A01f1792a4e021538fc57;
    // address collSurplusPool=0xAbaf80156857E05b1EB162552Bea517b25F29aD9;
    // address stabilityPool=0x25ADF247aC836D35be924f4b701A0787A30d46a9;
    // address pusd= 0x55FD5B67B115767036f9e8af569B281A8A544a12;


    //fork botanix
    address borrowerOperations =0x793771C01509fa19aBA55a2bd4D18a167E4D96F9;
    address troveManager = 0x4A313d60Ed48E792c6DD1cef1d5Db1C258562C48;
    address hintHelpers=0x6C7ca3D5d0CE8C7ecc3a6d52e9d266e25Fa6f424;
    address sortedTroves=0x26bE66407AD51a5220a91FB7bEc6bE70E75b8a19;
    address priceFeed=0xF3A418bc8882aC406c9032D949D29a4e5a18fbBf;
    address collSurplusPool=0x1F140eE1f078a982c1f0e9c22C65365cd9452A62;
    address stabilityPool=0x3519030725d177362f4aC3066274E6bc73B3788A;
    address pusd= 0xA505CFC9480b82320D57c863B69418D66D297803;
    address pdm=0xEbe79B0eF31aFB3c893e94FE8EbF11D5CB2231d5;





    //variables to avoid stackstrace


    uint256 pusdAmount = 2500e18 ;// borrower wants to withdraw 2500 pusd
    // uint256 pusdAmount = 400e18 ;// borrower wants to withdraw 2500 pusd
    uint256 collateralAmount = 5e18; // borrower wants to lock 5 ETH collateral
    uint256 _1e20 = 100e18; //This value of 1e20 is chosen for safety against overflow and underflow
    uint256 collIncrease = 1e18;  // borrower wants to add 1 ETH
    uint256 pusdRepayment = 230e18; // borrower wants to repay 230 pusd
    uint256 pusdMintMore = 100e18; // borrower wants to repay 230 pusd
    uint256 stablePoolDepAmount=100e18;

    address upperHint;
    address lowerHint;

    uint newDebt;
    uint newColl;
    uint ethusdprice;
    uint debt;
    uint coll;

    address firstRedemptionHint;
    uint partialRedemptionNewICR;
    uint truncatedpusdamount;
    bool mode;
    uint troveStake;
    uint totalStakesSnapshot;
    uint totalCollateralSnapshot;
    uint MIN_NET_DEBT;


    uint ratio;


    function setUp() public {
        string memory seedPhrase = vm.readFile(".secret");

        uint256 _user1PrivateKey = vm.deriveKey(seedPhrase, 0);
        user1PrivateKey=_user1PrivateKey;
        user1 = vm.addr(user1PrivateKey);

        uint256 _user2PrivateKey = vm.deriveKey(seedPhrase, 1);
        user2PrivateKey=_user2PrivateKey;
        user2 = vm.addr(user2PrivateKey);

        uint256 _user3PrivateKey = vm.deriveKey(seedPhrase, 2);
        user3PrivateKey=_user3PrivateKey;
        user3 = vm.addr(user3PrivateKey);

        uint256 _user4PrivateKey = vm.deriveKey(seedPhrase, 3);
        user4PrivateKey=_user4PrivateKey;
        user4 = vm.addr(user4PrivateKey);

        uint256 _user5PrivateKey = vm.deriveKey(seedPhrase, 4);
        user5PrivateKey=_user5PrivateKey;
        user5 = vm.addr(user5PrivateKey);

        uint256 _user6PrivateKey = vm.deriveKey(seedPhrase, 5);
        user6PrivateKey=_user6PrivateKey;
        user6 = vm.addr(user6PrivateKey);
        BorrowerOperations = IBorrowerOperations(borrowerOperations);
        HintHelpers = IHintHelpers(hintHelpers);
        TroveManager = ITroveManager(troveManager);
        SortedTroves = ISortedTroves(sortedTroves);
        PriceFeed = IPriceFeed(priceFeed);
        CollSurplusPool = ICollSurplusPool(collSurplusPool);
        StabilityPool = IStabilityPool(stabilityPool);
        MIN_NET_DEBT=BorrowerOperations.MIN_NET_DEBT();

    }

    function test_checkMode() public {
        mode =TroveManager.checkRecoveryMode(ethusdprice);
        console.log("mode",mode);
    }

    function test_OpenTrove(/*uint pusdAmount,*/ uint collAmount  ) public {
        vm.assume(collAmount>1e17 && collAmount<address(user1).balance);
        uint collusdprice=PriceFeed.fetchPrice();

        uint pusdAmount=1800e18;
        // uint pusdAmount=((collAmount*collusdprice*10)/11)-400e18;
        // uint collAmount =1e18;
        // vm.assume(pusdAmount>MIN_NET_DEBT && pusdAmount<50000e18);
        // vm.assume(collAmount>1e18 && collAmount<10e18);
        openTrove(user1, pusdAmount,collAmount);
    }

    function test_IncreaseOnlyCollateral( ) public {
        uint pusdAmount=2500e18;
        uint collAmount =1e18;
        uint collIncrease=2e18;
        openTrove(user1, pusdAmount,collAmount);
        ( debt, coll,,) = TroveManager.getEntireDebtAndColl(user1);
        console.log("debt before",debt);
        console.log("coll before",coll);
        uint newDebt=debt+0;
        uint newColl=coll+collIncrease;
        uint NICR =( newColl*_1e20)/newDebt;
        uint numTroves = SortedTroves.getSize();
        uint numTrials = numTroves*15;
        uint maxFee = 5e16; // Slippage protection: 5%
        //hint helper not working on forked env , so directly assigning hint address in below  findInsertPosition  function .
        (address hintAddress,, )=HintHelpers.getApproxHint(NICR, numTrials, 42);
        (address upperHint,address  lowerHint ) = SortedTroves.findInsertPosition(NICR, hintAddress, hintAddress);
        console.log("pusd balance before adjust ",IERC20(pusd).balanceOf(user1));
        vm.startPrank(user1);
        BorrowerOperations.adjustTrove{ value: collIncrease }(maxFee, 0, 0, false, upperHint, lowerHint);
        ( debt, coll,,) = TroveManager.getEntireDebtAndColl(user1);
        console.log("debt after",debt);
        console.log("coll after",coll);
        console.log("pusd balance after adjust ",IERC20(pusd).balanceOf(user1));
    }

    function test_IncreaseOnlyDebt( ) public {
        uint pusdAmount=2500e18;
        uint debtIncrease=500e18;
        uint collAmount =1e18;
        // uint collIncrease=0;
        openTrove(user1, pusdAmount,collAmount);
        ( debt, coll,,) = TroveManager.getEntireDebtAndColl(user1);
        console.log("debt before",debt);
        console.log("coll before",coll);
        uint newDebt=debt+debtIncrease;
        uint newColl=coll+0;
        uint NICR =( newColl*_1e20)/newDebt;
        uint numTroves = SortedTroves.getSize();
        uint numTrials = numTroves*15;
        uint maxFee = 5e16; // Slippage protection: 5%
        //hint helper not working on forked env , so directly assigning hint address in below  findInsertPosition  function .
        (address hintAddress,, )=HintHelpers.getApproxHint(NICR, numTrials, 42);
        (address upperHint,address  lowerHint ) = SortedTroves.findInsertPosition(NICR, hintAddress, hintAddress);
        console.log("pusd balance before adjust ",IERC20(pusd).balanceOf(user1));
        vm.startPrank(user1);
        BorrowerOperations.adjustTrove{ value: 0 }(maxFee, 0, debtIncrease, true, upperHint, lowerHint);
        ( debt, coll,,) = TroveManager.getEntireDebtAndColl(user1);
        console.log("debt after",debt);
        console.log("coll after",coll);
        console.log("pusd balance after adjust ",IERC20(pusd).balanceOf(user1));
    }

    function test_IncreaseBothDebtAndCollateral( ) public {
        uint pusdAmount=2500e18;
        uint collAmount =1e18;
        uint debtIncrease=500e18;
        uint collIncrease=2e18;
        openTrove(user1, pusdAmount,collAmount);
        ( debt, coll,,) = TroveManager.getEntireDebtAndColl(user1);
        console.log("debt before",debt);
        console.log("coll before",coll);
        uint newDebt=debt+debtIncrease;
        uint newColl=coll+collIncrease;
        uint NICR =( newColl*_1e20)/newDebt;
        uint numTroves = SortedTroves.getSize();
        uint numTrials = numTroves*15;
        uint maxFee = 5e16; // Slippage protection: 5%
        //hint helper not working on forked env , so directly assigning hint address in below  findInsertPosition  function .
        (address hintAddress,, )=HintHelpers.getApproxHint(NICR, numTrials, 42);
        (address upperHint,address  lowerHint ) = SortedTroves.findInsertPosition(NICR, hintAddress, hintAddress);
        console.log("pusd balance before adjust ",IERC20(pusd).balanceOf(user1));
        vm.startPrank(user1);
        BorrowerOperations.adjustTrove{ value: collIncrease }(maxFee, 0, debtIncrease, true, upperHint, lowerHint);
        ( debt, coll,,) = TroveManager.getEntireDebtAndColl(user1);
        console.log("debt after",debt);
        console.log("coll after",coll);
        console.log("pusd balance after adjust ",IERC20(pusd).balanceOf(user1));
    }

    function test_DecreaseOnlyCollateral( ) public {
        uint pusdAmount=2500e18;
        uint collAmount =1e18;
        uint collDecrease=1e17;
        openTrove(user1, pusdAmount,collAmount);
        ( debt, coll,,) = TroveManager.getEntireDebtAndColl(user1);
        console.log("debt before",debt);
        console.log("coll before",coll);
        uint newDebt=debt-0;
        uint newColl=coll-collDecrease;
        uint NICR =( newColl*_1e20)/newDebt;
        uint numTroves = SortedTroves.getSize();
        uint numTrials = numTroves*15;
        uint maxFee = 5e16; // Slippage protection: 5%
        //hint helper not working on forked env , so directly assigning hint address in below  findInsertPosition  function .
        (address hintAddress,, )=HintHelpers.getApproxHint(NICR, numTrials, 42);
        (address upperHint,address  lowerHint ) = SortedTroves.findInsertPosition(NICR, hintAddress, hintAddress);
        console.log("pusd balance before adjust ",IERC20(pusd).balanceOf(user1));
        vm.startPrank(user1);
        BorrowerOperations.adjustTrove{ value: 0 }(maxFee, collDecrease, 0, false, upperHint, lowerHint);
        ( debt, coll,,) = TroveManager.getEntireDebtAndColl(user1);
        console.log("debt after",debt);
        console.log("coll after",coll);
        console.log("pusd balance after adjust ",IERC20(pusd).balanceOf(user1));
    }   

    function test_DecreaseOnlyDebt( ) public {
        uint pusdAmount=2500e18;
        uint collAmount =1e18;
        uint collDecrease=0;
        uint pusdRepayment=500e18;
        openTrove(user1, pusdAmount,collAmount);
        ( debt, coll,,) = TroveManager.getEntireDebtAndColl(user1);
        console.log("debt before",debt);
        console.log("coll before",coll);
        uint newDebt=debt-pusdRepayment;
        uint newColl=coll-0;
        uint NICR =( newColl*_1e20)/newDebt;
        uint numTroves = SortedTroves.getSize();
        uint numTrials = numTroves*15;
        uint maxFee = 5e16; // Slippage protection: 5%
        //hint helper not working on forked env , so directly assigning hint address in below  findInsertPosition  function .
        (address hintAddress,, )=HintHelpers.getApproxHint(NICR, numTrials, 42);
        (address upperHint,address  lowerHint ) = SortedTroves.findInsertPosition(NICR, hintAddress, hintAddress);
        console.log("pusd balance before adjust ",IERC20(pusd).balanceOf(user1));
        vm.startPrank(user1);
        BorrowerOperations.adjustTrove{ value: 0 }(maxFee, 0, pusdRepayment, false, upperHint, lowerHint);
        ( debt, coll,,) = TroveManager.getEntireDebtAndColl(user1);
        console.log("debt after",debt);
        console.log("coll after",coll);
        console.log("pusd balance after adjust ",IERC20(pusd).balanceOf(user1));
    } 

    function test_DecreaseBothDebtAndCollateral( ) public {
        uint pusdAmount=2500e18;
        uint collAmount =1e18;
        uint collDecrease=1e17;
        uint pusdRepayment=500e18;
        openTrove(user1, pusdAmount,collAmount);
        ( debt, coll,,) = TroveManager.getEntireDebtAndColl(user1);
        console.log("debt before",debt);
        console.log("coll before",coll);
        uint newDebt=debt-pusdRepayment;
        uint newColl=coll-collDecrease;
        uint NICR =( newColl*_1e20)/newDebt;
        uint numTroves = SortedTroves.getSize();
        uint numTrials = numTroves*15;
        uint maxFee = 5e16; // Slippage protection: 5%
        //hint helper not working on forked env , so directly assigning hint address in below  findInsertPosition  function .
        (address hintAddress,, )=HintHelpers.getApproxHint(NICR, numTrials, 42);
        (address upperHint,address  lowerHint ) = SortedTroves.findInsertPosition(NICR, hintAddress, hintAddress);
        console.log("pusd balance before adjust ",IERC20(pusd).balanceOf(user1));
        vm.startPrank(user1);
        BorrowerOperations.adjustTrove{ value: 0 }(maxFee, collDecrease, pusdRepayment, false, upperHint, lowerHint);
        ( debt, coll,,) = TroveManager.getEntireDebtAndColl(user1);
        console.log("debt after",debt);
        console.log("coll after",coll);
        console.log("pusd balance after adjust ",IERC20(pusd).balanceOf(user1));
    }   

    function test_Close() public {
        ethusdprice=PriceFeed.fetchPrice();
        vm.prank(owner);
        // PriceFeed.setPrice(45000e18);
        ethusdprice=PriceFeed.fetchPrice();
        /*Opening the Trove*/
        console.log("==================================== ");
        console.log("Opening the Trove user1 ");
        console.log("==================================== ");
        // Call deployed TroveManager contract to read the liquidation reserve and latest borrowing fee
        openTrove(user1, pusdAmount,collateralAmount);
        console.log("bsd balance after ",IERC20(pusd).balanceOf(user1));

        console.log("==================================== ");
        console.log("Opening the Trove user2 ");
        console.log("==================================== ");
        // Call deployed TroveManager contract to read the liquidation reserve and latest borrowing fee
        openTrove(user2, pusdAmount,collateralAmount);
        console.log("bsd balance after ",IERC20(pusd).balanceOf(user2));
        /*Closing the Trove*/
        console.log("==================================== ");
        console.log("Closing the Trove user1 ");
        console.log("==================================== ");
        ( debt, coll,,) = TroveManager.getEntireDebtAndColl(user1);
        // console.log("debt before ",debt);
        // console.log("coll before",coll);
        vm.prank(user2);
        IERC20(pusd).transfer(user1, 12.5e18);
        console.log("coll balance Before ",address(user1).balance);
        vm.startPrank(user1);
        BorrowerOperations.closeTrove(); 
        ( debt, coll,,) = TroveManager.getEntireDebtAndColl(user1);
        console.log("debt after ",debt);
        console.log("coll after",coll);
        console.log("coll balance After ",address(user1).balance);

    }

    function test_RedeemCollateral() public {
        uint redeemAmount=100e18;
        uint collAmount=5e18;
        //open couple of troves
        openTrove(user1, pusdAmount,collAmount);
        openTrove(user2, pusdAmount,collAmount);
        openTrove(user3, pusdAmount,collAmount);
        //transfer some pusd to 4th user 
        vm.startPrank(user3);
        IERC20(pusd).transfer(user4, redeemAmount);
        vm.stopPrank();
        skip(1296000);
        ethusdprice=PriceFeed.fetchPrice();
         (
             firstRedemptionHint,
             partialRedemptionNewICR,
             truncatedpusdamount //Here truncatedpusdamount is max redeemable amount 
        ) = HintHelpers.getRedemptionHints(redeemAmount, ethusdprice, 50);
        uint numTroves = SortedTroves.getSize();
        uint numTrials = numTroves*15;
        (address hintAddress,,)=HintHelpers.getApproxHint(partialRedemptionNewICR, numTrials, 42);
        (address upperHint, address lowerHint ) =  SortedTroves.findInsertPosition(partialRedemptionNewICR,
        hintAddress,
        hintAddress);
        vm.startPrank(user4);
        TroveManager.redeemCollateral(truncatedpusdamount,
        firstRedemptionHint,
        upperHint,
        lowerHint,
        partialRedemptionNewICR,
        0, /*maxFee */2e17);
    }

    function test_ProvideToStabilityPool() public {
        uint collAmount=5e18;
        uint stablePoolDepAmount=1000e18;
        openTrove(user1, pusdAmount, collAmount);
        console.log("pusd balance before Provide To Stability Pool ",IERC20(pusd).balanceOf(user1));
        vm.startPrank(user1);
        StabilityPool.provideToSP(stablePoolDepAmount, address(0));
        console.log("pusd balance after Provide To Stability Pool ",IERC20(pusd).balanceOf(user1));
        uint256 getCompoundedLUSDDeposit=StabilityPool.getCompoundedLUSDDeposit(user1);
        console.log("getCompoundedLUSDDeposit ",getCompoundedLUSDDeposit);
        vm.stopPrank();
    }

    function test_LiquidateTrove() public {
        openTrove(user1, pusdAmount, collateralAmount);
        openTrove(user2, pusdAmount, collateralAmount);
        openTrove(user3, pusdAmount, collateralAmount);
        vm.prank(owner);
        PriceFeed.setPrice(200000000000000000000);
        vm.startPrank(user4);
        TroveManager.liquidate(user1);
        ( debt, coll,,) = TroveManager.getEntireDebtAndColl(user1);
        console.log("debt after user1 liquidate of user1  ",debt);
        console.log("coll after user1 liquidate of user1 ",coll);
    }


    function test_BountyAddressLock() public {
        vm.prank(owner);
        PriceFeed.setPrice(60000e18);
        ethusdprice=PriceFeed.fetchPrice();
        console.log("ethusdprice",ethusdprice);
        console.log("pdm balanceof bounty user",IERC20(pdm).balanceOf(user4));
        vm.startPrank(user4);
        IERC20(pdm).transfer(user5, IERC20(pdm).balanceOf(user4)/2);
        console.log("pdm balanceof  user 5",IERC20(pdm).balanceOf(user5));
        console.log("pdm balanceof bounty user",IERC20(pdm).balanceOf(user4));

    }

    function test_CalculateRatio( ) public {
        ethusdprice=PriceFeed.fetchPrice();
        console.log("ethusdprice",ethusdprice);
        uint collAmount=1e18;
        uint borrowAmount=30000e18;
        uint ratio=(collAmount*ethusdprice*100)/borrowAmount;
        console.log("ratio",ratio/1e18);
        uint256 liquidationReserve = TroveManager.LUSD_GAS_COMPENSATION();
        uint256 expectedFee =  TroveManager.getBorrowingFeeWithDecay(borrowAmount);
        uint256 totalDebt=borrowAmount+liquidationReserve+expectedFee;
        uint256 NICR =( collAmount*_1e20)/totalDebt;
        uint lastRatio=(collAmount*ethusdprice*100)/(totalDebt);
        console.log("lastRatio",lastRatio/1e18);
        uint256 numTroves = SortedTroves.getSize();
        uint256 numTrials = numTroves*15;
        (address hintAddress,, )=HintHelpers.getApproxHint(NICR, numTrials, 42);
        ( upperHint,  lowerHint ) = SortedTroves.findInsertPosition(NICR, hintAddress, hintAddress);
        uint256 maxFee = 5e16; // Slippage protection: 5%
        vm.startPrank(user1);
        BorrowerOperations.openTrove{ value: collAmount }(maxFee, borrowAmount, upperHint, lowerHint);
        vm.stopPrank();
    }


    function openTrove(address user,uint amount,uint collAmount) public {
        // Call deployed TroveManager contract to read the liquidation reserve and latest borrowing fee
        uint256 liquidationReserve = TroveManager.LUSD_GAS_COMPENSATION();
        uint256 expectedFee =  TroveManager.getBorrowingFeeWithDecay(amount);
        // Total debt of the new trove = pusd amount drawn, plus fee, plus the liquidation reserve
        uint256 totalDebt=amount+liquidationReserve+expectedFee;
        uint256 NICR =( collAmount*_1e20)/totalDebt;
        uint256 numTroves = SortedTroves.getSize();
        uint256 numTrials = numTroves*15;
        (address hintAddress,, )=HintHelpers.getApproxHint(NICR, numTrials, 42);
        //hint helper not working on forked env , so directly assigning hint address in below  findInsertPosition  function .
        ( upperHint,  lowerHint ) = SortedTroves.findInsertPosition(NICR, hintAddress, hintAddress);
        uint256 maxFee = 5e16; // Slippage protection: 5%
        // vm.startBroadcast(user1PrivateKey);
        // console.log("bsd balance before ",IERC20(pusd).balanceOf(user));
        // console.log("btc balance ",user.balance);
        vm.startPrank(user);
        BorrowerOperations.openTrove{ value: collAmount }(maxFee, amount, upperHint, lowerHint);
        // console.log("bsd balance after ",IERC20(pusd).balanceOf(user));
        vm.stopPrank();
    }

    

}