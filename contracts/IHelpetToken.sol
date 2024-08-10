// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract HelpetToken is ERC20, Ownable {
    constructor() ERC20("HelPet Token", "HPT") Ownable(msg.sender){}

    // Solo el owner puede mintear tokens
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    // Permite al usuario quemar sus propios tokens
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    // Sobreescribir la función transfer para deshabilitar la transferencia de tokens
    function transfer(address , uint256 ) public virtual override returns (bool) {
        require(false, "Transfers are disabled");
        return false;
    }

    // Sobreescribir la función transferFrom para deshabilitar la transferencia de tokens desde otra cuenta
    function transferFrom(address , address , uint256 ) public virtual override returns (bool) {
        require(false, "Transfers are disabled");
        return false;
    }
}