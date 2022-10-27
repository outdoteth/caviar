// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "solmate/tokens/ERC20.sol";
import "solmate/utils/Math.sol";

contract Pair {
    uint256 constant ONE = 1e18;
    address immutable nft;
    address immutable baseToken;

    constructor(address _nft, address _baseToken) {
        nft = _nft;
        baseToken = _baseToken;
    }

    function add(
        uint256 baseTokenAmount,
        uint256 fractionalTokenAmount,
        uint256 minBaseTokenOutputAmount,
        uint256 minFractionalTokenOutputAmount
    ) public {}

    function price() public view returns (uint256) {
        uint256 baseTokenBalance = ERC20(baseToken).balanceOf(address(this));
        uint256 fractionalTokenBalance = ERC20(address(this)).balanceOf(address(this));

        return (baseTokenBalance * ONE) / fractionalTokenBalance;
    }
}
