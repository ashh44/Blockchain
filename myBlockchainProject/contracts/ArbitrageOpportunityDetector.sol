// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract ArbitrageOpportunityDetector is ChainlinkClient {

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

    AggregatorV3Interface private ethUsdAggregator;

    mapping(string => address) public cryptoPrice;

    bool private isOnChain;
    string private onChainData;

    event ArbitrageOpportunity(string result);

    constructor(address _ethUsdAggregator) {
        ethUsdAggregator = AggregatorV3Interface(_ethUsdAggregator);
        isOnChain = true;
        onChainData = "Default On-Chain Data";

        // Initialize cryptoPrice mapping
        cryptoPrice["BTC / ETH"] = 0x5fb1616F78dA7aFC9FF79e0371741a747D2a7F22;
        cryptoPrice["BTC / USD"] = 0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43;
        cryptoPrice["CZK / USD"] = 0xC32f0A9D70A34B9E7377C10FDAd88512596f61EA;
        cryptoPrice["DAI / USD"] = 0x14866185B1962B63C3Ea9E03Bc1da838bab34C19;
        cryptoPrice["ETH / USD"] = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
        cryptoPrice["EUR / USD"] = 0x1a81afB8146aeFfCFc5E50e8479e826E7D55b910;
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
        // Your logic for fetching on-chain data goes here
        // Example: Fetch data from the cryptoPrice mapping
        address btcEthPriceOracle = cryptoPrice["BTC / ETH"];
        
        // Perform additional logic as needed based on the oracle address
        // For illustration, let's assume there's a function to get the latest price from the oracle
        uint256 btcEthPrice = getPriceFromOracle(btcEthPriceOracle);

        // Use abi.encodePacked to concatenate the strings
        return string(abi.encodePacked("On-chain data: BTC/ETH Price - ", integerToString(btcEthPrice)));
    }

    function getPriceFromOracle(address oracleAddress) internal view returns (uint256) {
        // Assuming oracleAddress is an AggregatorV3Interface contract address
        AggregatorV3Interface oracle = AggregatorV3Interface(oracleAddress);

        // Get the latest round data from the oracle
        (, int256 latestPrice, , , ) = oracle.latestRoundData();

        // Check if the latest price is valid (not negative)
        require(latestPrice > 0, "Invalid price from oracle");

        // Convert int256 to uint256
        uint256 price = uint256(latestPrice);

        return price;
    }

    function getOffChainData() internal view returns (string memory) {
        // Fetch ETH/USD price from Chainlink
        (, int256 ethUsdPrice, , , ) = ethUsdAggregator.latestRoundData();

        // Convert int256 to string directly in the function
        uint256 value = uint256(ethUsdPrice);

        if (value == 0) {
            return "0";
        } else {
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

            // Used abi.encodePacked to concatenate the strings
            return string(abi.encodePacked("Off-chain data: ETH/USD Price - ", string(result)));
        }
    }

    function addressToString(address _addr) internal pure returns (string memory) {
        bytes32 hexAlphabet = "0123456789abcdef";
        bytes memory s = new bytes(40);

        uint256 addrValue = uint256(uint160(_addr)); // Cast to uint160 to get the correct size

        for (uint256 i = 0; i < 20; i++) {
            s[i * 2] = hexAlphabet[uint8(addrValue / (2**(8 * (19 - i)))) % 16];
            s[i * 2 + 1] = hexAlphabet[uint8(addrValue / (2**(8 * (18 - i)))) % 16];
        }

        return string(s);
    }
}
