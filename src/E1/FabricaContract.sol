//SPDX-License-Identifier: GPL-3.0
pragma solidity >0.8.0;

contract FabricaContract {
    uint idDigits = 16;

    struct Producto {
        string nombre;
        uint id;
    }

    Producto[] public productos;

    function _crearProducto(string memory _nombre, uint _id) private {
        productos.push(Producto(_nombre, _id));
    }

    function _generarIdAleatorio(
        string memory _str
    ) private view returns (uint) {
        uint rand = uint(keccak256(abi.encodePacked(_str)));
        uint idModulus = 10 ** idDigits;
        return rand % idModulus;
    }
}
