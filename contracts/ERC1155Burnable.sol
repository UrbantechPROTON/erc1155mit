//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC1155.sol";


abstract contract ERC1155Burnable is ERC1155 {

    function burn(
        address _from,
        uint _id,
        uint _value
    ) public virtual {
        require(_from == msg.sender || isApprovedForAll(_from, msg.sender));

        _burn(_from, _id, _value);
    }

    function burnBatch(
        address _from,
        uint[] memory _ids,
        uint[] memory _values
    ) public virtual {
        require(_from == msg.sender || isApprovedForAll(_from, msg.sender));

        _burnBatch(_from, _ids, _values);
    }
}    