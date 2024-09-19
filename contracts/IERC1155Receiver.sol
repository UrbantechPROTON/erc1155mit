//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC165.sol";


interface IERC1155Receiver is IERC165 {

    function onERC1155Received(
        address operator,
        address from,
        uint id,
        uint value,
        bytes calldata data
    ) external returns(bytes4);

   function onERC1155BatchReceived(
        address operator,
        address from,
        uint[] calldata ids,
        uint[] calldata values,
        bytes calldata data
    ) external returns(bytes4); 
}