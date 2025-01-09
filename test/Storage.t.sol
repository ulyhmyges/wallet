// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Storage} from "../src/Storage.sol";

contract WalletTest is Test {
    Storage public str;

    address public myAddr = address(0x99bdA7fd93A5c41Ea537182b37215567e832A726);
    function setUp() public {
        str = new Storage();
    }

    function test_retrieve() public {
        str.store(1);
        assertEq(str.retrieve(), 1);
    }

}