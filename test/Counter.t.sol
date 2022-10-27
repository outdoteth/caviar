// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";

import "../src/Caviar.sol";

contract CaviarTest is Test {
    Caviar public caviar;

    function setUp() public {
        caviar = new Caviar();
    }
}
