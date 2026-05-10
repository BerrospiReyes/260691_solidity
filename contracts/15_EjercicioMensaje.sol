/* Ejercicio: Mensajes básicos con Solidity 
Implementar un contrato que permita al propietario del contrato enviar mensajes a otro usuario. Cada mensaje debe guardar: 
La dirección del remitente (from) //la misma 
La dirección del destinatario (to) 
El contenido del mensaje (contenido) 
La fecha y hora en que fue enviado (timestamp) //block.timestamp 
Cada vez que se envíe un mensaje: 
Debe guardarse en una estructura (struct) 
Debe emitirse un evento para dejar registro público en la blockchain
*/


// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

contract Mensajes {

    // Struct
    struct Mensaje {
        address from;
        address to;
        string contenido;
        uint timestamp;
    }

    Mensaje[] private mensajes;

    // Evento
    event MensajeEnviado(
        address from,
        address to,
        string contenido,
        uint timestamp
    );

    // Función para enviar mensaje
    function enviarMensaje(address _to, string memory _contenido) public {
        Mensaje memory nuevoMensaje = Mensaje(msg.sender, _to, _contenido,block.timestamp);

        mensajes.push(nuevoMensaje);

        emit MensajeEnviado(msg.sender, _to, _contenido,block.timestamp);
    }

    function obtenerMensajes() public view returns(Mensaje[] memory) {
        return mensajes;
    }
    
    function totalMensajes() public view returns(uint) {
        return mensajes.length;
    }
}