//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC1155.sol";
import "./ERC165.sol";
import "./IERC1155MetadataURI.sol";
import "./IERC1155Receiver.sol";


contract ERC1155 is ERC165, IERC1155, IERC1155MetadataURI {
    mapping(uint => mapping(address => uint)) private balances;
    mapping(address => mapping(address => bool)) private operatorApprovals;
    string private _uri;

    constructor(string memory uri_) {
        _setURI(uri_);
    }

    function supportsInterface(bytes4 interfaceId) public view override returns(bool) {
        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function uri(uint) public view virtual override(IERC1155, IERC1155MetadataURI) returns(string memory) {
        return _uri;
    } 

    function balanceOf(address _account, uint _id) public view virtual returns(uint) {
        require(_account != address(0));

        return balances[_id][_account];
    }

    function balanceOfBatch(
        address[] calldata _accounts,
        uint[] calldata _ids
    ) public view virtual returns(uint[] memory batchBalances_) {
        require(_accounts.length == _ids.length);

        batchBalances_ = new uint[](_accounts.length);

        for(uint i = 0; i < _accounts.length; i++) {
            batchBalances_[i] = balanceOf(_accounts[i], _ids[i]);
        }
    }

    function setApprovalForAll(
        address _operator,
        bool _approved
    ) external virtual {
        _setApprovalForAll(msg.sender, _operator, _approved);
    } 

    function isApprovedForAll(
        address _account,
        address _operator
    ) public view virtual returns(bool) {
        return operatorApprovals[_account][_operator];
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint _id,
        uint _amount,
        bytes calldata _data
    ) public virtual {
        require(_from == msg.sender || isApprovedForAll(_from, msg.sender));

        _safeTransferFrom(_from, _to, _id, _amount, _data);
    }

    function safeBatchTransferFrom(
        address _from,
        address _to,
        uint[] calldata _ids,
        uint[] calldata _amounts,
        bytes calldata _data
    ) public virtual {
        require(_from == msg.sender || isApprovedForAll(_from, msg.sender));

        _safeBatchTransferFrom(_from, _to, _ids, _amounts, _data);
    }

    function _safeTransferFrom(
        address _from,
        address _to,
        uint _id,
        uint _amount,
        bytes calldata _data
    ) internal virtual {
        require(_to != address(0));

        address operator = msg.sender;

        uint[] memory ids = _asSingletonArray(_id);
        uint[] memory amounts = _asSingletonArray(_amount);

        _beforeTokenTransfer(operator, _from, _to, ids, amounts, _data);

        uint fromBalance = balances[_id][_from];
        require(fromBalance >= _amount);

        balances[_id][_from] = fromBalance - _amount;
        balances[_id][_to] += _amount;

        emit TransferSingle(operator, _from, _to, _id, _amount);

        _afterTokenTransfer(operator, _from, _to, ids, amounts, _data);

        _doSafeTransferAcceptanceCheck(operator, _from, _to, _id, _amount, _data);
    }

    function _safeBatchTransferFrom(
        address _from,
        address _to,
        uint[] calldata _ids,
        uint[] calldata _amounts,
        bytes calldata _data
    ) internal virtual {
        require(_ids.length == _amounts.length);
        require(_to != address(0));

        address operator = msg.sender;

        _beforeTokenTransfer(operator, _from, _to, _ids, _amounts, _data);

        for(uint i = 0; i <_ids.length; i++) {
            uint id = _ids[i];
            uint amount =_amounts[i];
            uint fromBalance = balances[id][_from];
            require(fromBalance >= amount);

            balances[id][_from] = fromBalance - amount;
            balances[id][_to] += amount;
        }

        emit TransferBatch(operator, _from, _to, _ids, _amounts);

        _afterTokenTransfer(operator, _from, _to, _ids, _amounts, _data);

        _doSafeBatchTransferAcceptanceCheck(operator, _from, _to, _ids, _amounts, _data);
    }

    function _setURI(string memory _newUri) internal virtual {
        _uri = _newUri;
    }

    function _setApprovalForAll(
        address _owner,
        address _operator,
        bool _approved
    ) internal virtual {
        require(_owner != _operator);

        operatorApprovals[_owner][_operator] = _approved;
        
        emit Approval(_owner, _operator, _approved);
    }

    function _beforeTokenTransfer(
        address _operator,
        address _from,
        address _to,
        uint[] memory _ids,
        uint[] memory _amount,
        bytes memory _data
    ) internal virtual {}

    function _afterTokenTransfer(
        address _operator,
        address _from,
        address _to,
        uint[] memory _ids,
        uint[] memory _amount,
        bytes memory _data
    ) internal virtual {}

    function _doSafeTransferAcceptanceCheck(
        address _operator, 
        address _from, 
        address _to, 
        uint _id,
        uint _amount, 
        bytes memory _data
    ) private {
        if(_to.code.length > 0) {
            try IERC1155Receiver(_to).onERC1155Received(_operator, _from, _id, _amount, _data) returns (bytes4 response) {
                if(response != IERC1155Receiver.onERC1155Received.selector) {
                    revert("Tokens rejected");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("Non-ERC1155 receiver");
            }
        }
    } 

    function _doSafeBatchTransferAcceptanceCheck(
        address _operator, 
        address _from, 
        address _to, 
        uint[] memory _ids,
        uint[] memory _amounts, 
        bytes memory _data
    ) private {
        if(_to.code.length > 0) {
            try IERC1155Receiver(_to).onERC1155BatchReceived(_operator, _from, _ids, _amounts, _data) returns (bytes4 response) {
                if(response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("Tokens rejected");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("Non-ERC1155 receiver");
            }
        }
    } 

    function _asSingletonArray(uint _el) private pure returns(uint[] memory result_) {
        result_ = new uint[](1);
        result_[0] = _el;
    }

    function _mint(
        address _to,
        uint _id,
        uint _amount,
        bytes memory _data
    )   internal virtual {
        require(_to != address(0));

        address operator = msg.sender;

        uint[] memory ids = _asSingletonArray(_id);
        uint[] memory amounts = _asSingletonArray(_amount);

        _beforeTokenTransfer(operator, address(0), _to, ids, amounts, _data);

        balances[_id][_to] += _amount;

        emit TransferSingle(operator, address(0), _to, _id, _amount);

        _afterTokenTransfer(operator, address(0), _to, ids, amounts, _data);

        _doSafeTransferAcceptanceCheck(operator, address(0), _to, _id, _amount, _data);
    }

    function _mintBatch(
        address _to,
        uint[] memory _ids,
        uint[] memory _amounts,
        bytes memory _data
    )   internal virtual {
        require(_ids.length == _amounts.length);
        require(_to != address(0));

        address operator = msg.sender;

        _beforeTokenTransfer(operator, address(0), _to, _ids, _amounts, _data);

        for(uint i = 0; i <_ids.length; i++) {
            uint id = _ids[i];
            uint amount =_amounts[i];
            
            balances[id][_to] += amount;
        }

        emit TransferBatch(operator, address(0), _to, _ids, _amounts);

        _afterTokenTransfer(operator, address(0), _to, _ids, _amounts, _data);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), _to, _ids, _amounts, _data);
    }

    function _burn(
        address _from,
        uint _id,
        uint _amount
    ) internal virtual {
        require(_from != address(0));
        address operator = msg.sender;
        uint[] memory ids = _asSingletonArray(_id);
        uint[] memory amounts = _asSingletonArray(_amount);

        _beforeTokenTransfer(operator, _from, address(0), ids, amounts, "");

        uint fromBalance = balances[_id][_from];
        require(fromBalance >= _amount);

        balances[_id][_from] = fromBalance - _amount;

        emit TransferSingle(operator, _from, address(0), _id, _amount);

        _afterTokenTransfer(operator, _from, address(0), ids, amounts, "");
    }

    function _burnBatch(
        address _from,
        uint[] memory _ids,
        uint[] memory _amounts
    ) internal virtual {
        require(_from != address(0));
        require(_ids.length == _amounts.length);

        address operator = msg.sender;

        _beforeTokenTransfer(operator, _from, address(0), _ids, _amounts, "");

        for(uint i = 0; i <_ids.length; i++) {
            uint id = _ids[i];
            uint amount =_amounts[i];
            uint fromBalance = balances[id][_from];
            require(fromBalance >= amount);

            balances[id][_from] = fromBalance - amount;
        }

        emit TransferBatch(operator, _from, address(0), _ids, _amounts);

        _afterTokenTransfer(operator, _from, address(0), _ids, _amounts, "");
    }
}