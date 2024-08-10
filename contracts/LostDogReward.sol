// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Register {
    address private owner;

    struct Person {
        string name;
        uint256 age;
        string addressPhysical;
        string phone;
        string ci;
        string photo;
        string idCardPhoto;
        bool isVerified;
    }

    struct Entity {
        string name;
        string addressPhysical;
        string responsiblePerson;
        string phone;
        string ciResponsible;
        string photo;
        string idCardPhoto;
        string placePhoto;
        address walletAddress;
        bool isVerified;
    }

    mapping(address => Person) private persons;
    mapping(address => Entity) private entities;
    mapping(address => bool) private permissionedUsers;

    event PersonRegistered(address indexed walletAddress, string name);
    event EntityRegistered(address indexed walletAddress, string name);
    event PersonVerified(address indexed walletAddress);
    event EntityVerified(address indexed walletAddress);
    event PermissionGranted(address indexed grantedTo);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    modifier onlyPermissioned() {
        require(permissionedUsers[msg.sender] || msg.sender == owner, "Not authorized");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function registerPerson(
        string memory _name,
        uint256 _age,
        string memory _addressPhysical,
        string memory _phone,
        string memory _ci,
        string memory _photo,
        string memory _idCardPhoto
    ) public {
        persons[msg.sender] = Person({
            name: _name,
            age: _age,
            addressPhysical: _addressPhysical,
            phone: _phone,
            ci: _ci,
            photo: _photo,
            idCardPhoto: _idCardPhoto,
            isVerified: false
        });

        emit PersonRegistered(msg.sender, _name);
    }

    function registerEntity(
        string memory _name,
        string memory _addressPhysical,
        string memory _responsiblePerson,
        string memory _phone,
        string memory _ciResponsible,
        string memory _photo,
        string memory _idCardPhoto,
        string memory _placePhoto,
        address _walletAddress
    ) public {
        entities[_walletAddress] = Entity({
            name: _name,
            addressPhysical: _addressPhysical,
            responsiblePerson: _responsiblePerson,
            phone: _phone,
            ciResponsible: _ciResponsible,
            photo: _photo,
            idCardPhoto: _idCardPhoto,
            placePhoto: _placePhoto,
            walletAddress: _walletAddress,
            isVerified: false
        });

        emit EntityRegistered(_walletAddress, _name);
    }

    function isPersonRegistered(address _walletAddress) public view returns (bool, bool) {
        Person memory person = persons[_walletAddress];
        return (bytes(person.name).length > 0, person.isVerified);
    }

    function isEntityRegistered(address _walletAddress) public view returns (bool, bool) {
        Entity memory entity = entities[_walletAddress];
        return (bytes(entity.name).length > 0, entity.isVerified);
    }

    function verifyPerson(address _walletAddress) public onlyPermissioned {
        require(bytes(persons[_walletAddress].name).length > 0, "Person not registered");
        persons[_walletAddress].isVerified = true;

        emit PersonVerified(_walletAddress);
    }

    function verifyEntity(address _walletAddress) public onlyPermissioned {
        require(bytes(entities[_walletAddress].name).length > 0, "Entity not registered");
        entities[_walletAddress].isVerified = true;

        emit EntityVerified(_walletAddress);
    }

    function revokePersonVerification(address _walletAddress) public onlyPermissioned {
        require(bytes(persons[_walletAddress].name).length > 0, "Person not registered");
        persons[_walletAddress].isVerified = false;
    }

    function revokeEntityVerification(address _walletAddress) public onlyPermissioned {
        require(bytes(entities[_walletAddress].name).length > 0, "Entity not registered");
        entities[_walletAddress].isVerified = false;
    }

    function grantPermission(address _user) public onlyOwner {
        permissionedUsers[_user] = true;

        emit PermissionGranted(_user);
    }

    function revokePermission(address _user) public onlyOwner {
        permissionedUsers[_user] = false;
    }
}