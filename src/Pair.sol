// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "solmate/tokens/ERC20.sol";
import "openzeppelin/utils/math/Math.sol";

import "./LpToken.sol";

contract Pair is ERC20 {
    uint256 public constant ONE = 1e18;

    address public immutable nft;
    address public immutable baseToken;
    address public immutable lpToken;

    constructor(address _nft, address _baseToken) ERC20("Fractional token", "FT", 18) {
        nft = _nft;
        baseToken = _baseToken;
        lpToken = address(new LpToken("LP token", "LPT", 18));
    }

    // ====================== //
    // ===== Core logic ===== //
    // ====================== //

    function add(uint256 baseTokenAmount, uint256 fractionalTokenAmount, uint256 minLpTokenAmount)
        public
        returns (uint256)
    {
        // calculate the lp token shares to mint
        uint256 lpTokenSupply = ERC20(lpToken).totalSupply();
        uint256 lpTokenAmount;
        if (lpTokenSupply > 0) {
            uint256 baseTokenShare = (baseTokenAmount * lpTokenSupply) / baseTokenReserves();
            uint256 fractionalTokenShare = (fractionalTokenAmount * lpTokenSupply) / fractionalTokenReserves();
            lpTokenAmount = Math.min(baseTokenShare, fractionalTokenShare);
        } else {
            // if there is no liquidity then init
            lpTokenAmount = baseTokenAmount * fractionalTokenAmount;
        }

        // ~~~~~~ Checks ~~~~~~ //

        // check that the amount of lp tokens outputted is greater than the min amount
        require(lpTokenAmount >= minLpTokenAmount, "Slippage: Insufficient lp token output amount");

        // ~~~~~~ Effects ~~~~~~ //

        // transfer fractional tokens in
        _transferFrom(msg.sender, address(this), fractionalTokenAmount);

        // ~~~~~~ Interactions ~~~~~~ //

        // transfer base tokens in
        ERC20(baseToken).transferFrom(msg.sender, address(this), baseTokenAmount);

        // mint lp tokens to sender
        LpToken(lpToken).mint(msg.sender, lpTokenAmount);

        return lpTokenAmount;
    }

    function buy(uint256 outputAmount, uint256 maxInputAmount) public returns (uint256) {
        uint256 inputAmount = (outputAmount * baseTokenReserves()) / (fractionalTokenReserves() - outputAmount);

        // ~~~~~~ Checks ~~~~~~ //

        // check that the required amount of base tokens is less than the max amount
        require(inputAmount <= maxInputAmount, "Slippage: amount in is too large");

        // ~~~~~~ Effects ~~~~~~ //

        // transfer fractional tokens to sender
        _transferFrom(address(this), msg.sender, outputAmount);

        // ~~~~~~ Interactions ~~~~~~ //

        // transfer base tokens in
        ERC20(baseToken).transferFrom(msg.sender, address(this), inputAmount);

        return inputAmount;
    }

    // =================== //
    // ===== Getters ===== //
    // =================== //

    function baseTokenReserves() public view returns (uint256) {
        return ERC20(baseToken).balanceOf(address(this));
    }

    function fractionalTokenReserves() public view returns (uint256) {
        return balanceOf[address(this)];
    }

    function buyQuote(uint256 outputAmount) public view returns (uint256) {
        return (outputAmount * baseTokenReserves()) / (fractionalTokenReserves() - outputAmount);
    }

    function price() public view returns (uint256) {
        uint256 baseTokenBalance = ERC20(baseToken).balanceOf(address(this));
        uint256 fractionalTokenBalance = ERC20(address(this)).balanceOf(address(this));

        return (baseTokenBalance * ONE) / fractionalTokenBalance;
    }

    // ========================== //
    // ===== Internal utils ===== //
    // ========================== //

    function _transferFrom(address from, address to, uint256 amount) internal returns (bool) {
        balanceOf[from] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }
}
