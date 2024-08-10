// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.22;

contract Recompensa {
    uint monto;
    address owner;
    address payable ownerPayable;
    //address payable general=payable();
    struct Recompensa{
        address duenio;
    }
    constructor(uint _monto) {
        owner = msg.sender;
        ownerPayable=payable(msg.sender);
        monto=_monto;
        Recompensa memory r = Recompensa(owner );
        general.transfer(monto);
    }
    modifier onlyOwner{
        require(msg.sender==owner, "Only owner");
        _;
    }
    function encontrado(address x) public onlyOwner{
        address payable rescatista = payable(x);
        //llamar a una funcion para que se le pague
    }
    function cancelar() public onlyOwner{

    }
}
