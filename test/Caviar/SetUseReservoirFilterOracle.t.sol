// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../shared/Fixture.t.sol";

contract SetUseReservoirFilterOracleTest is Fixture {
    event SetUseReservoirFilterOracle(bool indexed useReservoirFilterOracle);

    function testItSetsUseReservoirFilterOracle() public {
        // act
        c.setUseReservoirFilterOracle(true);

        // assert
        assertEq(c.useReservoirFilterOracle(), true, "Should have set useReservoirFilterOracle");
    }

    function testItEmitsSetUseReservoirFilterOracleEvent() public {
        // arrange
        vm.expectEmit(true, true, true, true);
        emit SetUseReservoirFilterOracle(true);

        // act
        c.setUseReservoirFilterOracle(true);
    }

    function testItSetsUseReservoirFilterOracle(bool useReservoirFilterOracle) public {
        // act
        c.setUseReservoirFilterOracle(useReservoirFilterOracle);

        // assert
        assertEq(c.useReservoirFilterOracle(), useReservoirFilterOracle, "Should have set useReservoirFilterOracle");
    }

    function testOnlyAdminCanSetUserReservoirFilterOracle() public {
        // arrange
        vm.prank(address(0xbeef));

        // act
        vm.expectRevert("UNAUTHORIZED");
        c.setUseReservoirFilterOracle(true);
    }
}
