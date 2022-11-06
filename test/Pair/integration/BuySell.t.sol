// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../../shared/Fixture.t.sol";
import "../../../src/Caviar.sol";

contract BuyTest is Fixture {
    uint256 public outputAmount = 1e18;

    function setUp() public {
        uint256 baseTokenAmount = 100e18;
        uint256 fractionalTokenAmount = 100e18;

        deal(address(usd), address(this), baseTokenAmount, true);
        deal(address(p), address(this), fractionalTokenAmount, true);

        usd.approve(address(p), type(uint256).max);

        uint256 minLpTokenAmount = baseTokenAmount * fractionalTokenAmount;
        p.add(baseTokenAmount, fractionalTokenAmount, minLpTokenAmount);

        deal(address(ethPair), address(this), fractionalTokenAmount, true);
        ethPair.add{value: baseTokenAmount}(baseTokenAmount, fractionalTokenAmount, minLpTokenAmount);
    }

    function testBuySellInvariant() public {
        // buy the amount
        // uint256 maxInputAmount = p.buyQuote(outputAmount);
        // deal(address(usd), address(this), maxInputAmount, true);
        // p.buy(outputAmount, maxInputAmount);

        // // sell the same amount
        // console.log("f bal:", p.balanceOf(address(this)));
        // uint256 minOutputAmount = p.sellQuote(outputAmount);
        // uint256 ethOutputAmount = p.sell(outputAmount, minOutputAmount);

        // // assert
        // assertEq(
        //     usd.balanceOf(address(this)), ((maxInputAmount * 994009) / 1000000), "Should have returned input amount"
        // );
    }
}
