// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "hardhat/console.sol";

contract Grimorio260681 {

    struct Tomo {
        uint256 id;
        string titulo;
        string autor;
    }

    Tomo[] public tomos;

    address public dirContrato = 0xd9145CCE52D386f254917e481eB44e9943F39138;

    constructor() {
        console.log("Ejecutado por: 260681 - HERNAN MAURICCIO GASTON BERROSPI REYES");
    }

    function agregarElemento(uint256 _id, string memory _titulo, string memory _autor) public {
        tomos.push(Tomo(_id, _titulo, _autor));
    }

    function contarElementos() public view returns (uint256) {
        console.log("Ejecutado por: 260681 - HERNAN MAURICCIO GASTON BERROSPI REYES");
        return tomos.length;
    }

}