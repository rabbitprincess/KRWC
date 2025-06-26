// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

abstract contract RoleBlacklist {
    address private _blacklister;

    event BlacklisterChanged(address indexed previousBlacklister, address indexed newBlacklister);
    event Blacklisted(address indexed account, address indexed by);
    event UnBlacklisted(address indexed account, address indexed by);

    modifier onlyBlacklister() {
        require(msg.sender == _blacklister, "RoleBlacklist: caller is not the blacklister");
        _;
    }

    function _updateBlacklister(address newBlacklister) internal {
        require(newBlacklister != address(0), "RoleBlacklist: new blacklister is the zero address");
        address old = _blacklister;
        _blacklister = newBlacklister;
        emit BlacklisterChanged(old, newBlacklister);
    }

    function blacklister() public view returns (address) {
        return _blacklister;
    }

    modifier notBlacklisted(address _account) {
        require(
            !_isBlacklisted(_account),
            "RoleBlacklist: account is blacklisted"
        );
        _;
    }

    function isBlacklisted(address account) external view returns (bool) {
        return _isBlacklisted(account);
    }

    function blacklist(address account) external onlyBlacklister {
        _blacklist(account);
        emit Blacklisted(account, _blacklister);
    }

    function unBlacklist(address account) external onlyBlacklister {
        _unBlacklist(account);
        emit UnBlacklisted(account, _blacklister);
    }

    function _isBlacklisted(address _account) internal virtual view returns (bool);
    function _blacklist(address _account) internal virtual;
    function _unBlacklist(address _account) internal virtual;
}