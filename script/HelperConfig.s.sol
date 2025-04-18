//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/Mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8; // Decimals for the price feed
    int256 public constant INITIAL_PRICE = 2000e8; // Initial price for the mock price feed

    // Struct to hold network configuration
    // This struct will be used to store the price feed address for different networks
    // The address of the price feed will be different for each network
    struct NetworkConfig {
        address priceFeed; // ETH/USD pricefeed address
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getsepoliaEthconfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getmainnetEthconfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthconfig();
        }
    }

    function getsepoliaEthconfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306 // Sepolia ETH/USD Address
        });
        return sepoliaConfig;
    }

    function getmainnetEthconfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory mainnetConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419 // ethmainnet ETH/USD Address
        });
        return mainnetConfig;
    }

    function getOrCreateAnvilEthconfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig; // Return the existing config if already set
        }
        //getpricefeed address from anvil
        // 1. Deploy the mock contract
        // 2. Get the address of the deployed contract
        // 3. Return the address
        vm.startBroadcast();
        MockV3Aggregator mockpricefeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockpricefeed) // Anvil ETH/USD Address
        });
        return anvilConfig;
    }
}
