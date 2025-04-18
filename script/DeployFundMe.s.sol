//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        // be4 startBroadcast => not a real txn
        HelperConfig helperConfig = new HelperConfig();
        // after startBroadcast => real txn

        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();
        // address ethUsdPriceFeed = 0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF; // Sepolia ETH/USD Address

        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethUsdPriceFeed); // Sepolia ETH/USD Address
        // https://docs.chain.link/data-feeds/price-feeds/addresses
        vm.stopBroadcast();
        return fundMe;
    }
}
