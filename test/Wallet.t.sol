// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Wallet} from "../src/Wallet.sol";
import {Storage} from "../src/Storage.sol";

contract WalletTest is Test {
    Wallet public wallet;
    Storage public str;
    address public constant USER1 = address(0x1);
    address public constant USER2 = address(0x02);
    address public USER = address(0x36);
    address public myAddr = address(0x99bdA7fd93A5c41Ea537182b37215567e832A726);
    function setUp() public {
        wallet = new Wallet(USER1, USER2, myAddr);
        str = new Storage();
    }

    function test_IsOwner() public view {
        assertEq(wallet.isOwner(USER1), true);
        assertEq(wallet.isOwner(USER2), true);
        assertEq(wallet.isOwner(myAddr), true);
    }

    function test_IsNotOwner() public view {
        assertEq(wallet.isOwner(USER), false);
    }

    function test_Get() public view {
        assertEq(wallet.get(0), USER1);
        assertEq(wallet.get(1), USER2);
        assertEq(wallet.get(2), myAddr);
    }

    function test_Size() public view {
        uint256 len = wallet.getSize();
        assertEq(len, 3);
    }

    function test_AddOwner() public {
        assertEq(wallet.getSize(), 3);
        vm.prank(myAddr);
        wallet.add(USER);
        assertEq(wallet.getSize(), 4);
    }

    function test_AddOwner_Failed() public {
        assertEq(wallet.getSize(), 3);
        vm.expectRevert("Not authorized");
        wallet.add(USER);
    }

    function test_AddOwnerAdded() public {
        assertEq(wallet.getSize(), 3);
        vm.prank(myAddr);
        wallet.add(myAddr);
        assertEq(wallet.getSize(), 3);
    }

    function test_AddOwnerAdded_Failed() public {
        assertEq(wallet.getSize(), 3);
        vm.expectRevert("Not authorized");
        wallet.add(myAddr);
    }

    function test_RemoveOwner() public {
        assertEq(wallet.getSize(), 3);
        vm.prank(myAddr);
        assertEq(wallet.remove(USER1), true);
        assertEq(wallet.getSize(), 2);
    }

    function test_RemoveOwner_Failed() public {
        assertEq(wallet.getSize(), 3);
        vm.expectRevert("Not authorized");
        assertEq(wallet.remove(USER1), false);
    }

    function test_RemoveOwnerRemoved() public {
        vm.startPrank(myAddr, myAddr);
        address user = wallet.get(1);
        assertEq(wallet.getSize(), 3);
        assertEq(wallet.remove(user), true);
        assertEq(wallet.getSize(), 2);
        assertEq(wallet.remove(user), false);
        assertEq(wallet.getSize(), 2);
        vm.stopPrank(); 
    }

    function test_RemoveOwnerRemoved_Failed() public {
        vm.startPrank(myAddr, myAddr);
        address user = wallet.get(1);
        assertEq(wallet.getSize(), 3);
        assertEq(wallet.remove(user), true);
        assertEq(wallet.getSize(), 2);
        vm.stopPrank(); 
        vm.expectRevert("Not authorized");
        assertEq(wallet.remove(user), false);
    }

    function test_Submit() public {
        bytes memory data = abi.encodeWithSignature("receive()");
        uint256 value = 0;
        vm.prank(myAddr);
        uint256 txID = wallet.submit(address(str), value, data);
        assertEq(txID, 1);
    }

    function test_Submit_Failed() public {
        bytes memory data = abi.encodeWithSignature("receive()");
        uint256 value = 0;
        vm.expectRevert("Not authorized");
        wallet.submit(address(str), value, data);
    }

    function test_Validate() public {
        str.store(2890);
        bytes memory data = abi.encodeWithSignature("retrieve()");
        uint256 value = 0;
        vm.prank(USER1);    // submit tx by an owner
        uint256 txID = wallet.submit(address(str), value, data);
        assertEq(txID, 1);

        // need an owner to validate tx
        vm.prank(myAddr);
        wallet.validate(txID);
    }

    function test_Validate_Failed() public {
        str.store(2890);
        bytes memory data = abi.encodeWithSignature("retrieve()");
        uint256 value = 0;
        vm.prank(USER1);    // submit tx by an owner
        uint256 txID = wallet.submit(address(str), value, data);
        assertEq(txID, 1);

        // need an owner to validate tx
        vm.expectRevert("Not authorized");
        wallet.validate(txID);
    }


    function test_ValidateExecutedTx() public {
        str.store(2890);
        bytes memory data = abi.encodeWithSignature("retrieve()");
        uint256 value = 0;
        vm.prank(USER1);    // submit tx by an owner
        uint256 txID = wallet.submit(address(str), value, data);
        assertEq(txID, 1);

        vm.startPrank(myAddr); // need 2 validations to execute a tx by an owner
        wallet.validate(txID);
        bytes memory return_data = wallet.execute(txID);
        assertEq(abi.encode(2890), return_data);
        vm.stopPrank();
        vm.prank(USER2);
        vm.expectRevert("Transaction already executed");
        wallet.validate(txID);
    }

   function test_Execute_RequireValidators_Failed() public {
        vm.startPrank(myAddr);
        bytes memory data = abi.encodeWithSignature("receive()");
        uint256 value = 0;
        uint256 txID = wallet.submit(address(str), value, data);
        assertEq(txID, 1);
        vm.expectRevert("Not enough validators");
        wallet.execute(txID);
        vm.stopPrank();
    }

    function test_Execute() public {
        str.store(2890);
        bytes memory data = abi.encodeWithSignature("retrieve()");
        uint256 value = 0;
        vm.prank(USER1);    // submit tx by an owner
        uint256 txID = wallet.submit(address(str), value, data);
        assertEq(txID, 1);

        vm.startPrank(myAddr); // need 2 validations to execute a tx by an owner
        wallet.validate(txID);
        bytes memory return_data = wallet.execute(txID);
        assertEq(abi.encode(2890), return_data);
        vm.stopPrank();
    }

    function test_Execute_Failed2() public {
        str.store(2890);
        bytes memory data = abi.encodeWithSignature("retrieve()");
        uint256 value = 0;
        vm.prank(USER1);    // submit tx by an owner
        uint256 txID = wallet.submit(address(str), value, data);
        assertEq(txID, 1);

        vm.prank(myAddr); // need 2 validations to execute a tx by an owner
        wallet.validate(txID);

        vm.expectRevert("Not authorized");
        wallet.execute(txID);
    }

    function test_RequireExecuted_Failed() public {
        vm.startPrank(myAddr);
        str.store(2890);
        bytes memory data = abi.encodeWithSignature("retrieve()");
        uint256 value = 0;
        uint256 txID = wallet.submit(address(str), value, data);
        assertEq(txID, 1);
        vm.stopPrank();

        // validate tx by an owner
        vm.prank(USER1);
        wallet.validate(txID);

        vm.startPrank(myAddr);
        bytes memory return_data = wallet.execute(txID);
        assertEq(abi.encode(2890), return_data);
        vm.expectRevert("Transaction already executed");
        wallet.execute(txID);    // try to execute a transaction second time
        vm.stopPrank();
    }

    function test_IsValidator_Failed() public {
        str.store(2890);
        bytes memory data = abi.encodeWithSignature("retrieve()");
        uint256 value = 0;
        vm.startPrank(USER1);    // submit tx by an owner
        uint256 txID = wallet.submit(address(str), value, data);
        assertEq(txID, 1);

        // need 2 validations to execute a tx by an owner
        vm.expectRevert("Transaction already validated!");
        wallet.validate(txID);
        vm.stopPrank();
    }

    function test_RequireCall_Failed() public {
        vm.startPrank(myAddr);
        str.store(2890);
        bytes memory data = abi.encodeWithSignature("do_not_exist_method()");
        uint256 value = 0;
        uint256 txID = wallet.submit(address(str), value, data);
        assertEq(txID, 1);
        vm.stopPrank();

        // validate tx by an owner and execute it
        vm.startPrank(USER1);
        wallet.validate(txID);

        vm.expectRevert("Call failed");
        wallet.execute(txID);   // execute tx
        vm.stopPrank();
    }
}