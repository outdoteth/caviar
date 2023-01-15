// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../shared/Fixture.t.sol";

contract SetStolenNftOracleTest is Fixture {
    event SetStolenNftFilterOracle(address indexed stolenNftFilterOracle);

    function testItSetsStolenNftFilterOracle() public {
        // act
        c.setStolenNftFilterOracle(address(123));

        // assert
        assertEq(c.stolenNftFilterOracle(), address(123), "Should have set stolenNftFilterOracle");
    }

    function testItEmitsSetStolenNftOracleEvent() public {
        // arrange
        address expectedAddress = address(0x123);
        vm.expectEmit(true, true, true, true);
        emit SetStolenNftFilterOracle(expectedAddress);

        // act
        c.setStolenNftFilterOracle(expectedAddress);
    }

    function testItSetsStolenNftOracle(address stolenNftOracle) public {
        // act
        c.setStolenNftFilterOracle(stolenNftOracle);

        // assert
        assertEq(c.stolenNftFilterOracle(), stolenNftOracle, "Should have set stolenNftOracle");
    }

    function testOnlyAdminCanSetStolenNftOracle() public {
        // arrange
        vm.prank(address(0xbeef));

        // act
        vm.expectRevert("UNAUTHORIZED");
        c.setStolenNftFilterOracle(address(123));
    }
}
