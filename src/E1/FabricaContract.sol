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
}
