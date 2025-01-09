// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

contract Wallet {
    address[] public owners;
    uint256 public constant minOwners = 3;
    uint256 public constant validatorsRequired = 2;


    constructor(address owner1, address owner2, address owner3){
        owners.push(owner1);
        owners.push(owner2);
        owners.push(owner3);
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