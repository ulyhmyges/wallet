// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

import {console} from "forge-std/Test.sol";

contract Wallet {
    address[] public owners;
    uint256 public constant minOwners = 3;
    uint256 public constant validatorsRequired = 2;
    uint256 public txID;


    struct Tx {
        address target;
        uint256 value;
        bytes data;
        address[] validators;
        bool executed;
    }

    mapping (uint256 txID => Tx tx) transactions;

    function execute(uint256 _txID) public onlyOwner returns (bytes memory){
        Tx memory transaction = transactions[_txID];
        address target = transaction.target;
        require(!transaction.executed, "Transaction executed");
        require(transaction.validators.length >= validatorsRequired, "Not enough validators");
        (bool success, bytes memory data) = target.call(transaction.data);
        require(success, "Call failed");
        transactions[_txID].executed = true;
        return data;
    }

    function validate(uint256 _txID) public onlyOwner {
        require(!isValidator(_txID), "Transaction already validated!");
        transactions[_txID].validators.push(msg.sender);
    }


    function submit(address _target, uint256 _value, bytes calldata _data) onlyOwner public returns(uint256) {
        txID += 1;
        address[] memory arr = new address[](1);
        arr[0] = msg.sender;
        transactions[txID] = createTx(_target, _value, _data, arr);
        return txID;
    }

    function createTx(address _target, uint256 _value, bytes calldata _data, address[] memory _validators) internal pure returns (Tx memory){
        return Tx({
            target: _target,
            value: _value, 
            data: _data, 
            validators: _validators, 
            executed: false
        });
    }

    function isValidator(uint256 _txID) internal view returns(bool) {
        bool isVal = false;
        Tx memory transaction = transactions[_txID];
        address[] memory validators = transaction.validators;
        for (uint256 i = 0; i < validators.length; ++i ){
            if (validators[i] == msg.sender){
                isVal = true;
                break;
            }
        }
        return isVal;
    }
    constructor(address owner1, address owner2, address owner3){
        owners.push(owner1);
        owners.push(owner2);
        owners.push(owner3);
        txID = 0;
    }
   
    function get(uint256 index) public view returns(address){
        return owners[index];
    }

    function getSize() public view returns(uint256){
        return owners.length;
    }

    /// return true if the user is an owner false otherwise
    /// @param user address
    function isOwner(address user) public view returns(bool){
        bool owner = false;
        for (uint256 i = 0; i < owners.length; ++i){
            if (owners[i] == user){
                owner = true;
            }
        }
        return owner;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "Not authorized");
        _;
    }

    /// Add an owner
    /// @param user owner's address
    function add(address user) public onlyOwner {
        bool added = false;
        for (uint256 index = 0; index < owners.length; ++ index){
            if (owners[index] == user){
                added = true;
            }
        }
        if (!added){
            owners.push(user);
        } 
    }

    /// Remove an owner
    /// @param user owner's address
    function remove(address user) public onlyOwner returns(bool) {
        bool isRemoved = false;
        uint256 index = 0;
        for (index; index < owners.length; ++index){
            if (owners[index] == user){
                address lastOwner = owners[owners.length - 1];
                owners[index] = lastOwner;
                owners.pop();
                isRemoved = true;
                break;
            }
        }
        return isRemoved;
    }
   
}