// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/Pausable.sol";

contract RolePause is Pausable {
    address private _pauser;

    event PauserChanged(address indexed previousPauser, address indexed newPauser);
    event PausedBy(address indexed pauser);
    event UnpausedBy(address indexed pauser);

    modifier onlyPauser() {
        require(msg.sender == _pauser, "RolePause: caller is not the pauser");
        _;
    }

    function _updatePauser(address newPauser) internal {
        require(newPauser != address(0), "RolePause: zero address");
        emit PauserChanged(_pauser, newPauser);
        _pauser = newPauser;
    }

    function pauser() public view returns (address) {
        return _pauser;
    }

    function pause() external onlyPauser {
        _pause();
        emit PausedBy(_pauser);
    }

    function unpause() external onlyPauser {
        _unpause();
        emit UnpausedBy(_pauser);
    }
}