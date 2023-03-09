// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "ERC721A/ERC721A.sol";
import "openzeppelin/token/common/ERC2981.sol";

contract FakeNft is ERC721A, ERC2981 {
    string public baseUri;
    address public immutable owner;

    constructor(string memory name, string memory symbol, string memory baseUri_) ERC721A(name, symbol) {
        baseUri = baseUri_;
        owner = msg.sender;
    }

    function mint(address to, uint256 quantity) public {
        _mint(to, quantity);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return string(abi.encodePacked(baseUri, _toString(tokenId)));
    }

    function supportsInterface(bytes4 interfaceId) public view override (ERC2981, ERC721A) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function royaltyInfo(uint256 tokenId, uint256 salePrice) public view override returns (address, uint256) {
        return (owner, salePrice * 250 / 10_000); // 2.5% royalty
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
