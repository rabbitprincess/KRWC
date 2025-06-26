// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

abstract contract RoleMint {
    address private _masterMinter;

    event MasterMinterChanged(address indexed previous, address indexed current);
    event MinterAdded(address indexed minter, uint256 initialAllowance);
    event MinterRemoved(address indexed minter);

    modifier onlyMasterMinter() {
        require(msg.sender == _masterMinter, "RoleMint: caller is not masterMinter");
        _;
    }

    function _updateMasterMinter(address newMasterMinter) internal {
        require(newMasterMinter != address(0), "RoleMint: zero address");
        emit MasterMinterChanged(_masterMinter, newMasterMinter);
        _masterMinter = newMasterMinter;
    }

    function masterMinter() public view returns (address) {
        return _masterMinter;
    }

    modifier onlyMinters() {
        require(_getAllowance(msg.sender) > 0, "RoleMint: caller is not a minter");
        _;
    }

    function addMinter(address minter, uint256 allowance) external onlyMasterMinter {
        _addMinter(minter, allowance);
        emit MinterAdded(minter, allowance);
    }

    function removeMinter(address minter) external onlyMasterMinter {
        _removeMinter(minter);
        emit MinterRemoved(minter);
    }

    function isMinter(address minter) public view returns (bool) {
        return _getAllowance(minter) > 0;
    }

    function getAllowance(address minter) public view returns (uint256) {
        return _getAllowance(minter);
    }

    function _addMinter(address _minter, uint256 _allowance) internal virtual;
    function _removeMinter(address _minter) internal virtual;
    function _getAllowance(address _minter) internal view virtual returns (uint256);
}
