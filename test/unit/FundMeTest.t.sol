//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user"); // Create a new address for testing
    uint256 constant SEND_VALUE = 1 ether; // Amount to send in tests

    function setUp() external {
        // fundMe = new FundMe(0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF); // Sepolia ETH/USD Address
        // https://docs.chain.link/data-feeds/price-feeds/addresses
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    function testifminimumUsdIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5 * 10 ** 18);
    }

    function testOwnerIsMsgSender() public {
        assertEq(fundMe.getowner(), msg.sender);
    }

    function testPriceFeedisAccutate() public {
        console.log("About to call getVersion...");
        uint256 version = fundMe.getVersion();
        console.log("Version is:", version);
        assertEq(version, 4); //chainlink price feed version is 6 for ethmainnet
            // assertEq(version, 4); // Chainlink price feed version is 4 for sepolia
    }

    function testFundFailWithoutEnoughEth() public {
        vm.expectRevert(); // hey, the next line should revert!
        fundMe.fund{value: (1e15)}(); // Call the fund function with 0.001 ETH
            // This should revert because 0.001 ETH is less than the minimum USD amount;
    }

    function testFundUpdatesAmountFundedDataStructure() public {
        console.log("Starting testFundUpdatesAmountFundedDataStructure");
        console.log("USER address:", USER);
        console.log("Sending value:", SEND_VALUE / 1e18, "ETH");

        vm.deal(USER, SEND_VALUE * 2); // Give user double what they need

        vm.prank(USER); // Pretend to be the user
        console.log("Before fund() call");
        fundMe.fund{value: SEND_VALUE}(); // Call the fund function with 10 ETH
        console.log("After fund() call");

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER); // Get the amount funded by this address
        console.log("Amount funded recorded:", amountFunded / 1e18, "ETH");
        assertEq(amountFunded, SEND_VALUE);
    } // Check if the amount funded is correct

    function testAddFundersToArrayOfFunders() public {
        vm.deal(USER, SEND_VALUE * 2); // Give user double what they need

        vm.prank(USER); // Pretend to be the user
        fundMe.fund{value: SEND_VALUE}(); // Call the fund function with 10 ETH

        address funder = fundMe.getFunder(0); // Get the first funder
        assertEq(funder, USER); // Check if the funder is the expected user
    }

    modifier funded() {
        vm.deal(USER, SEND_VALUE * 2);
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}(); // Call the fund function with SEND_VALUE
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER); // Pretend to be the user
        vm.expectRevert(); // Expect a revert when a non-owner tries to withdraw
        fundMe.withdraw();
    }

    function testWithdrawASingleFunder() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getowner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.prank(fundMe.getowner());
        fundMe.withdraw();

        // Assert
        uint256 endingOwnerBalance = fundMe.getowner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(endingOwnerBalance, startingOwnerBalance + startingFundMeBalance);
    }

    function testWithdrawMultipleFunders() public funded {
        uint160 numberoffunders = 10; // Number of funders to simulate
        uint160 startingfundersIndex = 1;
        for (uint160 i = startingfundersIndex; i < numberoffunders; i++) {
            hoax(address(i), SEND_VALUE); // Simulate a funder
            fundMe.fund{value: SEND_VALUE}(); // Call the fund function with SEND_VALUE
        }
        uint256 startingFundMeBalance = address(fundMe).balance; // Get the starting balance of the contract
        uint256 startingOwnerBalance = fundMe.getowner().balance; // Get the starting balance of the owner

        // Act
        vm.startPrank(fundMe.getowner()); // Pretend to be the owner
        fundMe.withdraw(); // Call the withdraw function
        vm.stopPrank(); // Stop pretending to be the owner

        // Assert
        assert(address(fundMe).balance == 0); // Check if the contract balance is 0
        assert(fundMe.getowner().balance == startingOwnerBalance + startingFundMeBalance); // Check if the owner's balance is correct
    }
     function testWithdrawMultipleFundersCheaper() public funded {
        uint160 numberoffunders = 10; // Number of funders to simulate
        uint160 startingfundersIndex = 1;
        for (uint160 i = startingfundersIndex; i < numberoffunders; i++) {
            hoax(address(i), SEND_VALUE); // Simulate a funder
            fundMe.fund{value: SEND_VALUE}(); // Call the fund function with SEND_VALUE
        }
        uint256 startingFundMeBalance = address(fundMe).balance; // Get the starting balance of the contract
        uint256 startingOwnerBalance = fundMe.getowner().balance; // Get the starting balance of the owner

        // Act
        vm.startPrank(fundMe.getowner()); // Pretend to be the owner
        fundMe.cheaperwithdraw(); // Call the withdraw function
        vm.stopPrank(); // Stop pretending to be the owner

        // Assert
        assert(address(fundMe).balance == 0); // Check if the contract balance is 0
        assert(fundMe.getowner().balance == startingOwnerBalance + startingFundMeBalance); // Check if the owner's balance is correct
    }
}
