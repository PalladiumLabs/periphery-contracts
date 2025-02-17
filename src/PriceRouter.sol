pragma solidity ^0.8.4;
import "./IPriceOracle.sol";
import "@openzeppelin/utils/math/SafeMath.sol";
import "@openzeppelin/access/Ownable2Step.sol";

/*This contract fetches price and decimals from the Price ORacle
It is an upgradable contract ans priceOracle address can be updated
*/
contract PriceRouter is Ownable2Step {
    using SafeMath for uint256;

    event UpgradeOracle(address implementation);

    uint constant public TARGET_DIGITS = 18; 
    address public priceOracle;

    constructor (
        address priceOracle_
    ) {
        priceOracle = priceOracle_;
    }

    function getPrice() public view returns (uint) {
        uint decimals =IPriceOracle(priceOracle).getDecimals();
        uint price =IPriceOracle(priceOracle).getLatestAnswer();
        return _scaleChainlinkPriceByDigits(price,decimals);
    }

    function _scaleChainlinkPriceByDigits(uint _price, uint _answerDigits) internal pure returns (uint) {
        /*
        * Convert the price returned by the Chainlink oracle to an 18-digit decimal for use by Liquity.
        * At date of Liquity launch, Chainlink uses an 8-digit price, but we also handle the possibility of
        * future changes.
        *
        */
        uint price;
        if (_answerDigits >= TARGET_DIGITS) {
            // Scale the returned price value down to Liquity's target precision
            price = _price.div(10 ** (_answerDigits - TARGET_DIGITS));
        }
        else if (_answerDigits < TARGET_DIGITS) {
            // Scale the returned price value up to Liquity's target precision
            price = _price.mul(10 ** (TARGET_DIGITS - _answerDigits));
        }
        return price;
    }


    function upgradeOracle(address _implementation) public onlyOwner { //Only owner can update oracle
        priceOracle=_implementation;
        emit UpgradeOracle(_implementation);
    }
}