// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../shared/Fixture.t.sol";

contract CreateTest is Fixture {
    event Create(address indexed nft, address indexed baseToken, bytes32 indexed merkleRoot);

    function testItReturnsPair() public {
        // arrange
        address nft = address(bayc);
        address baseToken = address(lpToken);

        // act
        address pair = address(c.create(nft, baseToken, bytes32(0)));

        // assert
        assertTrue(pair != address(0), "Should have deployed pair");
    }

    function testItSetsSymbolsAndNames() public {
        // arrange
        address nft = 0xbEEFB00b00000000000000000000000000000000;
        address baseToken = 0xCAFE000000000000000000000000000000000000;

        vm.etch(nft, address(bayc).code);
        vm.etch(baseToken, address(usd).code);

        // act
        Pair pair = c.create(nft, baseToken, bytes32(0));
        LpToken lpToken = LpToken(pair.lpToken());

        // assert
        assertEq(pair.symbol(), "f0xbeef", "Should have set fractional token symbol");
        assertEq(
            pair.name(),
            "0xbeefb00b00000000000000000000000000000000 fractional token",
            "Should have set fractional token name"
        );
        assertEq(lpToken.symbol(), "LP-0xbeef:0xcafe", "Should have set lp symbol");
        assertEq(lpToken.name(), "0xbeef:0xcafe LP token", "Should have set lp name");
    }

    function testItSavesPair() public {
        // arrange
        address nft = address(bayc);
        address baseToken = address(lpToken);
        bytes32 merkleRoot = bytes32(uint256(0xb00b));

        // act
        address pair = address(c.create(nft, baseToken, merkleRoot));

        // assert
        assertEq(c.pairs(nft, baseToken, merkleRoot), pair, "Should have saved pair address in pairs");
    }

    function testItRevertsIfDeployingSamePairTwice() public {
        // arrange
        address nft = address(bayc);
        address baseToken = address(lpToken);
        bytes32 merkleRoot = bytes32(uint256(0xb00b));
        c.create(nft, baseToken, merkleRoot);

        // act
        vm.expectRevert("Pair already exists");
        c.create(nft, baseToken, merkleRoot);
    }

    function testItEmitsCreateEvent() public {
        // arrange
        address nft = address(bayc);
        address baseToken = address(usd);
        bytes32 merkleRoot = bytes32(uint256(0xb00b));

        // act
        vm.expectEmit(true, true, true, true);
        emit Create(nft, baseToken, merkleRoot);
        c.create(nft, baseToken, merkleRoot);
    }

    function testItRevertsIfNftCodeNotSet() public {
        // arrange
        address nft = 0xbEEFB00b00000000000000000000000000000000;
        address baseToken = address(usd);

        // act
        vm.expectRevert("Invalid NFT contract");
        c.create(nft, baseToken, bytes32(0));
    }

    function testItRevertsIfBaseTokenCodeNotSet() public {
        // arrange
        address nft = address(bayc);
        address baseToken = address(0x123);

        // act
        vm.expectRevert("Invalid base token contract");
        c.create(nft, baseToken, bytes32(0));
    }
}
