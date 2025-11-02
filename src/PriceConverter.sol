// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Import Chainlink’s AggregatorV3Interface to access live price feeds
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

/*
    🧠 Why a library?
    -----------------
    - A library is used here instead of a contract or interface because
      we only need helper functions — not a full deployable contract.
    - Libraries allow attaching functions directly to types (like uint256)
      using 'using PriceConverter for uint256', making the code cleaner.
    - Libraries are also cheaper because they don’t store any state.

    🧩 Why not abstract or interface?
    - Abstract contracts or interfaces define structure and must be inherited or implemented.
    - Libraries are better for pure/view logic (like math or conversions) that don’t need state.
*/

library PriceConverter {
    /*
        getPrice():
        -----------
        - Fetches the current ETH/USD price from a Chainlink Aggregator feed.
        - Chainlink returns prices with 8 decimals (e.g. 2000.00000000).
        - We multiply by 1e10 to convert it to 18 decimals for consistency with ETH (1 ETH = 1e18 wei).
    */
    function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        // Get latest price data from the Chainlink feed
        (, int256 answer,,,) = priceFeed.latestRoundData();

        // Convert returned price (8 decimals) to 18 decimals
        // Example: 2000.00000000 → 2000 * 1e10 = 2000000000000000000000
        return uint256(answer * 1e10);
    }

    /*
        getConversionRate():
        --------------------
        - Converts a given amount of ETH into its USD equivalent using the price feed.
        - Uses the getPrice() function above.
        - Example:
            If 1 ETH = $2000 and user sends 0.5 ETH:
            ethPrice = 2000 * 1e18
            ethAmount = 0.5 * 1e18
            Result = (2000 * 1e18 * 0.5 * 1e18) / 1e18 = 1000 * 1e18 USD
    */
    function getConversionRate(uint256 ethAmount, AggregatorV3Interface priceFeed) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed); // Get current ETH/USD price in 18 decimals
        // Multiply price by ETH amount, then divide by 1e18 to normalize decimals
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUsd; // Final USD value (in 18 decimals)
    }
}
