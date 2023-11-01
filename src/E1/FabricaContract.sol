//SPDX-License-Identifier: GPL-3.0
pragma solidity >0.8.0;

contract FabricaContract {
    uint idDigits = 16;

    struct Producto {
        string nombre;
        uint id;
    }

    Producto[] public productos;
}
