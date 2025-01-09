// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

contract Wallet {
    address[] public owners;
    uint256 public constant minOwners = 3;
    uint256 public constant validatorsRequired = 2;
    uint256 public txID;


    struct Tx {
        address target;
        uint256 value;
        bytes data;
        uint256 validators;
    }

    mapping (uint256 txID => Tx tx) transactions;

    function submit(address _target, uint256 _value, bytes calldata _data) public returns(uint256) {
        txID += 1;
        transactions[txID] = Tx({target: _target, value: _value, data: _data, validators: 1});
        return txID;
    }

    function execute(uint256 _txID) public returns (bytes memory){
        Tx memory transaction = transactions[_txID];
        address target = transaction.target;
        (bool success, bytes memory data) = target.call{value: transaction.value}(transaction.data);
        require(transaction.validators >= validatorsRequired, "Not enough validators");
        require(success, "Transaction did not execute");
        return data;
    }

    function validate(uint256 _txID) public view {
        Tx memory transaction = transactions[_txID];
        transaction.validators += 1;
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
    function add(address user) public {
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
    function remove(address user) public returns(bool) {
        bool isRemoved = false;
        uint256 index = 0;
        for (index; index < owners.length; ++index){
            if (owners[index] == user){
                delete owners[index];
                isRemoved = true;
                break;
            }
        }
        if (isRemoved){
            for (uint256 j = index; j < owners.length - 1; ++j){
                owners[j] == owners[j+1];
            }
            owners.pop();
        }
        return isRemoved;
    }
   
}