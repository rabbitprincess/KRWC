// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Rescuable {
    using SafeERC20 for IERC20;

    address private _rescuer;

    event RescuerChanged(address indexed previousRescuer, address indexed newRescuer);

    modifier onlyRescuer() {
        require(msg.sender == _rescuer, "Rescuable: caller is not the rescuer");
        _;
    }

    function rescuer() public view returns (address) {
        return _rescuer;
    }

    function _updateRescuer(address newRescuer) internal {
        require(newRescuer != address(0), "Rescuable: new rescuer is zero address");
        address previous = _rescuer;
        _rescuer = newRescuer;
        emit RescuerChanged(previous, newRescuer);
    }

    function rescueERC20(IERC20 token, address to, uint256 amount) external onlyRescuer {
        require(to != address(0), "Rescuable: to is zero address");
        token.safeTransfer(to, amount);
    }
}