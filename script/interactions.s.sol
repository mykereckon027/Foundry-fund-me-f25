//SPDX-License-Identifier:MIT

//Fund 
//withdraw

pragma solidity ^0.8.18;

import { console, Script} from "forge-std/Script.sol"; 
import {DevOpsTools} from "foundry-devops/DevOpsTools.sol";
import {FundMe} from "../../src/FundMe.sol";
contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.01 ether ;
    
    function fundFundme(address mostRecentlyDeployed) public {
        vm.startBroadcast();
         FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Funded FundMe contract with %s", SEND_VALUE);
    }

    function run ()external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        vm.startBroadcast();
        fundFundme(mostRecentlyDeployed);
        vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script {
    uint256 constant SEND_VALUE = 0.01 ether;

    function WithdrawFundme(address mostRecentlyDeployed) public {
        vm.startBroadcast();
         FundMe(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
    }
    
    function run ()external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        vm.startBroadcast();
        WithdrawFundme(mostRecentlyDeployed);
        vm.stopBroadcast();
    }

} 