// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract BlockEvidenceRegistro is AccessControl {

    bytes32 public constant REGISTRADOR_ROLE =
        keccak256("REGISTRADOR_ROLE");

    bytes32 public constant VALIDADOR_ROLE =
        keccak256("VALIDADOR_ROLE");

    uint256 public constant MAX_EVIDENCIAS = 1000;

    uint256 public totalEvidencias;

    enum Estado {
        Registrada,
        Validada,
        EnAnalisis,
        Analizada,
        Presentada,
        Cerrada
    }

    struct Evidencia {
        uint256 id;
        bytes32 hashArchivo;
        bytes32 idCasoHash;
        string tipoArchivo;
        address custodioActual;
        Estado estado;
        uint256 fechaRegistro;
        bool existe;
    }

    mapping(uint256 => Evidencia) private evidencias;

    event EvidenciaRegistrada(
        uint256 indexed id,
        bytes32 indexed idCasoHash,
        bytes32 hashArchivo,
        address indexed custodioInicial,
        address registrador,
        string tipoArchivo,
        uint256 fecha
    );

    event EstadoActualizado(
        uint256 indexed id,
        Estado estadoAnterior,
        Estado nuevoEstado,
        address indexed actor,
        uint256 fecha
    );

    event CustodiaActualizada(
        uint256 indexed id,
        address indexed custodioAnterior,
        address indexed nuevoCustodio,
        address actor,
        uint256 fecha
    );

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function registrarEvidencia(
        uint256 id,
        bytes32 hashArchivo,
        bytes32 idCasoHash,
        string calldata tipoArchivo,
        address custodioInicial
    )
        external
        onlyRole(REGISTRADOR_ROLE)
    {
        require(
            totalEvidencias < MAX_EVIDENCIAS,
            "Se alcanzo el limite de 1000 evidencias"
        );

        require(
            id > 0,
            "El ID debe ser mayor que cero"
        );

        require(
            id <= MAX_EVIDENCIAS,
            "El ID no puede superar 1000"
        );

        require(
            !evidencias[id].existe,
            "Evidencia ya registrada"
        );

        require(
            hashArchivo != bytes32(0),
            "Hash de archivo invalido"
        );

        require(
            idCasoHash != bytes32(0),
            "Hash de caso invalido"
        );

        require(
            bytes(tipoArchivo).length > 0,
            "Tipo de archivo obligatorio"
        );

        require(
            custodioInicial != address(0),
            "Custodio invalido"
        );

        evidencias[id] = Evidencia({
            id: id,
            hashArchivo: hashArchivo,
            idCasoHash: idCasoHash,
            tipoArchivo: tipoArchivo,
            custodioActual: custodioInicial,
            estado: Estado.Registrada,
            fechaRegistro: block.timestamp,
            existe: true
        });

        totalEvidencias++;

        emit EvidenciaRegistrada(
            id,
            idCasoHash,
            hashArchivo,
            custodioInicial,
            msg.sender,
            tipoArchivo,
            block.timestamp
        );
    }

    function actualizarEstado(
        uint256 id,
        Estado nuevoEstado
    )
        external
        onlyRole(VALIDADOR_ROLE)
    {
        require(
            id > 0 && id <= MAX_EVIDENCIAS,
            "ID fuera de rango"
        );

        Evidencia storage evidencia = evidencias[id];

        require(
            evidencia.existe,
            "Evidencia inexistente"
        );

        require(
            evidencia.estado != nuevoEstado,
            "El estado ya es el indicado"
        );

        Estado anterior = evidencia.estado;

        evidencia.estado = nuevoEstado;

        emit EstadoActualizado(
            id,
            anterior,
            nuevoEstado,
            msg.sender,
            block.timestamp
        );
    }

    function actualizarCustodia(
        uint256 id,
        address nuevoCustodio
    )
        external
        onlyRole(VALIDADOR_ROLE)
    {
        require(
            id > 0 && id <= MAX_EVIDENCIAS,
            "ID fuera de rango"
        );

        Evidencia storage evidencia = evidencias[id];

        require(
            evidencia.existe,
            "Evidencia inexistente"
        );

        require(
            nuevoCustodio != address(0),
            "Custodio invalido"
        );

        require(
            evidencia.custodioActual != nuevoCustodio,
            "El custodio ya es el indicado"
        );

        address anterior = evidencia.custodioActual;

        evidencia.custodioActual = nuevoCustodio;

        emit CustodiaActualizada(
            id,
            anterior,
            nuevoCustodio,
            msg.sender,
            block.timestamp
        );
    }

    function obtenerEvidencia(
        uint256 id
    )
        external
        view
        returns (Evidencia memory)
    {
        require(
            id > 0 && id <= MAX_EVIDENCIAS,
            "ID fuera de rango"
        );

        require(
            evidencias[id].existe,
            "Evidencia inexistente"
        );

        return evidencias[id];
    }

    function existeEvidencia(
        uint256 id
    )
        external
        view
        returns (bool)
    {
        if (
            id == 0 ||
            id > MAX_EVIDENCIAS
        ) {
            return false;
        }

        return evidencias[id].existe;
    }
}
