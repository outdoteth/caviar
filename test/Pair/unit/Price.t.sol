// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../../shared/Fixture.t.sol";

contract PriceTest is Fixture {
    using stdStorage for StdStorage;

    function testItReturnsCorrectPrice() public {
        // arrange
        uint256 baseTokenReserves = 500;
        uint256 fractionalTokenReserves = 1000;
        uint256 expectedPrice = (baseTokenReserves * 10 ** (36 - 6)) / fractionalTokenReserves;

        // forgefmt: disable-next-item
        stdstore
            .target(address(usd))
            .sig("balanceOf(address)")
            .with_key(address(p))
            .checked_write(baseTokenReserves);

        // forgefmt: disable-next-item
        stdstore
            .target(address(p))
            .sig("balanceOf(address)")
            .with_key(address(p))
            .checked_write(fractionalTokenReserves);

        // act
        uint256 price = p.price();

        // assert
        assertEq(price, expectedPrice, "Price does not match");
    }

    function testPriceHas18DecimalsOfPrecision() public {
        // arrange
        uint256 baseTokenReserves = 0.12345e6; // 6 decimal token (e.g. USDC)
        uint256 fractionalTokenReserves = 1e18; // 18 decimal fractional token
        uint256 expectedPrice = 0.12345e18; // 0.12345 to 18 decimal places of accuracy

        // forgefmt: disable-next-item
        stdstore
            .target(address(usd))
            .sig("balanceOf(address)")
            .with_key(address(p))
            .checked_write(baseTokenReserves);

        // forgefmt: disable-next-item
        stdstore
            .target(address(p))
            .sig("balanceOf(address)")
            .with_key(address(p))
            .checked_write(fractionalTokenReserves);

        // act
        uint256 price = p.price();

        // assert
        assertEq(price, expectedPrice, "Price does not match");
    }
}
