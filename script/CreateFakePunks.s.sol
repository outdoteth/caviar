// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "ERC721A/ERC721A.sol";

contract FakePunks is ERC721A {
    constructor() ERC721A("Fake Wrapped Cryptopunks", "FWPUNKS") {}

    function mint(address to, uint256 quantity) public {
        _mint(to, quantity);
    }

    function tokenURI(uint256 tokenId) public pure override returns (string memory) {
        return string(abi.encodePacked("https://wrappedpunks.com:3000/api/punks/metadata/", _toString(tokenId)));
    }
}

contract CreateFakePunksScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        FakePunks fakePunks = new FakePunks();
        console.log("fake punks:");
        console.log(address(fakePunks));

        fakePunks.mint(msg.sender, 250);
        fakePunks.mint(msg.sender, 250);
        fakePunks.mint(msg.sender, 250);
        fakePunks.mint(msg.sender, 250);
        fakePunks.mint(msg.sender, 250);
        fakePunks.mint(msg.sender, 250);
    }
}
