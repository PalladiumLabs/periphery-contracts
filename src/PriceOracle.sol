pragma solidity ^0.8.4;
import "@openzeppelin/access/Ownable2Step.sol";

/*This contract will have two main funcitons 
1. getLatestAnswer
2. getDecimals
*/
contract PriceOracle is  Ownable2Step {

    uint256 private _price;
    uint constant public DIGITS = 18;

    constructor (
        uint256 initPRice
    ) {
        _price = initPRice;
    }

    function getLatestAnswer() public view returns(uint) {
        return _price;
    }

    function getDecimals() public pure returns(uint){
        return DIGITS;
    }

    // Manual external price setter.
    function setPrice(uint256 price) external onlyOwner returns (bool) {
        _price = price;
        return true;
    }
}

