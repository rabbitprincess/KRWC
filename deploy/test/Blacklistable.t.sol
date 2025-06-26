// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../src/Blacklistable.sol";
import "forge-std/Test.sol";
import "../src/Blacklistable.sol";

contract MockBlacklistable is Blacklistable {
    function setBlacklister(address newBlacklister) external {
        _updateBlacklister(newBlacklister);
    }

    function blacklist(address account) external {
        _blacklist(account);
    }

    function unBlacklist(address account) external {
        _unBlacklist(account);
    }

    function checkNotBlacklisted(address account) external view notBlacklisted(account) returns (bool) {
        return true;
    }

    receive() external payable {}
}

contract BlacklistableTest is Test {
    MockBlacklistable public blacklistable;
    address public initialBlacklister = address(0);
    address public blacklister = address(1);
    address public user = address(2);

    event BlacklisterChanged(address indexed previousBlacklister, address indexed newBlacklister);
    event Blacklisted(address indexed account, address indexed by);
    event UnBlacklisted(address indexed account, address indexed by);

    function setUp() public {
        blacklistable = new MockBlacklistable();
        blacklistable.setBlacklister(blacklister);
        assertEq(blacklistable.blacklister(), blacklister);
    }

    function testUpdateBlacklisterAndEmit() public {
        vm.expectEmit(true, true, false, true);
        emit BlacklisterChanged(blacklister, user);

        blacklistable.setBlacklister(user);
        assertEq(blacklistable.blacklister(), user);
    }

    function testBlacklistAndEmit() public {
        vm.expectEmit(true, true, false, true);
        emit Blacklisted(user, address(this));

        blacklistable.blacklist(user);
        assertTrue(blacklistable.isBlacklisted(user));
    }

    function testCannotDoubleBlacklist() public {
        blacklistable.blacklist(user);
        vm.expectRevert("Blacklistable: already blacklisted");
        blacklistable.blacklist(user);
    }

    function testUnBlacklistAndEmit() public {
        blacklistable.blacklist(user);

        vm.expectEmit(true, true, false, true);
        emit UnBlacklisted(user, address(this));

        blacklistable.unBlacklist(user);
        assertFalse(blacklistable.isBlacklisted(user));
    }

    function testCannotUnBlacklistIfNotPresent() public {
        vm.expectRevert("Blacklistable: not blacklisted");
        blacklistable.unBlacklist(user);
    }

    function testNotBlacklistedModifier() public {
        assertTrue(blacklistable.checkNotBlacklisted(user));

        blacklistable.blacklist(user);
        vm.expectRevert("Blacklistable: account is blacklisted");
        blacklistable.checkNotBlacklisted(user);
    }
}