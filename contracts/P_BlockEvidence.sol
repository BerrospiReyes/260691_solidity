// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract BlockEvidenceRegistro is AccessControl {

    bytes32 public constant PNP_ROLE =
        keccak256("PNP_ROLE");

    bytes32 public constant FISCALIA_ROLE =
        keccak256("FISCALIA_ROLE");

    bytes32 public constant LABORATORIO_ROLE =
        keccak256("LABORATORIO_ROLE");

    bytes32 public constant JUDICIAL_ROLE =
        keccak256("JUDICIAL_ROLE");

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

    function _validarCustodioActual(
        Evidencia storage evidencia
    )
        internal
        view
    {
        require(
            evidencia.custodioActual == msg.sender,
            "Solo el custodio actual puede actualizar"
        );
    }

    function _validarRolParaEstado(
        Estado nuevoEstado
    )
        internal
        view
    {
        if (nuevoEstado == Estado.Validada) {
            require(
                hasRole(FISCALIA_ROLE, msg.sender),
                "Para Validada debes tener rol FISCALIA"
            );
        } else if (
            nuevoEstado == Estado.EnAnalisis ||
            nuevoEstado == Estado.Analizada
        ) {
            require(
                hasRole(LABORATORIO_ROLE, msg.sender),
                "Para analisis debes tener rol LABORATORIO"
            );
        } else if (
            nuevoEstado == Estado.Presentada ||
            nuevoEstado == Estado.Cerrada
        ) {
            require(
                hasRole(JUDICIAL_ROLE, msg.sender),
                "Para etapa judicial debes tener rol JUDICIAL"
            );
        } else {
            revert("No se puede volver a Registrada");
        }
    }

    function _validarTransicionEstado(
        Estado estadoActual,
        Estado nuevoEstado
    )
        internal
        pure
    {
        bool permitida =
            (
                estadoActual == Estado.Registrada &&
                nuevoEstado == Estado.Validada
            ) ||
            (
                estadoActual == Estado.Validada &&
                nuevoEstado == Estado.EnAnalisis
            ) ||
            (
                estadoActual == Estado.EnAnalisis &&
                nuevoEstado == Estado.Analizada
            ) ||
            (
                estadoActual == Estado.Analizada &&
                nuevoEstado == Estado.Presentada
            ) ||
            (
                estadoActual == Estado.Presentada &&
                nuevoEstado == Estado.Cerrada
            );

        require(
            permitida,
            "Transicion de estado no permitida"
        );
    }

    function _validarNuevoCustodio(
        Estado estadoActual,
        address nuevoCustodio
    )
        internal
        view
    {
        if (estadoActual == Estado.Registrada) {
            require(
                hasRole(FISCALIA_ROLE, nuevoCustodio),
                "Nuevo custodio debe tener rol FISCALIA"
            );
        } else if (estadoActual == Estado.Validada) {
            require(
                hasRole(LABORATORIO_ROLE, nuevoCustodio),
                "Nuevo custodio debe tener rol LABORATORIO"
            );
        } else if (estadoActual == Estado.Analizada) {
            require(
                hasRole(JUDICIAL_ROLE, nuevoCustodio),
                "Nuevo custodio debe tener rol JUDICIAL"
            );
        } else {
            revert("No se puede transferir custodia en este estado");
        }
    }

    function registrarEvidencia(
        uint256 id,
        bytes32 hashArchivo,
        bytes32 idCasoHash,
        string calldata tipoArchivo,
        address custodioInicial
    )
        external
        onlyRole(PNP_ROLE)
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

        require(
            custodioInicial == msg.sender,
            "Custodio inicial debe ser la cuenta PNP"
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

        _validarCustodioActual(evidencia);

        require(
            evidencia.estado != nuevoEstado,
            "El estado ya es el indicado"
        );

        _validarRolParaEstado(nuevoEstado);
        _validarTransicionEstado(
            evidencia.estado,
            nuevoEstado
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

        _validarCustodioActual(evidencia);

        require(
            nuevoCustodio != address(0),
            "Custodio invalido"
        );

        require(
            evidencia.custodioActual != nuevoCustodio,
            "El custodio ya es el indicado"
        );

        _validarNuevoCustodio(
            evidencia.estado,
            nuevoCustodio
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
