// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/RolePause.sol";

contract MockPauseable is RolePause {
    function setPauser(address newPauser) external {
        _updatePauser(newPauser);
    }

    function protectedAction() external view whenNotPaused returns (bool) {
        return true;
    }

    function pausedAction() external view whenPaused returns (bool) {
        return true;
    }
}

contract RolePauseTest is Test {
    MockPauseable public mock;
    address public pauser = address(1);
    address public user   = address(2);

    event PauserChanged(address indexed previousPauser, address indexed newPauser);
    event PausedBy(address indexed pauser);
    event UnpausedBy(address indexed pauser);

    function setUp() public {
        mock = new MockPauseable();
        mock.setPauser(pauser);
        assertEq(mock.pauser(), pauser);
    }

    function testOnlyPauserCanPause() public {
        vm.prank(user);
        vm.expectRevert("RolePause: caller is not the pauser");
        mock.pause();

        vm.prank(pauser);
        vm.expectEmit(true, false, false, true);
        emit PausedBy(pauser);
        mock.pause();
        assertTrue(mock.paused());
    }

    function testOnlyPauserCanUnpause() public {
        vm.prank(pauser);
        mock.pause();

        vm.prank(user);
        vm.expectRevert("RolePause: caller is not the pauser");
        mock.unpause();

        vm.prank(pauser);
        vm.expectEmit(true, false, false, true);
        emit UnpausedBy(pauser);
        mock.unpause();
        assertFalse(mock.paused());
    }

    function testProtectedAndPausedAction() public {
        assertTrue(mock.protectedAction());
        vm.expectRevert();
        mock.pausedAction();

        vm.prank(pauser);
        mock.pause();

        vm.expectRevert();
        mock.protectedAction();
        assertTrue(mock.pausedAction());
    }

    function testSetPauserUpdatesValueAndEmitsEvent() public {
        vm.prank(pauser);
        vm.expectEmit(true, true, false, true);
        emit PauserChanged(pauser, user);
        mock.setPauser(user);
        assertEq(mock.pauser(), user);
    }
}
