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
import "../../src/PriceRouter.sol";
import "../../src/PriceOracle.sol";

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

    address _priceOracle=0x9080325bA305953c0Dae207da8d424991DDf8186;
    address _priceRouter=0x77b713201dDA5805De0F19f4B8a127Cc55f6dac6;
    PriceRouter priceRouter;
    PriceOracle priceOracle;

    // address borrowerOperations =0x46ECf770a99d5d81056243deA22ecaB7271a43C7;
    // address troveManager = 0x84400014b6bFA5b76d2feb4F460AEac8dd84B656;
    // address hintHelpers=0xA7B88e482d3C9d17A1b83bc3FbeB4DF72cB20478;
    // address sortedTroves=0x6AB8c9590bD89cBF9DCC90d5efEC4F45D5d219be;
    // address priceFeed=0xDC63FB38FDB04B7e2A9A01f1792a4e021538fc57;
    // address collSurplusPool=0xAbaf80156857E05b1EB162552Bea517b25F29aD9;
    // address stabilityPool=0x25ADF247aC836D35be924f4b701A0787A30d46a9;
    // address pusd= 0x55FD5B67B115767036f9e8af569B281A8A544a12;


    //fork botanix
    address borrowerOperations =0x4D31Cc6324A2010595C8a3bD60e88Eb2ADFDb83e;
    address troveManager = 0x8e6B12783356d2321bF09386F088E0194B03f5dB;
    address hintHelpers=0xD7110E8E953d2bA408cEe5611413a17a2C6D8D68;
    address sortedTroves=0xc0551fAA6A12BbA561fC2cF439902AC8Cb9BF4E2;
    address priceFeed=0x89acFD0Ec0572D05f6Cb46469b197Ae0e0333e2D;
    address collSurplusPool=0x7E3954d1b556Abe3D670B6896267434b4f7eC090;
    address stabilityPool=0x0Bd4073E4c3b260812829C860552778896A77101;
    address pusd= 0x90200a19dF430a91eB34ACc219e6E81498Eae00D;
    address pdm=0xCE36C4e1703106e9cAB6258A6dcB6FeB52D25E87;





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
        priceOracle=PriceOracle(_priceOracle);
        priceRouter=PriceRouter(_priceRouter);
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
        // vm.prank(owner);
        // PriceFeed.setPrice(45000e18);
        updatePrice(45000e18);
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
        vm.startPrank(user1);
        StabilityPool.provideToSP(stablePoolDepAmount, address(0));
        uint256 getCompoundedLUSDDeposit=StabilityPool.getCompoundedLUSDDeposit(user1);
        vm.stopPrank();
    }

    function test_ProvideToStabilityPoolAndLiquidate() public {
        uint stablePoolDepAmount=1000e18;
        ethusdprice=PriceFeed.fetchPrice();
        openTrove(user1, 2500e18, 1e18);
        openTrove(user2, pusdAmount, 5e18);
        openTrove(user3, pusdAmount, 5e18);
        vm.startPrank(user3);
        StabilityPool.provideToSP(stablePoolDepAmount, address(0));
        uint256 getCompoundedLUSDDeposit=StabilityPool.getCompoundedLUSDDeposit(user3)/1e18;
        vm.stopPrank();
        uint ICRuser=TroveManager.getCurrentICR(user1, ethusdprice);
        console.log("getCompoundedLUSDDeposit beforee",getCompoundedLUSDDeposit);
        console.log("ICRuser before",ICRuser/1e16);
        ( debt, coll, , )=TroveManager.getEntireDebtAndColl(user1);
        uint liquidationPriceForUer1=calculateLiquidationPrice(110, debt, coll);
        // vm.prank(owner);
        // PriceFeed.setPrice(liquidationPriceForUer1-1e18);
        updatePrice(liquidationPriceForUer1-1e18);
        ethusdprice=PriceFeed.fetchPrice();
        ICRuser=TroveManager.getCurrentICR(user1, ethusdprice);
        console.log("ICRuser after nprice change",ICRuser/1e16);
        vm.startPrank(user4);
        TroveManager.liquidate(user1);
        getCompoundedLUSDDeposit=StabilityPool.getCompoundedLUSDDeposit(user3)/1e18;
        uint256 getEthGain=StabilityPool.getDepositorETHGain(user3);
        uint256 getLQTYGain=StabilityPool.getDepositorLQTYGain(user3);
        console.log("getEthGain after liquidate",getEthGain);
        console.log("getLQTYGain after liquidate",getLQTYGain);
        console.log("getCompoundedLUSDDeposit after liquidate",getCompoundedLUSDDeposit);
        console.log("btcbalance before withdraw",user3.balance);
        vm.startPrank(user3);
        StabilityPool.withdrawFromSP(0);
        console.log("btcbalance after withdraw",user3.balance);
    }

    function test_RemoveFromStabilityPool() public {
        uint collAmount=5e18;
        uint stablePoolDepAmount=1000e18;
        openTrove(user1, pusdAmount, collAmount);
        console.log("pusd balance before Provide To Stability Pool ",IERC20(pusd).balanceOf(user1));
        vm.startPrank(user1);
        StabilityPool.provideToSP(stablePoolDepAmount, address(0));
        uint256 getCompoundedLUSDDeposit=StabilityPool.getCompoundedLUSDDeposit(user1);
        console.log("pusd balance after Provide To Stability Pool ",IERC20(pusd).balanceOf(user1));
        console.log("getCompoundedLUSDDeposit",getCompoundedLUSDDeposit);
        StabilityPool.withdrawFromSP(stablePoolDepAmount/4);
        getCompoundedLUSDDeposit=StabilityPool.getCompoundedLUSDDeposit(user1);
        console.log("getCompoundedLUSDDeposit",getCompoundedLUSDDeposit);
        StabilityPool.withdrawFromSP(getCompoundedLUSDDeposit);
        getCompoundedLUSDDeposit=StabilityPool.getCompoundedLUSDDeposit(user1);
        console.log("getCompoundedLUSDDeposit",getCompoundedLUSDDeposit);
        vm.stopPrank();
    }


    function test_LiquidateTrove() public {
        openTrove(user1, 30000e18, 1e18);
        openTrove(user2, pusdAmount, collateralAmount);
        openTrove(user3, pusdAmount, collateralAmount);
        (uint debt,uint coll, , )=TroveManager.getEntireDebtAndColl(user1);
        uint liquidationPriceForUer1=calculateLiquidationPrice(110, debt, coll);
        console.log("liquidationPriceForUer1",liquidationPriceForUer1/1e18);
        // vm.prank(owner);
        // PriceFeed.setPrice(liquidationPriceForUer1-1e18);
        updatePrice(liquidationPriceForUer1-1e18);
        vm.startPrank(user4);
        TroveManager.liquidate(user1);
        ( debt, coll,,) = TroveManager.getEntireDebtAndColl(user1);
        console.log("debt after user1 liquidate of user1  ",debt);
        console.log("coll after user1 liquidate of user1 ",coll);
    }


    function test_BountyAddressLock() public {
        // vm.prank(owner);
        // PriceFeed.setPrice(60000e18);
        updatePrice(60000e18);
        ethusdprice=PriceFeed.fetchPrice();
        console.log("ethusdprice",ethusdprice);
        console.log("pdm balanceof bounty user",IERC20(pdm).balanceOf(user4));
        vm.startPrank(user4);
        IERC20(pdm).transfer(user5, IERC20(pdm).balanceOf(user4)/2);
        console.log("pdm balanceof  user 5",IERC20(pdm).balanceOf(user5));
        console.log("pdm balanceof bounty user",IERC20(pdm).balanceOf(user4));

    }

    function test_CalculateRatio( ) public {
        uint btcPrice=PriceFeed.fetchPrice();
        uint collAmount= 1e18;
        uint borrowAmount=20000e18;
        openTrove(user1, borrowAmount, collAmount);
        (uint debt,uint coll, , )=TroveManager.getEntireDebtAndColl(user1);
        uint troveRatioFromProtocol=TroveManager.getCurrentICR(user1, btcPrice);
        uint troveRatioFromFunction=calculateCollateralRatio(debt, coll, btcPrice);
        console.log("troveRatio from protocol",troveRatioFromProtocol/1e16);
        console.log("troveRatio from fucntion",troveRatioFromFunction/1e18);
    }

    function test_MaxBorrowOpenTroveInNormalMode() public {
        uint MCR=TroveManager.MCR()/1e16;
        openTrove(user2, pusdAmount, 5e18);
        openTrove(user3, pusdAmount, 5e18);
        openTrove(user4, pusdAmount, 5e18);
        uint btcPrice=PriceFeed.fetchPrice();
        uint collAmount=1e18;
        uint maxBorrowAmount=calculateMaxBorrowAmountOpenTrove(MCR/*110*/, collAmount, btcPrice);
        console.log("maxBorrowAmount",maxBorrowAmount);
        openTrove(user1, maxBorrowAmount, collAmount);
        uint getTroveTCR=TroveManager.getCurrentICR(user1, btcPrice);
        console.log("getTroveTCR",getTroveTCR);
    }

    function test_MaxBorrowOpenTroveInRecoveryMode() public {
        uint CCR=TroveManager.CCR()/1e16;
        openTrove(user2, 40000e18, 5e18);
        openTrove(user3, 40000e18, 5e18);
        openTrove(user4, 40000e18, 5e18);
        uint btcPrice=PriceFeed.fetchPrice();
        uint collAmount=1e18;
        uint getEntireSystemDebt=TroveManager.getEntireSystemDebt();
        uint getEntireSystemColl=TroveManager.getEntireSystemColl();
        uint recModePrice=calculateLiquidationPrice(CCR, getEntireSystemDebt, getEntireSystemColl);
        console.log("recModePrice",recModePrice/1e18);
        uint TCR=TroveManager.getTCR(recModePrice-1e18);
        btcPrice=PriceFeed.fetchPrice();
        // vm.prank(owner);
        // PriceFeed.setPrice(recModePrice-1e18);//this will put protocol in recovery mode
        updatePrice(recModePrice-1e18);
        btcPrice=PriceFeed.fetchPrice();
        uint maxBorrowAmount=calculateMaxBorrowAmountOpenTrove(CCR/*150*/, collAmount, btcPrice);
        console.log("maxBorrowAmount",maxBorrowAmount);
        openTrove(user1, maxBorrowAmount, collAmount);
        uint getTroveTCR=TroveManager.getCurrentICR(user1, btcPrice);
        console.log("getTroveTCR",getTroveTCR);//there is slight error up here ≈0.5%
    }

    function test_MaxBorrowIncreaseOnlyDebt( ) public {
        openTrove(user2, 35000e18,2e18);
        openTrove(user3, 35000e18,2e18);
        //^dummy openig^
        uint debtIncrease;
        uint maxDebtIncrease;
        openTrove(user1, 2500e18,1e18);
        ( debt, coll,,) = TroveManager.getEntireDebtAndColl(user1);
        console.log("debt before",debt);
        console.log("coll before",coll);
        maxDebtIncrease=calculateMaxBorrowAmountIcreaseDebt(110, coll, debt, PriceFeed.fetchPrice());
        console.log("maxDebtIncrease",maxDebtIncrease);
        debtIncrease=maxDebtIncrease;
        console.log("ratio",calculateCollateralRatio(debt+maxDebtIncrease,coll,PriceFeed.fetchPrice()));
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
        uint getTroveTCR=TroveManager.getCurrentICR(user1, PriceFeed.fetchPrice());
        console.log("getTroveTCR",getTroveTCR/1e16);//there is slight error up here ≈0.5%
    }

    function test_MaxBorrowIncreaseBothDebtAndCollateral( ) public {
        openTrove(user2, 40000e18, 5e18);
        openTrove(user3, 40000e18, 5e18);
        openTrove(user4, 40000e18, 5e18);
        uint pusdAmount=2500e18;
        uint collAmount =1e18;
        uint debtIncrease=500e18;
        uint collIncrease=2e18;
        openTrove(user1, pusdAmount,collAmount);
        ( debt, coll,,) = TroveManager.getEntireDebtAndColl(user1);
        console.log("debt before",debt);
        console.log("coll before",coll);
        debtIncrease=calculateMaxBorrowAmountIcreaseDebt(110, coll+collIncrease, debt, PriceFeed.fetchPrice());
        console.log("debtIncrease",debtIncrease);
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
        uint getTroveTCR=TroveManager.getCurrentICR(user1, PriceFeed.fetchPrice());
        console.log("getTroveTCR",getTroveTCR/1e16);//there is slight error up here ≈0.5%
    }

    function test_CCR() public {
        openTrove(user2, 40000e18, 2e18);
        openTrove(user3, 40000e18, 3e18);
        openTrove(user4, 40000e18, 4e18);
        uint CCR=TroveManager.CCR()/1e16;
        uint MCR=TroveManager.MCR()/1e16;
        uint btcPrice=PriceFeed.fetchPrice();
        bool mode =TroveManager.checkRecoveryMode(btcPrice);
        assertEq(mode, false);
        uint getTotalTCR=TroveManager.getTCR(btcPrice)/1e16;
        uint getEntireSystemDebt=TroveManager.getEntireSystemDebt();
        uint getEntireSystemColl=TroveManager.getEntireSystemColl();
        uint recModePrice=calculateLiquidationPrice(CCR, getEntireSystemDebt, getEntireSystemColl);
        updatePrice(recModePrice-1e18);
        btcPrice=PriceFeed.fetchPrice();
        mode =TroveManager.checkRecoveryMode(btcPrice);
        assertEq(mode, true);
    }

    function test_PriceFeedTest() public {
        uint btcPrice=PriceFeed.fetchPrice();
        console.log("btcPrice",btcPrice/1e18);

        address router=PriceFeed.priceRouter();
        assertEq(router, address(priceRouter));

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

    function calculateCollateralRatio(uint debtAmount/*(18dec input)*/,uint collAmount/*(18dec input)*/,uint btcPrice/*(18dec input)*/) public returns(uint){
        uint CollateralRatio=(collAmount*btcPrice*100)/(debtAmount);
        return CollateralRatio;//in 18 decimal while protocl returns in 16 decimal dont get confused
    }

    function calculateMaxBorrowAmountOpenTrove(uint collRatio/*110 innormal & 150 in recovery(normal input)*/,uint collAmount/*(18dec input)*/,uint btcPrice/*(18dec input)*/) public returns (uint) {
        uint borrowingRateWithDecay=TroveManager.getBorrowingRateWithDecay();
        // uint deimalPrecision=TroveManager.DECIMAL_PRECISION();
        // uint Rate=borrowingRateWithDecay/deimalPrecision;
        // console.log("rAte",Rate);
        uint BorrowAmountNoReserveAndFee=(collAmount*btcPrice*100)/(collRatio*1e18);
        uint256 liquidationReserve = TroveManager.LUSD_GAS_COMPENSATION();
        uint maxBorrowAmount=((BorrowAmountNoReserveAndFee-liquidationReserve)*1e18)/(borrowingRateWithDecay+1e18);
        return maxBorrowAmount;//in 18 decimal
    }

    function calculateMaxBorrowAmountIcreaseDebt(uint collRatio/*110 innormal & 150 in recovery(normal input)*/,uint collAmount/*(18dec input)*/,uint currentBebt,uint btcPrice/*(18dec input)*/) public returns (uint) {
        uint borrowingRateWithDecay=TroveManager.getBorrowingRateWithDecay();
        uint BorrowAmountNoReserveAndFee=(collAmount*btcPrice*100)/(collRatio*1e18);
        // uint256 liquidationReserve = TroveManager.LUSD_GAS_COMPENSATION();
        uint maxBorrowAmount=(BorrowAmountNoReserveAndFee*1e18)/(borrowingRateWithDecay+1e18);
        return maxBorrowAmount-currentBebt;//in 18 decimal
    }

    function calculateLiquidationPrice(uint liquidationThreshhold/*(normal input)*/,uint debtAmount/*(18dec input)*/,uint collAmount/*(18dec input)*/) public returns(uint) {
        uint liquidationPrice=(liquidationThreshhold*debtAmount*1e18)/(collAmount*100);
        return liquidationPrice;//in 18 decimal
    }

    function updatePrice(uint price) public  {
        vm.prank(owner);
        priceOracle.setPrice(price);
    }

    

}