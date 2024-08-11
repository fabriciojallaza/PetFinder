// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract HelpetToken is ERC20, Ownable {
    address public rewardContract;

    constructor() ERC20("HelPet Token", "HPT") Ownable(msg.sender) {}

    function setRewardContract(address _rewardContract) external {
        rewardContract = _rewardContract;
    }

    function mint(address to, uint256 amount) external {
        require(msg.sender == rewardContract || msg.sender == owner(), "Not authorized");
        _mint(to, amount);
    }

    function burn(address to, uint256 amount) external {
        _burn(to, amount);
    }

    function transfer(address , uint256 ) public virtual override returns (bool) {
        require(false, "Transfers are disabled");
        return false;
    }

    function transferFrom(address , address , uint256 ) public virtual override returns (bool) {
        require(false, "Transfers are disabled");
        return false;
    }
}
