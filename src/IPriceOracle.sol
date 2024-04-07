pragma solidity ^0.8.4;

interface IPriceOracle {
    function getLatestAnswer() external view returns (uint);
    function getDecimals() external view returns (uint);
}