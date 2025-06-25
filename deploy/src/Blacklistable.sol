// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

abstract contract Blacklistable {
    event Blacklisted(address indexed account, address indexed by);
    event UnBlacklisted(address indexed account, address indexed by);
    event BlacklisterChanged(address indexed previousBlacklister, address indexed newBlacklister);

    address public blacklister;

    mapping(address => bool) private _blacklisted;

    modifier onlyBlacklister() {
        require(msg.sender == blacklister, "Blacklistable: caller is not the blacklister");
        _;
    }

    modifier notBlacklisted(address account) {
        require(!_blacklisted[account], "Blacklistable: account is blacklisted");
        _;
    }

    function isBlacklisted(address account) public view virtual returns (bool) {
        return _blacklisted[account];
    }

    function _isBlacklisted(address account) internal view returns (bool) {
        return _blacklisted[account];
    }

    function _blacklist(address account) internal virtual {
        require(!_blacklisted[account], "Blacklistable: already blacklisted");
        _blacklisted[account] = true;
        emit Blacklisted(account, msg.sender);
    }

    function _unBlacklist(address account) internal virtual {
        require(_blacklisted[account], "Blacklistable: not blacklisted");
        _blacklisted[account] = false;
        emit UnBlacklisted(account, msg.sender);
    }

    function _updateBlacklister(address newBlacklister) internal virtual {
        require(newBlacklister != address(0), "Blacklistable: new blacklister is the zero address");
        address old = blacklister;
        blacklister = newBlacklister;
        emit BlacklisterChanged(old, newBlacklister);
    }
}