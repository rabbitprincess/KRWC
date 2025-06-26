// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

abstract contract RoleMint {
    address private _masterMinter;

    mapping(address => uint256) private _minterAllowance;

    event MinterAdded(address indexed minter, uint256 initialAllowance);
    event MinterRemoved(address indexed minter);
    event MinterAllowanceIncremented(
        address indexed sender,
        address indexed minter,
        uint256 increment,
        uint256 newAllowance
    );
    event MinterAllowanceDecremented(
        address indexed sender,
        address indexed minter,
        uint256 decrement,
        uint256 newAllowance
    );

    modifier onlyMinter() {
        require(_minterAllowance[msg.sender] > 0, "Mintable: caller is not a minter");
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return _minterAllowance[account] > 0;
    }

    function minterAllowance(address account) public view returns (uint256) {
        return _minterAllowance[account];
    }

    function _addMinter(address minter, uint256 allowance) internal {
        require(minter != address(0), "Mintable: zero address");
        require(_minterAllowance[minter] == 0, "Mintable: already a minter");
        _minterAllowance[minter] = allowance;
        emit MinterAdded(minter, allowance);
    }

    function _removeMinter(address minter) internal {
        require(_minterAllowance[minter] > 0, "Mintable: not a minter");
        _minterAllowance[minter] = 0;
        emit MinterRemoved(minter);
    }

    function _increaseMinterAllowance(address minter, uint256 increment) internal {
        require(_minterAllowance[minter] > 0, "Mintable: not a minter");
        _minterAllowance[minter] += increment;
        emit MinterAllowanceIncremented(msg.sender, minter, increment, _minterAllowance[minter]);
    }

    function _decreaseMinterAllowance(address minter, uint256 decrement) internal {
        require(_minterAllowance[minter] > 0, "Mintable: not a minter");
        require(_minterAllowance[minter] >= decrement, "Mintable: decrement exceeds allowance");
        _minterAllowance[minter] -= decrement;
        emit MinterAllowanceDecremented(msg.sender, minter, decrement, _minterAllowance[minter]);
    }
}
