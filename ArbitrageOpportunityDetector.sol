// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

// Import Chainlink Aggregator interface
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract ArbitrageOpportunityDetector is ChainlinkClient {
    AggregatorV3Interface private ethUsdAggregator;

    bool private isOnChain;
    string private onChainData;
    string private offChainData;

    event ArbitrageOpportunity(string result);

    constructor(address _ethUsdAggregator) {
        ethUsdAggregator = AggregatorV3Interface(_ethUsdAggregator);
        isOnChain = true;
        onChainData = "Default On-Chain Data";
    }

    function switchDataSource(bool _isOnChain) external {
        isOnChain = _isOnChain;
    }

    function detectArbitrageOpportunity() external {
        string memory result;
        if (isOnChain) {
            result = getOnChainData();
        } else {
            result = getOffChainData();
        }

        emit ArbitrageOpportunity(result);
    }

    function getOnChainData() internal view returns (string memory) {
        return onChainData;
    }

    function getOffChainData() internal view returns (string memory) {
        // Fetch ETH/USD price from Chainlink
        (, int256 ethUsdPrice, , , ) = ethUsdAggregator.latestRoundData();
        offChainData = integerToString(uint256(ethUsdPrice));
        return offChainData;
    }

    // Helper function: Converts integers to strings
    function integerToString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }

        uint256 temp = value;
        uint256 length;

        while (temp > 0) {
            temp /= 10;
            length++;
        }

        bytes memory result = new bytes(length);
        uint256 i = length - 1;
        temp = value;

        while (temp > 0) {
            result[i--] = bytes1(uint8(48 + temp % 10));
            temp /= 10;
        }

        return string(result);
    }
}
