// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;
import {Script, console} from "forge-std/Script.sol";

import {Wallet } from "../src/Wallet.sol";

contract GoldScript is Script {
    Wallet public wallet;
    address public addr;

    function setUp() public {
        addr = address(vm.envAddress("WALLET_ADDRESS"));
        console.log("wallet: ", addr);
    }

    function run() public {
        //wallet = new Wallet();
    
    }

}