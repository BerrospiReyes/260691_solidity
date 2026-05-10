// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

contract Animal {

    string public especie;

    constructor(string memory _especie) {
        especie = _especie;
    }

    function hacerSonido()
        public pure virtual returns(string memory) {
        return "aah";
    }

    function obtenerInfo() public view returns(string memory){
        return string.concat("Soy un ", especie);
    }
}

contract Perro is Animal {

    constructor() Animal("Perro") {

    }

    function hacerSonido() public pure override returns(string memory){
        return "guau";
    }
}