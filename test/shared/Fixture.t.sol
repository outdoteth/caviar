// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";

import "../../src/Caviar.sol";
import "../../src/Pair.sol";
import "./mocks/MockERC721.sol";
import "./mocks/MockERC20.sol";

contract Fixture is Test {
    MockERC721 public bayc;
    MockERC20 public usd;
    LpToken public lpToken;

    Caviar public c;
    Pair public p;

    address public babe = address(0xbabe);

    constructor() {
        c = new Caviar();

        bayc = new MockERC721("yeet", "YEET");
        usd = new MockERC20("us dollar", "USD");

        p = c.create(address(bayc), address(usd));
        lpToken = LpToken(p.lpToken());

        vm.label(babe, "babe");
        vm.label(address(c), "caviar");
        vm.label(address(bayc), "bayc");
        vm.label(address(usd), "usd");
        vm.label(address(p), "pair");
        vm.label(address(lpToken), "LP-token");
    }
}
