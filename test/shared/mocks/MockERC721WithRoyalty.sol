// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "solmate/tokens/ERC721.sol";
import "openzeppelin/token/common/ERC2981.sol";

contract MockERC721WithRoyalty is ERC721, ERC2981 {
    string public baseURI = "yeet-royalty";

    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {}

    function mint(address to, uint256 id) public {
        _mint(to, id);
    }

    function tokenURI(uint256) public view override returns (string memory) {
        return baseURI;
    }

    function supportsInterface(bytes4 interfaceId) public view override (ERC2981, ERC721) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function royaltyInfo(uint256 tokenId, uint256 salePrice) public pure override returns (address, uint256) {
        return (address(0xbeefbeef), salePrice * 10 / 100);
    }
}
