// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SingleUser.sol";

contract Entity is SingleUser {
    struct EntityDetails {
        string entityName;
        string entityAddress;
        string personInCharge;
        string certificateHash; // Store IPFS hash or similar
        string placePicsHash;   // Store IPFS hash or similar
        bool detailsComplete;
    }

    mapping(address => EntityDetails) public entityDetails;

    event EntityDetailsUpdated(address indexed userAddress, string entityName, string entityAddress, string personInCharge, string certificateHash, string placePicsHash);

    function registerEntity(
        string memory _name,
        string memory _email,
        string memory _entityName,
        string memory _entityAddress,
        string memory _personInCharge,
        string memory _certificateHash,
        string memory _placePicsHash
    ) public {
        registerUser(_name, _email);

        entityDetails[msg.sender] = EntityDetails({
            entityName: _entityName,
            entityAddress: _entityAddress,
            personInCharge: _personInCharge,
            certificateHash: _certificateHash,
            placePicsHash: _placePicsHash,
            detailsComplete: true
        });

        emit EntityDetailsUpdated(msg.sender, _entityName, _entityAddress, _personInCharge, _certificateHash, _placePicsHash);
    }

    function getEntityDetails(address _userAddress) public view returns (EntityDetails memory) {
        require(users[_userAddress].userType == UserType.Entity, "Not an Entity user");
        return entityDetails[_userAddress];
    }

    function UserRegistry() public view returns (UserType) {
        require(users[msg.sender].registered, "User not registered");
        return users[msg.sender].userType;
    }
}
