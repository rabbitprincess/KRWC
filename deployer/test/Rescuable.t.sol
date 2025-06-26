// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Rescuable.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract MockRescuable is Rescuable {
    function setRescuer(address newRescuer) external {
        _updateRescuer(newRescuer);
    }

    receive() external payable {}
}

contract TestToken is ERC20 {
    constructor() ERC20("TestToken", "TTK") {
        _mint(msg.sender, 1_000_000 ether);
    }
}

contract RescuableTest is Test {
    MockRescuable public rescuable;
    TestToken public token;

    address public rescuer = address(1);
    address public user = address(2);

    function setUp() public {
        rescuable = new MockRescuable();
        token = new TestToken();

        rescuable.setRescuer(rescuer);
        token.transfer(address(rescuable), 1000 ether);
    }

    function testRescuerCanRescueERC20() public {
        vm.prank(rescuer);
        rescuable.rescueERC20(IERC20(address(token)), user, 100 ether);

        assertEq(token.balanceOf(user), 100 ether);
        assertEq(token.balanceOf(address(rescuable)), 900 ether);
    }

    function testCannotRescueIfNotRescuer() public {
        vm.prank(user);
        vm.expectRevert("Rescuable: caller is not the rescuer");
        rescuable.rescueERC20(IERC20(address(token)), user, 100 ether);
    }

    function testRescueFailsToZeroAddress() public {
        vm.prank(rescuer);
        vm.expectRevert("Rescuable: to is zero address");
        rescuable.rescueERC20(IERC20(address(token)), address(0), 100 ether);
    }

    function testSetRescuerUpdatesValueAndEmitsEvent() public {
        vm.expectEmit(true, true, false, true);
        emit RescuerChanged(rescuer, user);

        vm.prank(rescuer);
        rescuable.setRescuer(user);

        assertEq(rescuable.rescuer(), user);
    }

    event RescuerChanged(address indexed previousRescuer, address indexed newRescuer);
}