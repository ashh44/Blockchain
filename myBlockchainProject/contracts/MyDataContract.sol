
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract MyContract is ChainlinkClient {
    using Chainlink for Chainlink.Request;

    // Chainlink Oracle and Job IDs for off-chain data
    address private oracle;
    bytes32 private jobId;
    uint256 private fee;

    // Other contract variables
    bool private isOnChain;
    string private onChainData;

    // Event to notify the result
    event QueryResult(string result);

    constructor(address _oracle, bytes32 _jobId, uint256 _fee) {
        // Initialize Chainlink variables
        setPublicChainlinkToken();
        oracle = _oracle;
        jobId = _jobId;
        fee = _fee;

        // Set other variables
        isOnChain = true; // Set to true for on-chain data initially
        onChainData = "Default On-Chain Data"; // Set default on-chain data
    }

    // Function to switch between on-chain and off-chain data retrieval
    function switchDataSource(bool _isOnChain) external {
        isOnChain = _isOnChain;
    }

    // Function to get data (either on-chain or off-chain)
    function getData() external {
        if (isOnChain) {
            getOnChainData();
        } else {
            getOffChainData();
        }
    }

    function getOnChainData() internal view {
    // For example, let's assume onChainData is a variable that holds a string
    string memory onChainDataResult = "This is on-chain data";

    // Emit the on-chain data result
    emit QueryResult(onChainDataResult);
}


    // Function to get off-chain data
    function getOffChainData() internal {
        // Create a Chainlink request
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);

        // Set the URL to fetch off-chain data (replace with your specific URL)
        string memory url = "https://api.example.com/eth-usd-price";

        // Add the HTTP GET method to the request
        request.add("method", "GET");

        // Add the URL to the request
        request.add("url", url);

        // Set the path in the API response JSON to extract the desired data (replace with your specific path)
        string memory path = "result";
        request.add("path", path);

        // Set the oracle payment amount
        // Set the oracle payment amount
        uint256 payment = 1 * 10**18; // 1 LINK (adjust as needed)
        request.add("payment", Strings.toString(payment));


        // Send the Chainlink request
        sendChainlinkRequestTo(oracle, request, fee);
    }

    // Chainlink callback function to process the off-chain data
    function fulfill(bytes32 _requestId, string memory _result) public recordChainlinkFulfillment(_requestId) {
        // Emit the off-chain data result
        emit QueryResult(_result);
    }
}
