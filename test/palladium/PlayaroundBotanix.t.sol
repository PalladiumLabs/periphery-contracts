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
import "./interfaces/IUniswapV2Router02.sol";
import "./interfaces/IWETH.sol";
import "./interfaces/IUniswapV2Factory.sol";
import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IUnipool.sol";
import "../../src/PriceRouter.sol";
import "../../src/PriceOracle.sol";
import {SigUtils} from "./utils/SigUtils.sol";

interface token{
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function multisigAddress() external view returns(address);
    function permit(address owner, address spender, uint256 amount, 
                    uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;
    function domainSeparator() external view  returns (bytes32);
    function nonces(address owner) external view  returns (uint256);
}

contract PlayaroundBotanix is Test {

    //tokenomics 
    // uint bountyEntitlement=35e24;
    // uint depositorsAndFrontEndsEntitlement=30e24;
    // uint _lpRewardsEntitlement=5e24;
    // uint multisigEntitlement=30e24;
    uint bountyEntitlement=350e24;
    uint depositorsAndFrontEndsEntitlement=300e24;
    uint _lpRewardsEntitlement=50e24;
    uint multisigEntitlement=300e24;

    IBorrowerOperations BorrowerOperations;
    IHintHelpers HintHelpers ;
    ITroveManager TroveManager ;
    ISortedTroves SortedTroves;
    IPriceFeed PriceFeed;
    ICollSurplusPool CollSurplusPool;
    IStabilityPool StabilityPool ;
    IUnipool Unipool ;
    IUniswapV2Router02 UniswapV2Router ;
    IUniswapV2Factory UniswapV2Factory ;
    IWETH Wbtc ;
    PriceRouter priceRouter;
    PriceOracle priceOracle;
    SigUtils internal sigUtils;
    uint256 user1PrivateKey;
    uint256 ownerAcPvt;
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
    // address owner=0x150CC4F90516C23e64231D2B92d737893DBb2515;
    address ownerOracle=0x961Ef0b358048D6E34BDD1acE00D72b37B9123D7;

    address _priceOracle=0x5BCC7cf55D3ce55cF97E05776F8155b595D40a78;
    address _priceRouter=0xd9833A378637573E1CB56Bb9FFd69FA1F487Ad31;
    address wbtc=0x69e0778b9Ba7e795329Ec8971B1FE46fA783daF6;
    address factory=0xE84a814B835E9F54e528Fb96205120E3bdA3f7d0;
    address router=0x00D4FDC04e86269cE7F4b1AcD985d5De0eA1C16d;



    // address borrowerOperations =0x1a45fEEe34a2fcfB39f28c57A1df08756f5d3A97;
    // address troveManager = 0x5fFE923816F183AfE08BFB5ea534Fbd71E07cd37;
    // address hintHelpers=0xF5c7b80ADd60c187479538Ec232E4b7CcB838D88;
    // address sortedTroves=0x672D640c5830e966C8a47d038bccD0631BA45a94;
    // address priceFeed=0x8549B49af5B0Ad6BFebBecF0177FCe8708921522;
    // address collSurplusPool=0x3F08e261bB89Dc3083C070041Db0A5A01E0d05A4;
    // address stabilityPool=0xb5d2f71f2B1506Ec243D0B232EB15492d685B689;
    // address pusd= 0xB7d7027B5dD0c50946dE98c26e5969b37D588c32;
    // address pdm=0x870dD7AB33Ac1d97d297cA600D5877e5B8e70842;
    // address communityIssuance=0x5a9BFeF291AA30fc3e344A019F2066dC37f3DB47;
    // address unipool=0xb49D376377556d411C5C82B417FdF5A6fd5559C0;
    // address uniToken=0x327a6A94485283d221A35246C2b61C2Bb359Cf96;

    //fork botanix
    address borrowerOperations =0x87d0c4E319640a5dEd725B8dE0640174b4695049;
    address troveManager = 0xfe30D11bf47609d01f4861ac1E8eA69A88af5e98;
    address hintHelpers=0xB7ab7086C34033723E0D756FB6736f677Bc28617;
    address sortedTroves=0xB62Fc6E4424757e6754fF0F737455133DCa1a0E4;
    address priceFeed=0x81bD0d2192D9f92aE6bf54E9a8cF202c2fe3F457;
    address collSurplusPool=0xE4040b417c7B555Fc9C16A91e9400fA0E8A657Dd;
    address stabilityPool=0x061EeDE6fa01306c75a0A549E0C2D334fC7d2090;
    address pusd= 0x616Ec656451D163b1cEe9BB22Fb769C2f1534ffB;
    address pdm=0x38cd889db746A67D77e531E80CA552853dCfDDF9;
    address communityIssuance=0x2f8825523A0F2A4275582ed334438FF66E7edF3c;
    address unipool=0x9f49351F5803507b5fB515015236AE6b3C28a6E3;
    address uniToken=0x55Ba27CDBD815f0314d36AA39D3e59a8e5Ce5ca9;

    //oracle shared  botanix
    // address borrowerOperations =0x4D31Cc6324A2010595C8a3bD60e88Eb2ADFDb83e;
    // address troveManager = 0x8e6B12783356d2321bF09386F088E0194B03f5dB;
    // address hintHelpers=0xD7110E8E953d2bA408cEe5611413a17a2C6D8D68;
    // address sortedTroves=0xc0551fAA6A12BbA561fC2cF439902AC8Cb9BF4E2;
    // address priceFeed=0x89acFD0Ec0572D05f6Cb46469b197Ae0e0333e2D;
    // address collSurplusPool=0x7E3954d1b556Abe3D670B6896267434b4f7eC090;
    // address stabilityPool=0x0Bd4073E4c3b260812829C860552778896A77101;
    // address pusd= 0x90200a19dF430a91eB34ACc219e6E81498Eae00D;
    // address pdm=0xCE36C4e1703106e9cAB6258A6dcB6FeB52D25E87;





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

        uint256 _ownerAcPvt = vm.deriveKey(seedPhrase, 0);
        ownerAcPvt=_ownerAcPvt;

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
        Unipool = IUnipool(unipool);
        UniswapV2Router = IUniswapV2Router02(router);
        UniswapV2Factory= IUniswapV2Factory(factory) ;
        Wbtc= IWETH(wbtc) ;
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
        uint collusdprice=recievePrice();

        uint pusdAmount=1800e18;
        // uint pusdAmount=((collAmount*collusdprice*10)/11)-400e18;
        // uint collAmount =1e18;
        // vm.assume(pusdAmount>MIN_NET_DEBT && pusdAmount<50000e18);
        // vm.assume(collAmount>1e18 && collAmount<10e18);
        openTrove(user1, pusdAmount,collAmount);
    }
    function test_OpenTroveInRecoveryMode() public {
        uint CCR=TroveManager.CCR()/1e16;
        openTrove(user2, 40000e18, 5e18);
        openTrove(user3, 40000e18, 5e18);
        openTrove(user4, 40000e18, 5e18);
        uint btcPrice=recievePrice();
        uint collAmount=1e18;
        uint getEntireSystemDebt=TroveManager.getEntireSystemDebt();
        uint getEntireSystemColl=TroveManager.getEntireSystemColl();
        uint recModePrice=calculateLiquidationPrice(CCR, getEntireSystemDebt, getEntireSystemColl);
        console.log("recModePrice",recModePrice/1e18);
        uint TCR=TroveManager.getTCR(recModePrice-1e18);
        btcPrice=recievePrice();
        updatePrice(recModePrice-1e18);
        btcPrice=recievePrice();
        mode =TroveManager.checkRecoveryMode(ethusdprice);
        console.log("mode",mode);


        //try to borrow less than ccr amount
        uint maxBorrowAmount=calculateMaxBorrowAmountOpenTrove(128, collAmount, btcPrice);
        console.log("maxBorrowAmount",maxBorrowAmount);
        uint256 liquidationReserve = TroveManager.LUSD_GAS_COMPENSATION();
        uint256 expectedFee =  TroveManager.getBorrowingFeeWithDecay(maxBorrowAmount);
        // Total debt of the new trove = pusd amount drawn, plus fee, plus the liquidation reserve
        // uint256 totalDebt=maxBorrowAmount+liquidationReserve+expectedFee;
        uint256 NICR =( collAmount*_1e20)/(maxBorrowAmount+liquidationReserve+expectedFee);
        uint256 numTroves = SortedTroves.getSize();
        // uint256 numTrials = numTroves*15;
        (address hintAddress,, )=HintHelpers.getApproxHint(NICR, numTroves*15, 42);
        //hint helper not working on forked env , so directly assigning hint address in below  findInsertPosition  function .
        ( upperHint,  lowerHint ) = SortedTroves.findInsertPosition(NICR, hintAddress, hintAddress);
        uint256 maxFee = 5e16; // Slippage protection: 5%
        vm.startPrank(user1);
        vm.expectRevert(bytes("BorrowerOps: Operation must leave trove with ICR >= CCR"));
        BorrowerOperations.openTrove{ value: collAmount }(maxFee, maxBorrowAmount, upperHint, lowerHint);

        //try to borrow less than ccr amount
        maxBorrowAmount=calculateMaxBorrowAmountOpenTrove(132, collAmount, btcPrice);
        openTrove(user5, maxBorrowAmount, collAmount);


        // uint maxBorrowAmount=calculateMaxBorrowAmountOpenTrove(CCR/*150*/, collAmount, btcPrice);
        // console.log("maxBorrowAmount",maxBorrowAmount);
        // openTrove(user1, maxBorrowAmount, collAmount);
        // uint getTroveTCR=TroveManager.getCurrentICR(user1, btcPrice);
        // console.log("getTroveTCR",getTroveTCR);//there is slight error up here ≈0.5%
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
        ethusdprice=recievePrice();
        // vm.prank(owner);
        // PriceFeed.setPrice(45000e18);
        updatePrice(45000e18);
        ethusdprice=recievePrice();
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
        uint redeemAmount=10e18;
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
        ethusdprice=recievePrice();
         (
             firstRedemptionHint,
             partialRedemptionNewICR,
             truncatedpusdamount //Here truncatedpusdamount is max redeemable amount 
        ) = HintHelpers.getRedemptionHints(redeemAmount, ethusdprice, 50);
        console.log("truncatedpusdamount",truncatedpusdamount);
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
        ethusdprice=recievePrice();
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
        ethusdprice=recievePrice();
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
        ethusdprice=recievePrice();
        console.log("ethusdprice",ethusdprice);
        console.log("pdm balanceof bounty user",IERC20(pdm).balanceOf(user4));
        vm.startPrank(user4);
        IERC20(pdm).transfer(user5, IERC20(pdm).balanceOf(user4)/2);
        console.log("pdm balanceof  user 5",IERC20(pdm).balanceOf(user5));
        console.log("pdm balanceof bounty user",IERC20(pdm).balanceOf(user4));

    }

    function test_CalculateRatio( ) public {
        uint btcPrice=recievePrice();
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
        uint btcPrice=recievePrice();
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
        uint btcPrice=recievePrice();
        uint collAmount=1e18;
        uint getEntireSystemDebt=TroveManager.getEntireSystemDebt();
        uint getEntireSystemColl=TroveManager.getEntireSystemColl();
        uint recModePrice=calculateLiquidationPrice(CCR, getEntireSystemDebt, getEntireSystemColl);
        console.log("recModePrice",recModePrice/1e18);
        uint TCR=TroveManager.getTCR(recModePrice-1e18);
        btcPrice=recievePrice();
        // vm.prank(owner);
        // PriceFeed.setPrice(recModePrice-1e18);//this will put protocol in recovery mode
        updatePrice(recModePrice-1e18);
        btcPrice=recievePrice();
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
        maxDebtIncrease=calculateMaxBorrowAmountIcreaseDebt(110, coll, debt, recievePrice());
        console.log("maxDebtIncrease",maxDebtIncrease);
        debtIncrease=maxDebtIncrease;
        console.log("ratio",calculateCollateralRatio(debt+maxDebtIncrease,coll,recievePrice()));
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
        uint getTroveTCR=TroveManager.getCurrentICR(user1, recievePrice());
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
        debtIncrease=calculateMaxBorrowAmountIcreaseDebt(110, coll+collIncrease, debt, recievePrice());
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
        uint getTroveTCR=TroveManager.getCurrentICR(user1, recievePrice());
        console.log("getTroveTCR",getTroveTCR/1e16);//there is slight error up here ≈0.5%
    }

    function test_CCR() public {
        openTrove(user2, 40000e18, 2e18);
        openTrove(user3, 40000e18, 3e18);
        openTrove(user4, 40000e18, 4e18);
        uint CCR=TroveManager.CCR()/1e16;
        uint MCR=TroveManager.MCR()/1e16;
        uint btcPrice=recievePrice();
        bool mode =TroveManager.checkRecoveryMode(btcPrice);
        assertEq(mode, false);
        uint getTotalTCR=TroveManager.getTCR(btcPrice)/1e16;
        console.log("getTotalTCR",getTotalTCR);
        uint getEntireSystemDebt=TroveManager.getEntireSystemDebt();
        uint getEntireSystemColl=TroveManager.getEntireSystemColl();
        uint recModePrice=calculateLiquidationPrice(CCR, getEntireSystemDebt, getEntireSystemColl);
        updatePrice(recModePrice-1e18);
        btcPrice=recievePrice();
        mode =TroveManager.checkRecoveryMode(btcPrice);
        assertEq(mode, true);
    }

    function test_PriceFeedTest() public {
        uint btcPrice=recievePrice();
        console.log("btcPrice",btcPrice/1e18);

        address router=PriceFeed.priceRouter();
        assertEq(router, address(priceRouter));

        address oracle =priceRouter.priceOracle();
        assertEq(oracle, address(priceOracle));

        address priceOwner=priceOracle.owner();
        assertEq(priceOwner, ownerOracle);

        // address oracle=PriceRouter.priceOracle();
        // assertEq(oracle, address(priceOracle));

    }

    function test_Tokenomics() public {
        assertEq(IERC20(pdm).balanceOf(communityIssuance), depositorsAndFrontEndsEntitlement);
        assertEq(IERC20(pdm).balanceOf(unipool), _lpRewardsEntitlement);
        uint totalSupplyLQTY=IERC20(pdm).totalSupply();
        console.log("totalSupplyLQTY",totalSupplyLQTY);
        address multisig=token(pdm).multisigAddress();
        console.log("multisig",multisig);
        console.log("balace multisig",IERC20(pdm).balanceOf(multisig));
        vm.startPrank(multisig);
        vm.expectRevert();
        IERC20(pdm).transfer(user4, 40e18);
        vm.warp(block.timestamp+31536000);
        IERC20(pdm).transfer(user4, 40e18);
        
    }


    function test_Weth9() public {
        openTrove(user2, 40000e18, 2e18);
        openTrove(user3, 40000e18, 3e18);
        openTrove(user4, 40000e18, 4e18);
        vm.startPrank(user2);
        console.log("wbtc balance before",Wbtc.balanceOf(user2));
        //get wrappped btc
        Wbtc.deposit{ value: 1e17 }();
        console.log("wbtc balance after",Wbtc.balanceOf(user2));
        Wbtc.withdraw(5e16);
        console.log("wbtc balance after withdraw",Wbtc.balanceOf(user2));

        
    }

    function test_UniTokens() public {
        openTrove(user2, 40000e18, 2e18);
        openTrove(user3, 40000e18, 3e18);
        openTrove(user4, 40000e18, 4e18);
        vm.startPrank(user2);
        console.log("wbtc balance before",Wbtc.balanceOf(user2));
        //get wrappped btc
        Wbtc.deposit{ value: 1e17 }();
        console.log("wbtc balance after",Wbtc.balanceOf(user2));
        //get pair 
        address pair=UniswapV2Factory.getPair(wbtc, pusd);
        console.log("pair",pair);
        // address token0=IUniswapV2Pair(pair).token0();
        // console.log("token0",token0);
        //get lptotken by providing liquidity
        console.log("unitoken balance before",IUniswapV2Pair(pair).balanceOf(user2));
        Wbtc.approve(router, 1e17);
        IERC20(pusd).approve(router, 6000e18);
        UniswapV2Router.addLiquidity(wbtc, pusd, 1e17, 6000e18, 0, 0, user2, block.timestamp);
        console.log("unitoken balance after",IUniswapV2Pair(pair).balanceOf(user2));
        //try swapping
        address[] memory path=new address[](2);
        path[0]=pusd;
        path[1]=wbtc;
        console.log("wbtc balance before swap",Wbtc.balanceOf(user2));
        IERC20(pusd).approve(router, 600e18);
        UniswapV2Router.swapExactTokensForTokens(600e18, 0, path, user2, block.timestamp);
        console.log("wbtc balance after swap",Wbtc.balanceOf(user2));
    }

    function test_Unipool() public{
        openTrove(user2, 40000e18, 2e18);
        openTrove(user3, 40000e18, 3e18);
        openTrove(user4, 40000e18, 4e18);
        vm.startPrank(user2);
        Wbtc.deposit{ value: 1e17 }();
        Wbtc.approve(router, 1e17);
        IERC20(pusd).approve(router, 6000e18);
        UniswapV2Router.addLiquidity(wbtc, pusd, 1e17, 6000e18, 0, 0, user2, block.timestamp);
        uint256 unitokenBalance=IUniswapV2Pair(uniToken).balanceOf(user2);
        console.log("unitoken balance befor",unitokenBalance);
        IERC20(uniToken).approve(unipool, unitokenBalance);
        Unipool.stake(IUniswapV2Pair(uniToken).balanceOf(user2));
        unitokenBalance=IUniswapV2Pair(uniToken).balanceOf(user2);
        console.log("unitoken balance after",unitokenBalance);
        console.log("earned",Unipool.earned(user2));
        vm.warp(block.timestamp+30);
        console.log("earned",Unipool.earned(user2));

    }

    
    function test_PermitLUSD() public {
        // bytes32 DOMAIN_SEPARATOR=keccak256(abi.encode(keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"), "PUSD Stablecoin", "1",3636, 0x616Ec656451D163b1cEe9BB22Fb769C2f1534ffB));
        bytes32 DOMAIN_SEPARATOR=token(pusd).domainSeparator();
        sigUtils = new SigUtils(DOMAIN_SEPARATOR);
        openTrove(user2, 40000e18, 2e18);
        openTrove(user3, 40000e18, 3e18);
        openTrove(user4, 40000e18, 4e18);
        address ownerAc=0x150CC4F90516C23e64231D2B92d737893DBb2515;
        address spenderAc=0x29782e6eefef1255D1DDC2Bd1b4851B890614868;
        uint256 ownerNonce=token(pusd).nonces(ownerAc);
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: ownerAc,
            spender: spenderAc,
            value: 200e18,
            nonce: ownerNonce,
            deadline: 100000000000000
        });
        bytes32 digest = sigUtils.getTypedDataHash(permit);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerAcPvt, digest);
        token(pusd).permit(ownerAc, spenderAc, 200e18, 100000000000000, v, r, s);
        //transfer some pusd to owner
        vm.startPrank(user2);
        IERC20(pusd).transfer(ownerAc, 200e18);
        vm.stopPrank();
        //transfer some pusd on behalf of owner
        vm.startPrank(spenderAc);
        IERC20(pusd).transferFrom(ownerAc, user5, 100e18);
    }

    function test_PermitLQTY() public {
        // bytes32 DOMAIN_SEPARATOR=keccak256(abi.encode(keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"), "PUSD Stablecoin", "1",3636, 0x616Ec656451D163b1cEe9BB22Fb769C2f1534ffB));
        bytes32 DOMAIN_SEPARATOR=token(pdm).domainSeparator();
        sigUtils = new SigUtils(DOMAIN_SEPARATOR);
        openTrove(user2, 40000e18, 2e18);
        openTrove(user3, 40000e18, 3e18);
        openTrove(user4, 40000e18, 4e18);
        address ownerAc=0x150CC4F90516C23e64231D2B92d737893DBb2515;
        address spenderAc=0x29782e6eefef1255D1DDC2Bd1b4851B890614868;
        uint256 ownerNonce=token(pdm).nonces(ownerAc);
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: ownerAc,
            spender: spenderAc,
            value: 200e18,
            nonce: ownerNonce,
            deadline: 100000000000000
        });
        bytes32 digest = sigUtils.getTypedDataHash(permit);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerAcPvt, digest);
        token(pdm).permit(ownerAc, spenderAc, 200e18, 100000000000000, v, r, s);

        ///transfer some pdm to owner
        address multisig=token(pdm).multisigAddress();
        vm.warp(block.timestamp+31536000);
        vm.prank(multisig);
        IERC20(pdm).transfer(ownerAc, 200e18);
        vm.startPrank(spenderAc);
        IERC20(pdm).transferFrom(ownerAc, user5, 100e18);
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

    function recievePrice() public returns (uint) {
        uint price=priceRouter.getPrice();
        return price;
    }

    function updatePrice(uint price) public  {
        vm.prank(ownerOracle);
        priceOracle.setPrice(price);
    }

    function getPermitHash() public view returns(bytes32 ) {
        bytes32  PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
        return(PERMIT_TYPEHASH);
    }

    function getTypeHash() public view returns(bytes32 ) {
        bytes32  PERMIT_TYPEHASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
        return(PERMIT_TYPEHASH);
    }


    // function test_RedeemCollateralWithIssue() public {
    //     uint redeemAmount=2e18;
    //     uint collAmount=5e18;
    //     openTrove(user3, 4500e18,collAmount);
    //     vm.startPrank(user3);
    //     IERC20(pusd).transfer(user4, redeemAmount);
    //     vm.stopPrank();
    //     skip(1296000);
    //     // increaseDebt(currentTroveuser, 1e18);
    //     address currentTroveuser = SortedTroves.getLast();
    //     console.log("currentTroveuser",currentTroveuser);
    //     console.log("debt",TroveManager.getTroveDebt(currentTroveuser));
    //     console.log("coll",TroveManager.getTroveColl(currentTroveuser));
    //     ethusdprice=recievePrice();
    //      (
    //          firstRedemptionHint,
    //          partialRedemptionNewICR,
    //          truncatedpusdamount //Here truncatedpusdamount is max redeemable amount 
    //     ) = HintHelpers.getRedemptionHints(redeemAmount, ethusdprice, 50);
    //     console.log("truncatedpusdamount",truncatedpusdamount);
    //     console.log("firstRedemptionHint",firstRedemptionHint);
    //     uint numTroves = SortedTroves.getSize();
    //     uint numTrials = numTroves*15;
    //     (address hintAddress,,)=HintHelpers.getApproxHint(partialRedemptionNewICR, numTrials, 42);
    //     (address upperHint, address lowerHint ) =  SortedTroves.findInsertPosition(partialRedemptionNewICR,
    //     hintAddress,
    //     hintAddress);
    //     // user4=0x2a35B8729e238B56bD5D227b6371f0bB0c93E9a0;
    //     vm.startPrank(user4);
    //     console.log("pusd before",IERC20(pusd).balanceOf(user4));
    //     console.log("btc before",user4.balance);
    //     TroveManager.redeemCollateral(truncatedpusdamount,
    //     firstRedemptionHint,
    //     upperHint,
    //     lowerHint,
    //     partialRedemptionNewICR,
    //     0, /*maxFee */2e17);
    //     console.log("pusd after",IERC20(pusd).balanceOf(user4));
    //     console.log("btc after",user4.balance);

        
    // }

    // function increaseDebt(address user,uint amount) public {
    //     ( debt, coll,,) = TroveManager.getEntireDebtAndColl(user);
    //     uint newDebt=debt+amount;
    //     uint newColl=coll+0;
    //     uint NICR =( newColl*_1e20)/newDebt;
    //     uint numTroves = SortedTroves.getSize();
    //     uint numTrials = numTroves*15;
    //     uint maxFee = 5e16; // Slippage protection: 5%
    //     //hint helper not working on forked env , so directly assigning hint address in below  findInsertPosition  function .
    //     (address hintAddress,, )=HintHelpers.getApproxHint(NICR, numTrials, 42);
    //     (address upperHint,address  lowerHint ) = SortedTroves.findInsertPosition(NICR, hintAddress, hintAddress);
    //     console.log("pusd balance before adjust ",IERC20(pusd).balanceOf(user));
    //     vm.startPrank(user);
    //     BorrowerOperations.adjustTrove{ value: 0 }(maxFee, 0, amount, true, upperHint, lowerHint);
    //     console.log("pusd balance before adjust ",IERC20(pusd).balanceOf(user));

    // }

    // function increaseDebt

    

}