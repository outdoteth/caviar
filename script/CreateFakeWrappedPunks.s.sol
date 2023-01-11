// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "ERC721A/ERC721A.sol";

contract FakeNft is ERC721A {
    string public baseUri;

    constructor(string memory name, string memory symbol, string memory baseUri_) ERC721A(name, symbol) {
        baseUri = baseUri_;
    }

    function mint(address to, uint256 quantity) public {
        _mint(to, quantity);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return string(abi.encodePacked(baseUri, _toString(tokenId)));
    }
}

contract CreateFakeNftScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        FakeNft fakeNft =
        new FakeNft(vm.envString("FAKE_NFT_NAME"), vm.envString("FAKE_NFT_SYMBOL"), vm.envString("FAKE_NFT_BASE_URI"));
        console.log("fake nft:", address(fakeNft));

        fakeNft.mint(msg.sender, 250);
        fakeNft.mint(msg.sender, 250);
        fakeNft.mint(msg.sender, 250);
        fakeNft.mint(msg.sender, 250);
    }
}
