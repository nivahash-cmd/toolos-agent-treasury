// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Script} from "forge-std/Script.sol";
import {AgentTreasury} from "../src/AgentTreasury.sol";
contract DeployAgentTreasury is Script {
 address constant ARC_USDC=0x3600000000000000000000000000000000000000;
 function run() external returns(AgentTreasury treasury){vm.startBroadcast();treasury=new AgentTreasury(ARC_USDC);vm.stopBroadcast();}
}
