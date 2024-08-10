// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract UserRegistry {
    enum UserType { SingleUser, Entity }

    struct SingleUserDetails {
        string photo;
        string fullName;
        string ci; // CI stands for an identification number
        string addressDetails;
        string phoneNumber;
        bool verified;
    }

    struct EntityDetails {
        string name;
        string addressDetails;
        string personInChargeName;
        string personInChargeCI;
        string placePicsHash; // Store IPFS hash or similar
        string certificationDocHash; // Store IPFS hash or similar
        bool verified;
    }

    struct User {
        UserType userType;
        address userAddress;
        bool registered;
        // This will hold either SingleUserDetails or EntityDetails based on userType
        bytes details;
    }

    mapping(address => User) public users;

    event UserRegistered(address indexed userAddress, UserType userType);
    event UserVerified(address indexed userAddress, bool verified);

    function registerSingleUser(
        string memory _photo,
        string memory _fullName,
        string memory _ci,
        string memory _addressDetails,
        string memory _phoneNumber
    ) public {
        require(!users[msg.sender].registered, "User already registered");

        SingleUserDetails memory details = SingleUserDetails({
            photo: _photo,
            fullName: _fullName,
            ci: _ci,
            addressDetails: _addressDetails,
            phoneNumber: _phoneNumber,
            verified: false
        });

        users[msg.sender] = User({
            userType: UserType.SingleUser,
            userAddress: msg.sender,
            registered: true,
            details: abi.encode(details)
        });

        emit UserRegistered(msg.sender, UserType.SingleUser);
    }

    function registerEntity(
        string memory _name,
        string memory _addressDetails,
        string memory _personInChargeName,
        string memory _personInChargeCI,
        string memory _placePicsHash,
        string memory _certificationDocHash
    ) public {
        require(!users[msg.sender].registered, "User already registered");

        EntityDetails memory details = EntityDetails({
            name: _name,
            addressDetails: _addressDetails,
            personInChargeName: _personInChargeName,
            personInChargeCI: _personInChargeCI,
            placePicsHash: _placePicsHash,
            certificationDocHash: _certificationDocHash,
            verified: false
        });

        users[msg.sender] = User({
            userType: UserType.Entity,
            userAddress: msg.sender,
            registered: true,
            details: abi.encode(details)
        });

        emit UserRegistered(msg.sender, UserType.Entity);
    }

    function getUser(address _userAddress) public view returns (UserType, bytes memory) {
        require(users[_userAddress].registered, "User not registered");
        return (users[_userAddress].userType, users[_userAddress].details);
    }

    function getSingleUserDetails(address _userAddress) public view returns (SingleUserDetails memory) {
        require(users[_userAddress].registered, "User not registered");
        require(users[_userAddress].userType == UserType.SingleUser, "Not a SingleUser");
        return abi.decode(users[_userAddress].details, (SingleUserDetails));
    }

    function getEntityDetails(address _userAddress) public view returns (EntityDetails memory) {
        require(users[_userAddress].registered, "User not registered");
        require(users[_userAddress].userType == UserType.Entity, "Not an Entity");
        return abi.decode(users[_userAddress].details, (EntityDetails));
    }

    function verifyUser(address _userAddress, bool _verified) public {
        require(users[_userAddress].registered, "User not registered");
        User storage user = users[_userAddress];
        if (user.userType == UserType.SingleUser) {
            SingleUserDetails memory details = abi.decode(user.details, (SingleUserDetails));
            details.verified = _verified;
            user.details = abi.encode(details);
        } else {
            EntityDetails memory details = abi.decode(user.details, (EntityDetails));
            details.verified = _verified;
            user.details = abi.encode(details);
        }
        emit UserVerified(_userAddress, _verified);
    }

    function GetUserType() public view returns (UserType) {
        require(users[msg.sender].registered, "User not registered");
        return users[msg.sender].userType;
    }
}
