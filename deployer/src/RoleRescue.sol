// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract RoleRescue {
    using SafeERC20 for IERC20;

    address private _rescuer;

    event RescuerChanged(address indexed previousRescuer, address indexed newRescuer);
    event ERC20Rescued(address indexed rescuer, address indexed token, address indexed to, uint256 amount);

    modifier onlyRescuer() {
        require(msg.sender == _rescuer, "RoleRescue: caller is not the rescuer");
        _;
    }

    function _updateRescuer(address newRescuer) internal {
        require(newRescuer != address(0), "RoleRescue: zero address");
        emit RescuerChanged(_rescuer, newRescuer);
        _rescuer = newRescuer;
    }

    function rescuer() public view returns(address) {
        return _rescuer;
    }

    function rescueERC20(IERC20 token, address to, uint256 amount) external onlyRescuer {
        require(to != address(0), "RoleRescue: to is zero address");
        token.safeTransfer(to, amount);
        emit ERC20Rescued(_rescuer, address(token), to, amount);
    }
}