// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IHelpetToken.sol";

contract Canjear {
    HelpetToken private helPetToken;
    address private owner;

    struct Item {
        string name;
        uint256 stock;
        uint256 cost;
    }

    uint256 private nextItemId = 0;
    mapping(uint256 => Item) private items;

    event ItemAdded(uint256 indexed itemId, string name, uint256 stock, uint256 cost);
    event ItemRedeemed(uint256 indexed itemId, address indexed redeemer, uint256 cost);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor() {
        helPetToken = HelpetToken(0x540d7E428D5207B30EE03F2551Cbb5751D3c7569);
        owner = msg.sender;
    }

    function addItem(string memory _name, uint256 _stock, uint256 _cost) public onlyOwner {
        uint256 itemId = nextItemId++;
        items[itemId] = Item({
            name: _name,
            stock: _stock,
            cost: _cost
        });

        emit ItemAdded(itemId, _name, _stock, _cost);
    }

    function redeemItem(uint256 _itemId) public {
        Item storage item = items[_itemId];
        require(item.stock > 0, "Item out of stock");
        require(helPetToken.balanceOf(msg.sender) >= item.cost, "Insufficient HelPet tokens");

        helPetToken.burn(msg.sender, item.cost);

        item.stock -= 1;

        emit ItemRedeemed(_itemId, msg.sender, item.cost);
    }

    function getItem(uint256 _itemId) public view returns (string memory name, uint256 stock, uint256 cost) {
        Item storage item = items[_itemId];
        return (item.name, item.stock, item.cost);
    }
}