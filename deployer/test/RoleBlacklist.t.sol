// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/RoleBlacklist.sol";

contract MockBlacklistable is RoleBlacklist {
    mapping(address => bool) private _states;
    constructor() {}

    function setBlacklister(address newBlacklister) external {
        _updateBlacklister(newBlacklister);
    }

    function doBlacklist(address account) external {
        _blacklist(account);
    }

    function doUnBlacklist(address account) external {
        _unBlacklist(account);
    }

    function checkNotBlacklisted(address account) external view notBlacklisted(account) returns (bool) {
        return true;
    }

    receive() external payable {}

    function _isBlacklisted(address account) internal view override returns (bool) {
        return _states[account];
    }

    function _blacklist(address account) internal override {
        require(!_states[account], "RoleBlacklist: already blacklisted");
        _states[account] = true;
    }

    function _unBlacklist(address account) internal override {
        require(_states[account], "RoleBlacklist: not blacklisted");
        _states[account] = false;
    }
}

contract RoleBlacklistTest is Test {
    MockBlacklistable public mock;
    address public blacklister = address(1);
    address public user       = address(2);

    event BlacklisterChanged(address indexed previousBlacklister, address indexed newBlacklister);
    event Blacklisted(address indexed account, address indexed by);
    event UnBlacklisted(address indexed account, address indexed by);

    function setUp() public {
        mock = new MockBlacklistable();
        mock.setBlacklister(blacklister);
        assertEq(mock.blacklister(), blacklister);
    }

    function testUpdateBlacklisterAndEmit() public {
        vm.expectEmit(true, true, false, true);
        emit BlacklisterChanged(blacklister, user);

        vm.prank(blacklister);
        mock.setBlacklister(user);

        assertEq(mock.blacklister(), user);
    }

    function testBlacklistAndEmit() public {
        vm.prank(blacklister);
        vm.expectEmit(true, true, false, true);
        emit Blacklisted(user, blacklister);

        mock.blacklist(user);
        assertTrue(mock.isBlacklisted(user));
    }

    function testCannotDoubleBlacklist() public {
        vm.prank(blacklister);
        mock.blacklist(user);

        vm.prank(blacklister);
        vm.expectRevert("RoleBlacklist: already blacklisted");
        mock.blacklist(user);
    }

    function testUnBlacklistAndEmit() public {
        vm.prank(blacklister);
        mock.blacklist(user);

        vm.prank(blacklister);
        vm.expectEmit(true, true, false, true);
        emit UnBlacklisted(user, blacklister);

        mock.unBlacklist(user);
        assertFalse(mock.isBlacklisted(user));
    }

    function testCannotUnBlacklistIfNotPresent() public {
        vm.prank(blacklister);
        vm.expectRevert("RoleBlacklist: not blacklisted");
        mock.unBlacklist(user);
    }

    function testNotBlacklistedModifier() public {
        assertTrue(mock.checkNotBlacklisted(user));

        vm.prank(blacklister);
        mock.blacklist(user);

        vm.expectRevert("RoleBlacklist: account is blacklisted");
        mock.checkNotBlacklisted(user);
    }
}
