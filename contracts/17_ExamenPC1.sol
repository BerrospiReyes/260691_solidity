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

    constructor() {
        console.log("Ejecutado por: 260681 - HERNAN MAURICCIO GASTON BERROSPI REYES");
    }
}