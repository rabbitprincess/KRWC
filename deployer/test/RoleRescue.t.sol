// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/RoleRescue.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract TestToken is ERC20 {
    constructor() ERC20("TestToken", "TTK") {
        _mint(msg.sender, 1_000_000 ether);
    }
}

contract MockRescue is RoleRescue {
    function setRescuer(address newRescuer) external {
        _updateRescuer(newRescuer);
    }

    receive() external payable {}
}


contract RoleRescueTest is Test {
    MockRescue public mock;
    TestToken   public token;

    address public rescuer = address(1);
    address public user    = address(2);

    function setUp() public {
        mock  = new MockRescue();
        token = new TestToken();
        mock.setRescuer(rescuer);
        token.transfer(address(mock), 1_000 ether);
    }

    function testRescuerCanRescueERC20() public {
        vm.prank(rescuer);
        mock.rescueERC20(IERC20(address(token)), user, 100 ether);
        assertEq(token.balanceOf(user), 100 ether);
        assertEq(token.balanceOf(address(mock)), 900 ether);
    }

    function testCannotRescueIfNotRescuer() public {
        vm.prank(user);
        vm.expectRevert("RoleRescue: caller is not the rescuer");
        mock.rescueERC20(IERC20(address(token)), user, 50 ether);
    }

    function testRescueFailsToZeroAddress() public {
        vm.prank(rescuer);
        vm.expectRevert("RoleRescue: to is zero address");
        mock.rescueERC20(IERC20(address(token)), address(0), 10 ether);
    }

    function testSetRescuerUpdatesValueAndEmitsEvent() public {
        vm.prank(rescuer);
        vm.expectEmit(true, true, false, true);
        emit RescuerChanged(rescuer, user);

        mock.setRescuer(user);
        assertEq(mock.rescuer(), user);
    }

    function testRescueERC20EmitsEvent() public {
        vm.prank(rescuer);
        vm.expectEmit(true, true, true, true);
        emit ERC20Rescued(rescuer, address(token), user, 123 ether);
        mock.rescueERC20(IERC20(address(token)), user, 123 ether);
    }

    event RescuerChanged(address indexed previousRescuer, address indexed newRescuer);
    event ERC20Rescued(address indexed rescuer, address indexed token, address indexed to, uint256 amount);
}