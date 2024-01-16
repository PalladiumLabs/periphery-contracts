/*command Sequence
* anvil -f https://node.botanixlabs.dev --mnemonic ".secret mnemonic"  --port 3000

* yarn deploy --network botonixFork --gas-price 1

* forge test --match-path test/liquity/PlayaroundBotanix.t.sol --fork-url http://127.0.0.1:3000/ -vvv
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


    // //fork

    address borrowerOperations =0x3C3292B2370fD06eD99b28ABdA1FB4fFBB985a2b;
    address troveManager = 0x01E2460982658069A2Ce288d65d981432762B216;
    address hintHelpers=0x793771C01509fa19aBA55a2bd4D18a167E4D96F9;
    address sortedTroves=0x7348CE8dd1510E7D96A2D044Dc47d86385A6f1d6;
    address priceFeed=0x9DC46D3bb1f305A2326F390756D3fbE37fBc6421;
    address collSurplusPool=0x28422bDab84A2623e2b4B8C74C0064540D45a6B7;
    address stabilityPool=0x6C7ca3D5d0CE8C7ecc3a6d52e9d266e25Fa6f424;
    address pusd= 0xF3A418bc8882aC406c9032D949D29a4e5a18fbBf;



    //variables to avoid stackstrace


    uint256 pusdAmount = 2500e18 ;// borrower wants to withdraw 2500 pusd
    // uint256 pusdAmount = 400e18 ;// borrower wants to withdraw 2500 pusd
    uint256 ETHColl = 5e18; // borrower wants to lock 5 ETH collateral
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


    uint ratio;





    function setUp() public {
        string memory seedPhrase = vm.readFile(".secret");

        uint256 _user1PrivateKey = vm.deriveKey(seedPhrase, 2);
        user1PrivateKey=_user1PrivateKey;
        user1 = vm.addr(user1PrivateKey);

        uint256 _user2PrivateKey = vm.deriveKey(seedPhrase, 3);
        user2PrivateKey=_user2PrivateKey;
        user2 = vm.addr(user2PrivateKey);

        uint256 _user3PrivateKey = vm.deriveKey(seedPhrase, 4);
        user3PrivateKey=_user3PrivateKey;
        user3 = vm.addr(user3PrivateKey);

        uint256 _user4PrivateKey = vm.deriveKey(seedPhrase, 5);
        user4PrivateKey=_user4PrivateKey;
        user4 = vm.addr(user4PrivateKey);

        uint256 _user5PrivateKey = vm.deriveKey(seedPhrase, 6);
        user5PrivateKey=_user5PrivateKey;
        user5 = vm.addr(user5PrivateKey);

        uint256 _user6PrivateKey = vm.deriveKey(seedPhrase, 7);
        user6PrivateKey=_user6PrivateKey;
        user6 = vm.addr(user6PrivateKey);

        
    }

    function test_Playground() public {
        IBorrowerOperations BorrowerOperations = IBorrowerOperations(borrowerOperations);
        IHintHelpers HintHelpers = IHintHelpers(hintHelpers);
        ITroveManager TroveManager = ITroveManager(troveManager);
        ISortedTroves SortedTroves = ISortedTroves(sortedTroves);
        IPriceFeed PriceFeed = IPriceFeed(priceFeed);
        ICollSurplusPool CollSurplusPool = ICollSurplusPool(collSurplusPool);
        IStabilityPool StabilityPool = IStabilityPool(stabilityPool);
        ethusdprice=PriceFeed.fetchPrice();
        console.log("ethusdprice",ethusdprice);
        vm.prank(owner);
        PriceFeed.setPrice(45000e18);
        ethusdprice=PriceFeed.fetchPrice();
        console.log("ethusdprice",ethusdprice);


        ratio=(ETHColl*ethusdprice)/pusdAmount;
        console.log("ratio",ratio/1e16);

        console.log("token name",token(pusd).symbol());

        




        console.log("==================================== ");
        console.log("TroveManager::Check Mode");
        console.log("==================================== ");
        mode =TroveManager.checkRecoveryMode(ethusdprice);
        console.log("mode",mode);


        



        /*Opening the Trove*/
        console.log("==================================== ");
        console.log("Opening the Trove user1 ");
        console.log("==================================== ");

        // Call deployed TroveManager contract to read the liquidation reserve and latest borrowing fee
        uint256 liquidationReserve = TroveManager.LUSD_GAS_COMPENSATION();
        uint256 expectedFee =  TroveManager.getBorrowingFeeWithDecay(pusdAmount);
        console.log("liquidationReserve",liquidationReserve);
        console.log("expectedFee",expectedFee);
        // Total debt of the new trove = pusd amount drawn, plus fee, plus the liquidation reserve
        uint256 totalDebt=pusdAmount+liquidationReserve+expectedFee;
        uint256 NICR =( ETHColl*_1e20)/totalDebt;
        uint256 numTroves = SortedTroves.getSize();
        uint256 numTrials = numTroves*15;
        console.log("NICR",NICR);
        console.log("numTrials",numTrials);
        (address hintAddress,, )=HintHelpers.getApproxHint(NICR, numTrials, 42);
        //hint helper not working on forked env , so directly assigning hint address in below  findInsertPosition  function .
        ( upperHint,  lowerHint ) = SortedTroves.findInsertPosition(NICR, hintAddress, hintAddress);
        console.log("upperHint",upperHint);
        console.log("lowerHint",lowerHint);
        uint256 maxFee = 5e16; // Slippage protection: 5%
        // vm.startBroadcast(user1PrivateKey);
        console.log("bsd balance before ",IERC20(pusd).balanceOf(user1));
        console.log("btc balance ",user1.balance);
        vm.startPrank(user1);
        BorrowerOperations.openTrove{ value: ETHColl }(maxFee, pusdAmount, upperHint, lowerHint);
        console.log("bsd balance after ",IERC20(pusd).balanceOf(user1));
        troveStake=TroveManager.getTroveStake(user1);
        console.log("troveStake",troveStake);
        totalCollateralSnapshot=TroveManager.totalCollateralSnapshot();
        console.log("totalCollateralSnapshot",totalCollateralSnapshot);

        totalStakesSnapshot=TroveManager.totalStakesSnapshot();
        console.log("totalStakesSnapshot",totalStakesSnapshot);
        vm.stopPrank();



         /*Opening the Trove*/
        console.log("==================================== ");
        console.log("Opening the Trove user2 ");
        console.log("==================================== ");

        // Call deployed TroveManager contract to read the liquidation reserve and latest borrowing fee
         liquidationReserve = TroveManager.LUSD_GAS_COMPENSATION();
         expectedFee =  TroveManager.getBorrowingFeeWithDecay(pusdAmount);
        console.log("liquidationReserve",liquidationReserve);
        console.log("expectedFee",expectedFee);
        // Total debt of the new trove = pusd amount drawn, plus fee, plus the liquidation reserve
         totalDebt=pusdAmount+liquidationReserve+expectedFee;
         NICR =( ETHColl*_1e20)/totalDebt;
         numTroves = SortedTroves.getSize();
         numTrials = numTroves*15;
        console.log("NICR",NICR);
        console.log("numTrials",numTrials);
        ( hintAddress,, )=HintHelpers.getApproxHint(NICR, numTrials, 42);
        //hint helper not working on forked env , so directly assigning hint address in below  findInsertPosition  function .
        ( upperHint,  lowerHint ) = SortedTroves.findInsertPosition(NICR, hintAddress, hintAddress);
        console.log("upperHint",upperHint);
        console.log("lowerHint",lowerHint);
         maxFee = 5e16; // Slippage protection: 5%
        // vm.startBroadcast(user1PrivateKey);
        console.log("bsd balance before ",IERC20(pusd).balanceOf(user2));
        console.log("btc balance ",user2.balance);
        vm.startPrank(user2);
        BorrowerOperations.openTrove{ value: ETHColl }(maxFee, pusdAmount, upperHint, lowerHint);
        console.log("bsd balance after ",IERC20(pusd).balanceOf(user2));
        troveStake=TroveManager.getTroveStake(user2);
        console.log("troveStake",troveStake);
        totalCollateralSnapshot=TroveManager.totalCollateralSnapshot();
        console.log("totalCollateralSnapshot",totalCollateralSnapshot);

        totalStakesSnapshot=TroveManager.totalStakesSnapshot();
        console.log("totalStakesSnapshot",totalStakesSnapshot);
        vm.stopPrank();


    




        /*Adjusting the Trove*/
        console.log("==================================== ");
        console.log("Adjusting the Trove vuser1  ");
        console.log("==================================== ");
        // Get trove's current debt and coll
        ( debt, coll,,) = TroveManager.getEntireDebtAndColl(user1);
        console.log("debt ",debt);
        console.log("coll",coll);
        newDebt=debt-pusdRepayment;
        newColl=coll+collIncrease;
        NICR =( newColl*_1e20)/newDebt;
        numTroves = SortedTroves.getSize();
        numTrials = numTroves*15;
        console.log("NICR",NICR);
        console.log("numTrials",numTrials);
        //hint helper not working on forked env , so directly assigning hint address in below  findInsertPosition  function .
        ( hintAddress,, )=HintHelpers.getApproxHint(NICR, numTrials, 42);
        ( upperHint,  lowerHint ) = SortedTroves.findInsertPosition(NICR, hintAddress, hintAddress);
        console.log("upperHint",upperHint);
        console.log("lowerHint",lowerHint);
        console.log("pusd balance before adjust ",IERC20(pusd).balanceOf(user1));
        vm.startPrank(user1);
        BorrowerOperations.adjustTrove{ value: collIncrease }(maxFee, 0, pusdRepayment, false, upperHint, lowerHint);
        console.log("pusd balance after adjust ",IERC20(pusd).balanceOf(user1));
        ( debt, coll,,) = TroveManager.getEntireDebtAndColl(user1);
        console.log("debt ",debt);
        console.log("coll",coll);
        troveStake=TroveManager.getTroveStake(user1);
        console.log("troveStake",troveStake);
        vm.stopPrank();





         /*redeemCollateral the Trove*/
        console.log(block.number);
        console.log(block.timestamp);
        skip(1296000);
        console.log(block.number);
        console.log(block.timestamp);


        console.log("==================================== ");
        console.log("TroveManager::redeemCollateral");
        console.log("==================================== ");
        ethusdprice=PriceFeed.fetchPrice();

         (
             firstRedemptionHint,
             partialRedemptionNewICR,
             truncatedpusdamount
        ) = HintHelpers.getRedemptionHints(IERC20(pusd).balanceOf(user1)/2, ethusdprice, 50);
        console.log("firstRedemptionHint",firstRedemptionHint);
        console.log("partialRedemptionNewICR",partialRedemptionNewICR);
        console.log("truncatedpusdamount",truncatedpusdamount);
        numTroves = SortedTroves.getSize();
        numTrials = numTroves*15;
        console.log("numTrials",numTrials);
        ( hintAddress,,)=HintHelpers.getApproxHint(partialRedemptionNewICR, numTrials, 42);
        // //approxPartialRedemptionHint=0x6b27a8AB1bf2F169F694C122CF0c5B0e832AB46a
        ( upperHint,  lowerHint ) =  SortedTroves.findInsertPosition(partialRedemptionNewICR,
        hintAddress,
        hintAddress);
        console.log("upperHint",upperHint);
        console.log("lowerHint",lowerHint);
        console.log("pusd balance before redeemCollateral ",IERC20(pusd).balanceOf(user1));
        console.log("eth balance before redeemCollateral ",user1.balance);
        vm.startPrank(user1);
        TroveManager.redeemCollateral(truncatedpusdamount,
        firstRedemptionHint,
        upperHint,
        lowerHint,
        partialRedemptionNewICR,
        0, /*maxFee */2e17);
        console.log("pusd balance after redeemCollateral ",IERC20(pusd).balanceOf(user1));
        console.log("eth balance before redeemCollateral ",user1.balance);
        vm.stopPrank();



        ( debt, coll,,) = TroveManager.getEntireDebtAndColl(user1);
        console.log("debt ",debt);
        console.log("coll",coll);



        // /*Transfer pusd to other user1 and try to redeem eth*/
        // console.log("==================================== ");
        // console.log("Transfer pusd to other user2 and try to redeem eth");
        // console.log("==================================== ");
        // vm.startPrank(user1);
        // IERC20(pusd).transfer(user2, IERC20(pusd).balanceOf(user1)/3);
        // vm.stopPrank();
        // ethusdprice=PriceFeed.fetchPrice();

        //  (
        //      firstRedemptionHint,
        //      partialRedemptionNewICR,
        //      truncatedpusdamount
        // ) = HintHelpers.getRedemptionHints(IERC20(pusd).balanceOf(user2), ethusdprice, 50);
        // console.log("firstRedemptionHint",firstRedemptionHint);
        // console.log("partialRedemptionNewICR",partialRedemptionNewICR);
        // console.log("truncatedpusdamount",truncatedpusdamount);
        // numTroves = SortedTroves.getSize();
        // numTrials = numTroves*15;
        // console.log("numTrials",numTrials);
        // ( hintAddress, ,)=HintHelpers.getApproxHint(partialRedemptionNewICR, numTrials, 42);
        // // //approxPartialRedemptionHint=0x6b27a8AB1bf2F169F694C122CF0c5B0e832AB46a  
        // ( upperHint,  lowerHint ) =  SortedTroves.findInsertPosition(partialRedemptionNewICR,
        // hintAddress,
        // hintAddress);
        // console.log("upperHint",upperHint);
        // console.log("lowerHint",lowerHint);
        // console.log("pusd balance before redeemCollateral ",IERC20(pusd).balanceOf(user2));
        // console.log("eth balance before redeemCollateral ",user2.balance);
        // vm.startPrank(user2);
        // TroveManager.redeemCollateral(truncatedpusdamount,
        // firstRedemptionHint,
        // upperHint,
        // lowerHint,
        // partialRedemptionNewICR,
        // 0, /*maxFee */4e17 );
        // console.log("pusd balance before redeemCollateral ",IERC20(pusd).balanceOf(user2));
        // console.log("eth balance after redeemCollateral ",user2.balance);
        // ( debt, coll,,) = TroveManager.getEntireDebtAndColl(user2);
        // console.log("debt ",debt);
        // console.log("coll",coll);
        // vm.stopPrank(); 



        /*Adjust Trove Mint pusd more*/
        console.log("==================================== ");
        console.log("Adjust Trove Mint pusd more");
        console.log("==================================== ");
        vm.startPrank(user1);
        ( debt, coll,,) = TroveManager.getEntireDebtAndColl(user1);
        console.log("debt ",debt);
        console.log("coll",coll);
        newDebt=debt+pusdMintMore;
        newColl=coll+collIncrease;
        NICR =( newColl*_1e20)/newDebt;
        numTroves = SortedTroves.getSize();
        numTrials = numTroves*15;
        console.log("NICR",NICR);
        console.log("numTrials",numTrials);
        //hint helper not working on forked env , so directly assigning hint address in below  findInsertPosition  function .
        ( hintAddress,, )=HintHelpers.getApproxHint(NICR, numTrials, 42);
        ( upperHint,  lowerHint ) = SortedTroves.findInsertPosition(NICR, hintAddress, hintAddress);
        console.log("upperHint",upperHint);
        console.log("lowerHint",lowerHint);
        console.log("pusd balance before Adjust Trove Mint pusd more ",IERC20(pusd).balanceOf(user1));
        console.log("eth balance before Adjust Trove Mint pusd more ",user1.balance);
        BorrowerOperations.adjustTrove{ value: collIncrease }(maxFee, 0, pusdMintMore, true, upperHint, lowerHint);
        console.log("pusd balance after Adjust Trove Mint pusd more ",IERC20(pusd).balanceOf(user1));
        console.log("eth balance before Adjust Trove Mint pusd more ",user1.balance);
        vm.stopPrank();


        /*Provide To Stability Pool*/
        console.log("==================================== ");
        console.log("Provide To Stability Pool");
        console.log("==================================== ");
        vm.startPrank(user1);
        ( debt, coll,,) = TroveManager.getEntireDebtAndColl(user1);
        console.log("debt ",debt);
        console.log("coll",coll);
        console.log("pusd balance before Provide To Stability Pool ",IERC20(pusd).balanceOf(user1));
        console.log("eth balance before Provide To Stability Pool ",user1.balance);
        StabilityPool.provideToSP(stablePoolDepAmount, address(0));
        console.log("pusd balance after Provide To Stability Pool ",IERC20(pusd).balanceOf(user1));
        console.log("eth balance before Provide To Stability Pool ",user1.balance);
        uint256 getCompoundedLUSDDeposit=StabilityPool.getCompoundedLUSDDeposit(user1);
        console.log("getCompoundedLUSDDeposit ",getCompoundedLUSDDeposit);

        vm.stopPrank();





        /*Lets see debt and collaterl*/
        console.log("==================================== ");
        console.log("Lets liquidate user by first setting low price and calling liquidate ");
        console.log("==================================== ");

       ( debt, coll,,) = TroveManager.getEntireDebtAndColl(user1);
        console.log("debt before user1 liquidate of user1  ",debt);
        console.log("coll before user1 liquidate of user1 ",coll);

        ( debt, coll,,) = TroveManager.getEntireDebtAndColl(user2);
        console.log("debt before user1 liquidate of user2 ",debt);
        console.log("coll before user1 liquidate of user2",coll);

        vm.prank(owner);
        PriceFeed.setPrice(200000000000000000000);

        vm.startPrank(user3);
        TroveManager.liquidate(user1);

        ( debt, coll,,) = TroveManager.getEntireDebtAndColl(user1);
        console.log("debt after user1 liquidate of user1  ",debt);
        console.log("coll after user1 liquidate of user1 ",coll);

        ( debt, coll,,) = TroveManager.getEntireDebtAndColl(user2);
        console.log("debt after user1 liquidate of user2 ",debt);
        console.log("coll after user1 liquidate of user2",coll);

        // vm.stopPrank(); 
        // // vm.stopBroadcast();

    }

}