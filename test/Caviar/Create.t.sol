// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";

import "../shared/Fixture.t.sol";

contract CreateTest is Fixture {
    function testItReturnsPair() public {
        // arrange
        address nft = address(0);
        address baseToken = address(0);

        // act
        address pair = address(c.create(nft, baseToken));

        // assert
        assertTrue(pair != address(0), "Should have deployed pair");
    }
}
