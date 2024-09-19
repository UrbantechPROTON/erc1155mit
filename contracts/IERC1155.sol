//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface IERC1155 {

  event TransferSingle(address operator, address indexed from, address indexed to, uint indexed id, uint amount);

  event TransferBatch(address operator, address indexed from, address indexed to, uint[] ids, uint[] amounts);

  event Approval(address owner, address operator, bool isApproved);

  function balanceOf(address account, uint id) external view returns(uint);

  function balanceOfBatch(address[] calldata accounts, uint[] calldata ids) external view returns(uint[] memory);

  function safeTransferFrom(address from, address to, uint id, uint amount, bytes calldata data) external;

  function safeBatchTransferFrom(address from, address to, uint[] calldata ids, uint[] calldata amounts, bytes calldata data) external;

  function setApprovalForAll(address operator, bool approved) external; 

  function isApprovedForAll(address account, address operator) external view returns(bool);

  function uri(uint id) external view returns(string memory);  
}