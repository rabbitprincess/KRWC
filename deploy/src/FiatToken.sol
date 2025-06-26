// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";
import { AbstractFiatToken } from "./AbstractFiatToken.sol";
import { EIP2612 } from "./EIP2612.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Pausable } from "@openzeppelin/contracts/utils/Pausable.sol";
import { Blacklistable } from "./Blacklistable.sol";
import { Rescuable } from "./Rescuable.sol";
import { Mintable } from "./Mintable.sol";

// contract FiatToken is AbstractFiatToken, EIP2612, Ownable, Pausable, Blacklistable, Rescuable {
//    using Math for uint256;

//     string public name;
//     string public symbol;
//     uint8 public decimals;
//     string public currency;
//     address public masterMinter;
//     bool internal initialized;

// }