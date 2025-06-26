// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { AbstractFiatToken } from "./AbstractFiatToken.sol";
import { EIP712 } from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import { SignatureChecker } from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

/**
 * @title EIP-2612
 * @notice Provide internal implementation for gas-abstracted approvals
 */
abstract contract EIP2612 is AbstractFiatToken, EIP712 {
    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)")
    bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

    mapping(address => uint256) private _permitNonces;

    /**
     * @notice In the inheriting contract’s constructor, ensure you call EIP712(name, version).
     * @param name    EIP-712 domain name
     * @param version EIP-712 domain version
     */
    constructor(string memory name, string memory version) EIP712(name, version) {}

    /**
     * @notice Nonces for permit
     * @param owner Token owner's address (Authorizer)
     * @return Next nonce
     */
    function nonces(address owner) external view returns (uint256) {
        return _permitNonces[owner];
    }

    /**
     * @notice Verify a signed approval permit and execute if valid
     * @param owner     Token owner's address (Authorizer)
     * @param spender   Spender's address
     * @param value     Amount of allowance
     * @param deadline  The time at which the signature expires (unix time), or max uint256 value to signal no expiration
     * @param v         v of the signature
     * @param r         r of the signature
     * @param s         s of the signature
     */
    function _permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        _permit(owner, spender, value, deadline, abi.encodePacked(r, s, v));
    }

    /**
     * @notice Verify a signed approval permit and execute if valid
     * @dev EOA wallet signatures should be packed in the order of r, s, v.
     * @param owner      Token owner's address (Authorizer)
     * @param spender    Spender's address
     * @param value      Amount of allowance
     * @param deadline   The time at which the signature expires (unix time), or max uint256 value to signal no expiration
     * @param signature  Signature byte array signed by an EOA wallet or a contract wallet
     */
    function _permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        bytes memory signature
    ) internal {
        require(
            deadline == type(uint256).max || deadline >= block.timestamp,
            "EIP2612: permit expired"
        );
        bytes32 structHash = keccak256(
            abi.encode(
                PERMIT_TYPEHASH,
                owner,
                spender,
                value,
                _permitNonces[owner]++,
                deadline
            )
        );
        bytes32 digest = _hashTypedDataV4(structHash);
        require(
            SignatureChecker.isValidSignatureNow(owner, digest, signature),
            "EIP2612: invalid signature"
        );
        _approve(owner, spender, value);
    }
}
