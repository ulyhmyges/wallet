// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Wallet} from "../src/Wallet.sol";

contract WalletTest is Test {
    Wallet public wallet;
    address public constant USER1 = address(0x1);
    address public constant USER2 = address(0x02);
    address public constant USER3 = address(0x03);
    address public USER = address(0x36);
    function setUp() public {
        wallet = new Wallet(USER1, USER2, USER3);
    }

    function test_IsOwner() public view {
        assertEq(wallet.isOwner(USER1), true);
        assertEq(wallet.isOwner(USER2), true);
        assertEq(wallet.isOwner(USER3), true);
    }

    function test_IsNotOwner() public view {
        assertEq(wallet.isOwner(USER), false);
    }

    function test_Get() public view {
        assertEq(wallet.get(0), USER1);
        assertEq(wallet.get(1), USER2);
        assertEq(wallet.get(2), USER3);
    }

    function test_Size() public view {
        uint256 len = wallet.getSize();
        assertEq(len, 3);
    }

    function test_AddOwner() public {
        assertEq(wallet.getSize(), 3);
        wallet.add(USER);
        assertEq(wallet.getSize(), 4);
    }

    function test_AddOwnerAdded() public {
        assertEq(wallet.getSize(), 3);
        wallet.add(USER3);
        assertEq(wallet.getSize(), 3);
    }


    function test_RemoveOwner() public {
        assertEq(wallet.getSize(), 3);
        assertEq(wallet.remove(wallet.get(2)), true);
        assertEq(wallet.getSize(), 2);
    }


    function test_RemoveOwnerRemoved() public {
        address user = wallet.get(2);
        assertEq(wallet.getSize(), 3);
     
        assertEq(wallet.remove(user), true);
        assertEq(wallet.getSize(), 2);

        assertEq(wallet.remove(user), false);
        assertEq(wallet.getSize(), 2);
        
    }
}