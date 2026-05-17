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

    mapping(uint256 => Tomo) public tomos;
    uint256[] private ids;
    uint256 public cantidad = 0;

    address public dirContrato = 0xd9145CCE52D386f254917e481eB44e9943F39138;

    modifier registrarEjecucion() {
        console.log("Ejecutado por: 260681 - HERNAN MAURICCIO GASTON BERROSPI REYES"); _;
    }

    constructor() registrarEjecucion {
    }

    function agregarElemento(uint256 _id, string memory _titulo, string memory _autor) public registrarEjecucion {
        require(bytes(_titulo).length > 0, "El titulo no puede estar vacio");
        require(tomos[_id].id == 0, "Tomo con ese ID ya existe");

        tomos[_id] = Tomo(_id, _titulo, _autor, true);
        ids.push(_id);
        cantidad = cantidad + 1;
    }

    function inactivarElemento(uint256 _id) public registrarEjecucion {
        require(tomos[_id].id != 0, "Tomo no encontrado");
        tomos[_id].estado = false;
    }

    function pintarElementosActivos() public view registrarEjecucion {
        for (uint256 i = 0; i < ids.length; i++) {
            if (tomos[ids[i]].estado == true) {
                console.log("Tomo activo:", tomos[ids[i]].id, tomos[ids[i]].titulo);
            }
        }
    }

    function contarElementos() public view registrarEjecucion returns (uint256) {
        return cantidad;
    }

}