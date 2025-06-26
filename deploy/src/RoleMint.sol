// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

abstract contract RoleMint {
    address private _masterMinter;

    event MasterMinterChanged(address indexed previous, address indexed current);
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

    function getMinterAllowance(address minter) public view returns (uint256) {
        return _getAllowance(minter);
    }

    function increaseAllowance(address owner, address spender, uint256 increment) external onlyMasterMinter {
        require(owner != address(0), "RoleMint: zero address");
        require(increment > 0, "RoleMint: zero increment");
        _increaseAllowance(owner, spender, increment);

        uint256 newAllow = _getAllowance(owner);
        emit MinterAllowanceIncremented(msg.sender, owner, increment, newAllow);
    }

    function decreaseAllowance(address owner, address spender, uint256 decrement) external onlyMasterMinter {
        require(owner != address(0), "RoleMint: zero address");
        require(decrement > 0, "RoleMint: zero decrement");
        _decreaseAllowance(owner, spender, decrement);

        uint256 newAllow = _getAllowance(owner);
        emit MinterAllowanceDecremented(msg.sender, owner, decrement, newAllow);
    }

    function _addMinter(address _minter, uint256 _allowance) internal virtual;
    function _removeMinter(address _minter) internal virtual;
    function _getAllowance(address _minter) internal view virtual returns (uint256);
    function _increaseAllowance(address owner, address spender, uint256 increment) internal virtual;
    function _decreaseAllowance(address owner, address spender, uint256 decrement) internal virtual;
}
