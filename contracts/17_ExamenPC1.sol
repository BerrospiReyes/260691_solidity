// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "hardhat/console.sol";

contract Grimorio260681 {

    struct Tomo {
        uint256 id;
        string titulo;
        string autor;
        bool estado;
    }

    Tomo[] public tomos;

    address public dirContrato = 0xd9145CCE52D386f254917e481eB44e9943F39138;

    modifier registrarEjecucion() {
        console.log("Ejecutado por: 260681 - HERNAN MAURICCIO GASTON BERROSPI REYES"); _;
    }

    constructor() registrarEjecucion {
    }

    function agregarElemento(uint256 _id, string memory _titulo, string memory _autor) public registrarEjecucion {
        require(bytes(_titulo).length > 0, "El titulo no puede estar vacio");
        for (uint256 i = 0; i < tomos.length; i++) {
            require(tomos[i].id != _id, "Tomo con ese ID ya existe");
        }
        tomos.push(Tomo(_id, _titulo, _autor, true));
    }

    function inactivarElemento(uint _posicion) public registrarEjecucion {
        require(_posicion < tomos.length, "Posicion invalida");
        tomos[_posicion].estado = false;
    }

    function pintarElementosActivos() public view registrarEjecucion {
        for (uint256 i = 0; i < tomos.length; i++) {
            if (tomos[i].estado == true) {
                console.log("Tomo activo:", tomos[i].id, tomos[i].titulo);
            }
        }
    }

    function contarElementos() public view registrarEjecucion returns (uint256) {
        return tomos.length;
    }

}