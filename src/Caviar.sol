// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "solmate/auth/Owned.sol";

import "./Pair.sol";

contract Caviar is Owned {
    constructor() Owned(msg.sender) {}

    function create(address nft, address baseToken) public returns (Pair) {
        return new Pair(nft, baseToken);
    }
}
