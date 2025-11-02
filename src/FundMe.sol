// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Import Chainlink price feed interface
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
// Import custom PriceConverter library
import {PriceConverter} from "./PriceConverter.sol";

contract FundMe {
    // Custom error to save gas instead of using require() with strings
    error FundMe__NotOwner();

    // Attach the PriceConverter library functions to uint256 type
    using PriceConverter for uint256;

    // Track how much ETH each address funded
    mapping(address => uint256) private s_addressToAmountFunded;
    // Keep an array of all funders
    address[] private s_funders;

    // The contract owner (set once when deployed)
    address private immutable i_owner;
    // Minimum USD amount (in 18 decimals) required to fund
    uint256 public immutable i_minimumUSD;
    // Chainlink price feed reference for ETH/USD
    AggregatorV3Interface private s_priceFeed;

    // Constructor runs once at deployment
    // Sets owner, price feed address, and minimum USD threshold
    constructor(address priceFeed, uint256 minimumUSD) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
        i_minimumUSD = minimumUSD;
    }

    // Main function that allows users to send ETH to the contract
    function fund() public payable {
        // Ensure the ETH sent is worth at least the minimum USD amount
        require(
            msg.value.getConversionRate(s_priceFeed) >= i_minimumUSD,
            "You need to spend more ETH!"
        );
        // Track how much each funder sent
        s_addressToAmountFunded[msg.sender] += msg.value;
        // Store funder address
        s_funders.push(msg.sender);
    }

    // Returns the version number of the Chainlink price feed
    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    // Restrict certain functions to only the contract owner
    modifier onlyOwner() {
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    // Optimized withdrawal function for owner to withdraw all funds
    function cheaperWithdraw() public payable onlyOwner {
        // Cache funders array in memory (saves gas)
        address[] memory funders = s_funders;

        // Loop through funders and reset their funding amount to 0
        for (uint256 i = 0; i < funders.length; i++) {
            address funder = funders[i];
            s_addressToAmountFunded[funder] = 0;
        }

        // Reset the funders array in storage
        s_funders = new address ;

        // Send all contract ETH balance to owner using call (recommended)
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
    }

    // Standard withdraw function (same logic, less optimized)
    function withdraw() public onlyOwner {
        for (uint256 i = 0; i < s_funders.length; i++) {
            address funder = s_funders[i];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address ;

        // Send all ETH to owner using call method
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
    }

    // Allow owner to change price feed (optional helper function)
    function setPriceFeed(address newFeed) external onlyOwner {
        require(newFeed != address(0), "Invalid address");
        s_priceFeed = AggregatorV3Interface(newFeed);
    }

    /*
        --- ETH Receiving Logic ---
        If someone sends ETH directly to the contract address:
        - If no data is attached → receive() is called
        - If data is attached → fallback() is called
        Both functions will call fund() internally to handle the contribution
    */

    // Handles plain ETH transfers with no data
    receive() external payable {
        fund();
    }

    // Handles ETH sent with data or calls to unknown functions
    fallback() external payable {
        fund();
    }

    /*
        --- View (Read-Only) Functions ---
        These do not modify blockchain state and can be called without gas cost
    */

    // Returns how much ETH a specific address has funded
    function getAddressToAmountFunded(address fundingAddress)
        external
        view
        returns (uint256)
    {
        return s_addressToAmountFunded[fundingAddress];
    }

    // Returns a funder address by index
    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    // Returns the contract owner address
    function getOwner() external view returns (address) {
        return i_owner;
    }
}
