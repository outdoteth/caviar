// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "solmate/tokens/ERC20.sol";
import "openzeppelin/utils/math/Math.sol";

import "./LpToken.sol";

contract Pair is ERC20 {
    uint256 constant ONE = 1e18;

    address immutable nft;
    address immutable baseToken;
    address immutable lpToken;

    constructor(address _nft, address _baseToken) ERC20("Fractional token", "FT", 18) {
        nft = _nft;
        baseToken = _baseToken;

        lpToken = address(new LpToken("LP token", "LPT", 18));
    }

    function add(uint256 baseTokenAmount, uint256 fractionalTokenAmount, uint256 minLpTokenAmount) public {
        // calculate the lp token shares to mint
        uint256 lpTokenSupply = ERC20(lpToken).totalSupply();
        uint256 baseTokenShare = (baseTokenAmount * lpTokenSupply) / baseTokenReserves();
        uint256 fractionalTokenShare = (fractionalTokenAmount * lpTokenSupply) / fractionalTokenReserves();
        uint256 lpTokenAmount = Math.min(baseTokenShare, fractionalTokenShare);

        // check that the amount of lp tokens outputted is greater than the min amount
        require(lpTokenAmount >= minLpTokenAmount, "Slippage: Insufficent lp token output amount");

        // mint lp tokens to sender
        LpToken(lpToken).mint(msg.sender, lpTokenAmount);

        // transfer fractional tokens in
        transferFrom(msg.sender, address(this), fractionalTokenAmount);

        // transfer base tokens in
        ERC20(baseToken).transferFrom(msg.sender, address(this), baseTokenAmount);
    }

    function baseTokenReserves() public view returns (uint256) {
        return ERC20(baseToken).balanceOf(address(this));
    }

    function fractionalTokenReserves() public view returns (uint256) {
        return balanceOf[address(this)];
    }

    function price() public view returns (uint256) {
        uint256 baseTokenBalance = ERC20(baseToken).balanceOf(address(this));
        uint256 fractionalTokenBalance = ERC20(address(this)).balanceOf(address(this));

        return (baseTokenBalance * ONE) / fractionalTokenBalance;
    }
}
