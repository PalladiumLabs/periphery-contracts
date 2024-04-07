// SPDX-License-Identifier: MIT

pragma solidity >0.6.11;

interface IPriceFeed {

    // --- Events ---
    event LastGoodPriceUpdated(uint _lastGoodPrice);
   
    // --- Function ---
    function fetchPrice() external returns (uint);
    function priceRouter() external returns (address);
    function setPrice(uint256 price) external returns (bool);
    function transferOwnership(address newOwner) external;
}