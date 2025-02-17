// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;



contract MockAggregator {
    int256 private _latestAnswer;
    uint8 private _decimals;
    uint80 private _roundId;

    constructor(int256 initialAnswer, uint8 decimals_, uint80 initialRoundId) {
        _latestAnswer = initialAnswer;
        _decimals = decimals_;
        _roundId = initialRoundId;
    }

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        return (_roundId, _latestAnswer, block.timestamp, block.timestamp, _roundId);
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function setLatestAnswer(int256 newAnswer) external {
        _latestAnswer = newAnswer;
    }

    function setRoundId(uint80 newRoundId) external {
        _roundId = newRoundId;
    }
}