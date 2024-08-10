// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./MyToken_HelPet.sol";

contract HelPetApadrinar {
    address public owner;
    HelpetToken public helpetToken; // Dirección del contrato del token HPT
    uint256 public donationTokenPercentage; // Porcentaje de tokens HPT por donación

    struct Animal {
        uint id;
        string name;
        string description;
        uint fundsNeeded;
        uint fundsRaised;
        address payable caretaker;
    }

    uint public animalCount;
    mapping(uint => Animal) public animals;

    event DonationReceived(uint indexed animalId, address indexed donor, uint amount);
    event AnimalAdded(uint indexed animalId, string name, string description, uint fundsNeeded);

    modifier onlyOwner() {
        require(msg.sender == owner, "Solo el propietario puede ejecutar esta funcion");
        _;
    }

    constructor(address _tokenAddress, uint256 _donationTokenPercentage) {
        owner = msg.sender;
        helpetToken = HelpetToken(_tokenAddress);
        donationTokenPercentage = _donationTokenPercentage;
    }

    function addAnimal(string memory _name, string memory _description, uint _fundsNeeded, address payable _caretaker) public onlyOwner {
        animalCount++;
        animals[animalCount] = Animal(animalCount, _name, _description, _fundsNeeded, 0, _caretaker);
        emit AnimalAdded(animalCount, _name, _description, _fundsNeeded);
    }

    function donate(uint _animalId) public payable {
        Animal storage animal = animals[_animalId];
        require(animal.id > 0, "El animal no existe");
        require(animal.fundsRaised < animal.fundsNeeded, "Este animal ya ha recibido los fondos necesarios");
        
        animal.fundsRaised += msg.value;
        animal.caretaker.transfer(msg.value);
        
        // Recompensa con tokens HPT basado en un porcentaje de la donación
        uint256 tokenAmount = (msg.value * donationTokenPercentage) / 100;
        helpetToken.mint(msg.sender, tokenAmount);

        emit DonationReceived(_animalId, msg.sender, msg.value);
    }

    function getAnimal(uint _animalId) public view returns (string memory, string memory, uint, uint, address) {
        Animal storage animal = animals[_animalId];
        return (animal.name, animal.description, animal.fundsNeeded, animal.fundsRaised, animal.caretaker);
    }
}
