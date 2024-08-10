// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SingleUser {
    enum UserType { SingleUser, Entity }

    struct User {
        UserType userType;
        address userAddress;
        string name;
        string email;
        bool registered;
    }

    mapping(address => User) public users;

    event UserRegistered(address indexed userAddress, UserType userType, string name, string email);

    function registerUser(string memory _name, string memory _email) public {
        require(!users[msg.sender].registered, "User already registered");

        users[msg.sender] = User({
            userType: UserType.SingleUser,
            userAddress: msg.sender,
            name: _name,
            email: _email,
            registered: true
        });

        emit UserRegistered(msg.sender, UserType.SingleUser, _name, _email);
    }

    function getUser(address _userAddress) public view returns (User memory) {
        require(users[_userAddress].registered, "User not registered");
        return users[_userAddress];
    }

    function UserRegistry() public view returns (UserType) {
        require(users[msg.sender].registered, "User not registered");
        return users[msg.sender].userType;
    }
}
