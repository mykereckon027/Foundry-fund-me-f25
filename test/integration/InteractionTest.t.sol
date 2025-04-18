//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe} from "../../script/interactions.s.sol"; 
import {WithdrawFundMe} from "../../script/interactions.s.sol";

contract InteractionTest is Test {
     FundMe fundMe;

    address USER = makeAddr("user"); // Create a new address for testing
    uint256 constant SEND_VALUE = 1 ether; // Amount to send in tests
    uint256 constant STARTING_BALANCE = 10 ether; // Starting balance for the user
    uint256 constant GAS_PRICE = 1; // Gas price for the transaction

    function setUp () external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE); // Give the user some ether

    }

    function testUserCanFundInteraction() public { 
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundme(address(fundMe)); // Fund the contract
        
        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.WithdrawFundme(address(fundMe)); // Withdraw from the contract

        assert(address(fundMe).balance == 0); // Check if the contract balance is zero
}
}