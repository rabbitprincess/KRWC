// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";
import { AbstractFiatToken } from "./AbstractFiatToken.sol";
import { EIP2612 } from "./EIP2612.sol";
import { EIP3009 } from "./EIP3009.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { RolePause } from "./RolePause.sol";
import { RoleBlacklist } from "./RoleBlacklist.sol";
import { RoleRescue } from "./RoleRescue.sol";
import { Mintable } from "./Mintable.sol";

contract FiatToken is AbstractFiatToken, EIP2612, EIP3009, Ownable, RolePause, RoleBlacklist, RoleRescue {
   using Math for uint256;

    string public name;
    string public symbol;
    uint8 public decimals;
    string public currency;
    address public masterMinter;
    bool internal initialized;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _currency,
        uint8  _decimals,
        address newMasterMinter,
        address newPauser,
        address newBlacklister,
        address newRescuer
    )
        EIP2612(_name, "1")
        EIP3009(_name, "1")
    {
        require(!initialized, "FiatToken: contract is already initialized");
        require(
            newMasterMinter != address(0),
            "FiatToken: new masterMinter is the zero address"
        );
        require(
            newPauser != address(0),
            "FiatToken: new pauser is the zero address"
        );
        require(
            newBlacklister != address(0),
            "FiatToken: new blacklister is the zero address"
        );

        name         = _name;
        symbol       = _symbol;
        decimals     = _decimals;
        currency     = _currency;
        _updatePauser(newPauser);
        _updateBlacklister(newBlacklister);
        _updateRescuer(newRescuer);
    }

    function updatePauser(address newBlacklister) external onlyOwner {
        _updateBlacklister(newBlacklister);
    }


    function updateBlacklister(address newBlacklister) external onlyOwner {
        _updateBlacklister(newBlacklister);
    }

    function updateRescuer(address newRescuer) external onlyOwner {
        _updateRescuer(newRescuer);
    }
}