//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract Pausable {
  bool isPaused;

  modifier onlyPaused() {
    require(isPaused);
    _;
  }

  modifier onlyUnpaused() {
    require(!isPaused);
    _;
  }

  function getPaused() public view returns(bool) {
    return isPaused;
  }  

  function _pause() internal {
    isPaused = true;
  }

  function _unpause() internal {
    isPaused = false;
  }
}  