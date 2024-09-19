//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC1155.sol";
import "./ERC1155Burnable.sol";


contract MyToken is ERC1155, ERC1155Burnable {
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor() ERC1155("http://example.com") {
        owner = msg.sender;
    }

    function setURI(string memory _newuri) public onlyOwner {
        _setURI(_newuri);
    }

    function mint(
        address _to,
        uint _id,
        uint _amount,
        bytes memory _data
    ) public onlyOwner {
        _mint(_to, _id, _amount, _data);
    }

    function mintBatch(
        address _to,
        uint[] memory _ids,
        uint[] memory _amounts,
        bytes memory _data
    ) public onlyOwner {
        _mintBatch(_to, _ids, _amounts, _data);
    }
}