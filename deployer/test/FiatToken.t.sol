// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/FiatToken.sol";

contract FiatTokenTest is Test {
    FiatToken token;

    address owner = address(0x1);
    address masterMinter = address(0x2);
    address pauser = address(0x3);
    address blacklister = address(0x4);
    address rescuer = address(0x5);
    address cheolsu = address(0x10);
    uint256 cheolsuPk = 0x10;
    address younghui = address(0x11);
    uint256 younghuiPk = 0x11;

    function setUp() public {
        token = new FiatToken(
            "Fiat KRW", "KRW", "KRW", 6,
            masterMinter, pauser, blacklister, rescuer, owner
        );

        vm.startPrank(owner);
        token.updateMasterMinter(masterMinter);
        vm.stopPrank();

        vm.startPrank(masterMinter);
        token.addMinter(cheolsu, 1_000_000e6);
        vm.stopPrank();
    }

    function testMintAndTransfer() public {
        vm.startPrank(cheolsu);
        token.mint(cheolsu, 500e6);
        assertEq(token.balanceOf(cheolsu), 500e6);

        token.transfer(younghui, 100e6);
        assertEq(token.balanceOf(cheolsu), 400e6);
        assertEq(token.balanceOf(younghui), 100e6);

        vm.stopPrank();
    }

    function testApproveAndTransferFrom() public {
        vm.startPrank(cheolsu);
        token.mint(cheolsu, 1000e6);
        token.approve(younghui, 200e6);
        assertEq(token.allowance(cheolsu, younghui), 200e6);
        vm.stopPrank();

        vm.startPrank(younghui);
        token.transferFrom(cheolsu, younghui, 150e6);
        assertEq(token.balanceOf(younghui), 150e6);
        assertEq(token.allowance(cheolsu, younghui), 50e6);
        vm.stopPrank();
    }

    function testBlacklist() public {
        vm.startPrank(blacklister);
        token.blacklist(younghui);
        vm.stopPrank();

        vm.startPrank(cheolsu);
        token.mint(cheolsu, 100e6);
        vm.expectRevert();
        token.transfer(younghui, 10e6);
        vm.stopPrank();
    }

    function testPauseUnpause() public {
        vm.startPrank(pauser);
        token.pause();
        vm.stopPrank();

        vm.startPrank(cheolsu);
        vm.expectRevert();
        token.mint(cheolsu, 100e6);
        vm.stopPrank();

        vm.startPrank(pauser);
        token.unpause();
        vm.stopPrank();

        vm.startPrank(cheolsu);
        token.mint(cheolsu, 100e6);
        vm.stopPrank();
    }

    function testBurn() public {
        vm.startPrank(cheolsu);
        token.mint(cheolsu, 500e6);
        token.burn(100e6);
        assertEq(token.balanceOf(cheolsu), 400e6);
        vm.stopPrank();
    }
}
