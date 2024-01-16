/*command Sequence
* anvil -f https://goerli.infura.io/v3/ad9cef41c9c844a7b54d10be24d416e5 --mnemonic ".seed mnemonic"  --port 3000

* forge test --match-path test/liquity/PlayaroundGoerli.t.sol --fork-url http://127.0.0.1:3000/ -vvv
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

contract PlayaroundGoerli is Test {
    uint256 user1PrivateKey;
    uint256 user2PrivateKey;
    address user1;
    address user2;
    address owner=0x152b1Da694bE93D2DCaF5662d33F91b13FfFD2ce;
    

    // //goerli testnet
    // address borrowerOperations =0xAbaf80156857E05b1EB162552Bea517b25F29aD9;

    // address troveManager = 0x3b8225C88a66aF1C00416bCa3fbF938D128B84b9;
    // address hintHelpers=0xd4d1D220a0D2d4D60cBD5502C5A372928f9649B9;
    // address sortedTroves=0xe931672196AB22B0c161b402B516f9eC33bD684c;
    // address priceFeed=0x25ADF247aC836D35be924f4b701A0787A30d46a9;
    // address collSurplusPool=0xA9C3e24d94ef6003fB6064D3a7cdd40F87bA44de;
    // address stabilityPool=0x74C5E75798b33D38abeE64f7EC63698B7e0a10f1;

    // address lusd= 0xe8d223328543Cc10Edaa3292CE12C320CE43A099;


    //fork

    address borrowerOperations =0x6e9Cd926Bf8F57FCe14b5884d9Ee0323126A772E;

    address troveManager = 0x5FB4E66C918f155a42d4551e871AD3b70c52275d;
    address hintHelpers=0xB18655E5402858c2F8829B091F460b0c69f48bed;
    address sortedTroves=0x4721ec6d9409648b7f03503b3db4eFe2dE1C57c3;
    address priceFeed=0x45f11BF102669731B49b9a6160212a9f99584152;
    address collSurplusPool=0xE0774dA339FA29bAf646B57B00644deA48fCaE23;
    address stabilityPool=0x104cA4C9415fbcCE53b5f522a1aBC96b3731aEB6;

    address lusd= 0xc55E23BdD71A00b8adD4c323d1724eF9193b7479;




    //variables to avoid stackstrace


    uint256 LUSDAmount = 500e18 ;// borrower wants to withdraw 2500 LUSD
    uint256 ETHColl = 5e18; // borrower wants to lock 5 ETH collateral
    uint256 _1e20 = 100e18;
    uint256 collIncrease = 1e18;  // borrower wants to add 1 ETH
    uint256 LUSDRepayment = 230e18; // borrower wants to repay 230 LUSD
    uint256 LUSDMintMore = 100e18; // borrower wants to repay 230 LUSD
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
    uint truncatedLUSDamount;
    bool mode;
    uint troveStake;
    uint totalStakesSnapshot;
    uint totalCollateralSnapshot;





    function setUp() public {
        string memory seedPhrase = vm.readFile(".secret");

        uint256 _user1PrivateKey = vm.deriveKey(seedPhrase, 2);
        user1PrivateKey=_user1PrivateKey;
        user1 = vm.addr(user1PrivateKey);

        uint256 _user2PrivateKey = vm.deriveKey(seedPhrase, 3);
        user2PrivateKey=_user2PrivateKey;
        user2 = vm.addr(user2PrivateKey);

        
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
        PriceFeed.setPrice(2000000000000000000000);
        ethusdprice=PriceFeed.fetchPrice();
        console.log("ethusdprice",ethusdprice);

        console.log("token name",token(lusd).symbol());

        




        console.log("==================================== ");
        console.log("TroveManager::Check Mode");
        console.log("==================================== ");
        mode =TroveManager.checkRecoveryMode(ethusdprice);
        console.log("mode",mode);



        /*Opening the Trove*/
        console.log("==================================== ");
        console.log("Opening the Trove ");
        console.log("==================================== ");

        // Call deployed TroveManager contract to read the liquidation reserve and latest borrowing fee
        uint256 liquidationReserve = TroveManager.LUSD_GAS_COMPENSATION();
        uint256 expectedFee =  TroveManager.getBorrowingFeeWithDecay(LUSDAmount);
        console.log("liquidationReserve",liquidationReserve);
        console.log("expectedFee",expectedFee);
        // Total debt of the new trove = LUSD amount drawn, plus fee, plus the liquidation reserve
        uint256 totalDebt=LUSDAmount+liquidationReserve+expectedFee;
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
        console.log("bsd balance before ",IERC20(lusd).balanceOf(user1));
        console.log("btc balance ",user1.balance);
        vm.startPrank(user1);
        BorrowerOperations.openTrove{ value: ETHColl }(maxFee, LUSDAmount, upperHint, lowerHint);
        console.log("bsd balance after ",IERC20(lusd).balanceOf(user1));
        troveStake=TroveManager.getTroveStake(user1);
        console.log("troveStake",troveStake);
        totalCollateralSnapshot=TroveManager.totalCollateralSnapshot();
        console.log("totalCollateralSnapshot",totalCollateralSnapshot);

        totalStakesSnapshot=TroveManager.totalStakesSnapshot();
        console.log("totalStakesSnapshot",totalStakesSnapshot);

    




        /*Adjusting the Trove*/
        console.log("==================================== ");
        console.log("Adjusting the Trove ");
        console.log("==================================== ");
        // Get trove's current debt and coll
        ( debt, coll,,) = TroveManager.getEntireDebtAndColl(user1);
        console.log("debt ",debt);
        console.log("coll",coll);
        newDebt=debt-LUSDRepayment;
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
        console.log("lusd balance before adjust ",IERC20(lusd).balanceOf(user1));
        BorrowerOperations.adjustTrove{ value: collIncrease }(maxFee, 0, LUSDRepayment, false, upperHint, lowerHint);
        console.log("lusd balance after adjust ",IERC20(lusd).balanceOf(user1));

        ( debt, coll,,) = TroveManager.getEntireDebtAndColl(user1);
        console.log("debt ",debt);
        console.log("coll",coll);
        troveStake=TroveManager.getTroveStake(user1);
        console.log("troveStake",troveStake);
        vm.stopPrank();





        //  /*redeemCollateral the Trove*/
        // console.log("==================================== ");
        // console.log("TroveManager::redeemCollateral");
        // console.log("==================================== ");
        // ethusdprice=PriceFeed.fetchPrice();

        //  (
        //      firstRedemptionHint,
        //      partialRedemptionNewICR,
        //      truncatedLUSDamount
        // ) = HintHelpers.getRedemptionHints(IERC20(lusd).balanceOf(user1)/2, ethusdprice, 50);
        // console.log("firstRedemptionHint",firstRedemptionHint);
        // console.log("partialRedemptionNewICR",partialRedemptionNewICR);
        // console.log("truncatedLUSDamount",truncatedLUSDamount);
        // numTroves = SortedTroves.getSize();
        // numTrials = numTroves*15;
        // console.log("numTrials",numTrials);
        // // (address hintAddress, uint diff, uint latestRandomSeed)=HintHelpers.hintHelpers.getApproxHint(partialRedemptionNewICR, numTrials, 42)
        // //approxPartialRedemptionHint=0x6b27a8AB1bf2F169F694C122CF0c5B0e832AB46a
        // ( upperHint,  lowerHint ) =  SortedTroves.findInsertPosition(partialRedemptionNewICR,
        // 0x6b27a8AB1bf2F169F694C122CF0c5B0e832AB46a,
        // 0x6b27a8AB1bf2F169F694C122CF0c5B0e832AB46a);
        // console.log("upperHint",upperHint);
        // console.log("lowerHint",lowerHint);
        // console.log("lusd balance before redeemCollateral ",IERC20(lusd).balanceOf(user1));
        // console.log("eth balance before redeemCollateral ",user1.balance);
        // TroveManager.redeemCollateral(truncatedLUSDamount,
        // firstRedemptionHint,
        // upperHint,
        // lowerHint,
        // partialRedemptionNewICR,
        // 0, maxFee );
        // console.log("lusd balance after redeemCollateral ",IERC20(lusd).balanceOf(user1));
        // console.log("eth balance before redeemCollateral ",user1.balance);


        // ( debt, coll,,) = TroveManager.getEntireDebtAndColl(user1);
        // console.log("debt ",debt);
        // console.log("coll",coll);



        // /*Transfer LUSD to other user1 and try to redeem eth*/
        // console.log("==================================== ");
        // console.log("Transfer LUSD to other user1 and try to redeem eth");
        // console.log("==================================== ");

        // IERC20(lusd).transfer(user2, IERC20(lusd).balanceOf(user1));
        // vm.stopPrank(); 
        // vm.startPrank(user2);
        // ethusdprice=PriceFeed.fetchPrice();

        //  (
        //      firstRedemptionHint,
        //      partialRedemptionNewICR,
        //      truncatedLUSDamount
        // ) = HintHelpers.getRedemptionHints(IERC20(lusd).balanceOf(user2), ethusdprice, 50);
        // console.log("firstRedemptionHint",firstRedemptionHint);
        // console.log("partialRedemptionNewICR",partialRedemptionNewICR);
        // console.log("truncatedLUSDamount",truncatedLUSDamount);
        // numTroves = SortedTroves.getSize();
        // numTrials = numTroves*15;
        // console.log("numTrials",numTrials);
        // // // (address hintAddress, uint diff, uint latestRandomSeed)=HintHelpers.hintHelpers.getApproxHint(partialRedemptionNewICR, numTrials, 42)
        // // //approxPartialRedemptionHint=0x6b27a8AB1bf2F169F694C122CF0c5B0e832AB46a  
        // ( upperHint,  lowerHint ) =  SortedTroves.findInsertPosition(partialRedemptionNewICR,
        // 0x6b27a8AB1bf2F169F694C122CF0c5B0e832AB46a,
        // 0x6b27a8AB1bf2F169F694C122CF0c5B0e832AB46a);
        // console.log("upperHint",upperHint);
        // console.log("lowerHint",lowerHint);
        // console.log("lusd balance before redeemCollateral ",IERC20(lusd).balanceOf(user2));
        // console.log("eth balance before redeemCollateral ",user2.balance);
        // TroveManager.redeemCollateral(truncatedLUSDamount,
        // firstRedemptionHint,
        // upperHint,
        // lowerHint,
        // partialRedemptionNewICR,
        // 0, maxFee );
        // console.log("lusd balance before redeemCollateral ",IERC20(lusd).balanceOf(user2));
        // console.log("eth balance after redeemCollateral ",user2.balance);
        // ( debt, coll,,) = TroveManager.getEntireDebtAndColl(user2);
        // console.log("debt ",debt);
        // console.log("coll",coll);
        // vm.stopPrank(); 



        /*Adjust Trove Mint LUSD more*/
        console.log("==================================== ");
        console.log("Adjust Trove Mint LUSD more");
        console.log("==================================== ");
        vm.startPrank(user1);
        ( debt, coll,,) = TroveManager.getEntireDebtAndColl(user1);
        console.log("debt ",debt);
        console.log("coll",coll);
        newDebt=debt+LUSDMintMore;
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
        console.log("lusd balance before Adjust Trove Mint LUSD more ",IERC20(lusd).balanceOf(user1));
        console.log("eth balance before Adjust Trove Mint LUSD more ",user1.balance);
        BorrowerOperations.adjustTrove{ value: collIncrease }(maxFee, 0, LUSDMintMore, true, upperHint, lowerHint);
        console.log("lusd balance after Adjust Trove Mint LUSD more ",IERC20(lusd).balanceOf(user1));
        console.log("eth balance before Adjust Trove Mint LUSD more ",user1.balance);
        vm.stopPrank();


        /*Provide To Stability Pool*/
        console.log("==================================== ");
        console.log("Provide To Stability Pool");
        console.log("==================================== ");
        vm.startPrank(user1);
        ( debt, coll,,) = TroveManager.getEntireDebtAndColl(user1);
        console.log("debt ",debt);
        console.log("coll",coll);
        console.log("lusd balance before Provide To Stability Pool ",IERC20(lusd).balanceOf(user1));
        console.log("eth balance before Provide To Stability Pool ",user1.balance);
        StabilityPool.provideToSP(stablePoolDepAmount, address(0));
        console.log("lusd balance after Provide To Stability Pool ",IERC20(lusd).balanceOf(user1));
        console.log("eth balance before Provide To Stability Pool ",user1.balance);
        uint256 getCompoundedLUSDDeposit=StabilityPool.getCompoundedLUSDDeposit(user1);
        console.log("getCompoundedLUSDDeposit ",getCompoundedLUSDDeposit);

        vm.stopPrank();






        // vm.stopPrank(); 
        // // vm.stopBroadcast();

    }

}