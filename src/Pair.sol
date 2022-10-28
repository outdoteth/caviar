// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "solmate/tokens/ERC20.sol";
import "solmate/tokens/ERC721.sol";
import "openzeppelin/utils/math/Math.sol";

import "./LpToken.sol";

contract Pair is ERC20, ERC721TokenReceiver {
    uint256 public constant ONE = 1e18;

    address public immutable nft;
    address public immutable baseToken;
    address public immutable lpToken;

    constructor(address _nft, address _baseToken) ERC20("Fractional token", "FT", 18) {
        nft = _nft;
        baseToken = _baseToken;
        lpToken = address(new LpToken("LP token", "LPT", 18));
    }

    // ===================== //
    // ===== AMM logic ===== //
    // ===================== //

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
        require(lpTokenAmount >= minLpTokenAmount, "Slippage: lp token amount out");

        // ~~~~~~ Effects ~~~~~~ //

        // transfer fractional tokens in
        _transferFrom(msg.sender, address(this), fractionalTokenAmount);

        // ~~~~~~ Interactions ~~~~~~ //

        // mint lp tokens to sender
        LpToken(lpToken).mint(msg.sender, lpTokenAmount);

        // transfer base tokens in
        ERC20(baseToken).transferFrom(msg.sender, address(this), baseTokenAmount);

        return lpTokenAmount;
    }

    function buy(uint256 outputAmount, uint256 maxInputAmount) public returns (uint256) {
        // calculate input amount using xyk invariant
        uint256 inputAmount = (outputAmount * baseTokenReserves()) / (fractionalTokenReserves() - outputAmount);

        // ~~~~~~ Checks ~~~~~~ //

        // check that the required amount of base tokens is less than the max amount
        require(inputAmount <= maxInputAmount, "Slippage: amount in");

        // ~~~~~~ Effects ~~~~~~ //

        // transfer fractional tokens to sender
        _transferFrom(address(this), msg.sender, outputAmount);

        // ~~~~~~ Interactions ~~~~~~ //

        // transfer base tokens in
        ERC20(baseToken).transferFrom(msg.sender, address(this), inputAmount);

        return inputAmount;
    }

    function sell(uint256 inputAmount, uint256 minOutputAmount) public returns (uint256) {
        // calculate output amount using xyk invariant
        uint256 outputAmount = (inputAmount * fractionalTokenReserves()) / (baseTokenReserves() + inputAmount);

        // ~~~~~~ Checks ~~~~~~ //

        // check that the outputted amount of fractional tokens is greater than the min amount
        require(outputAmount >= minOutputAmount, "Slippage: amount out");

        // ~~~~~~ Effects ~~~~~~ //

        // transfer fractional tokens from sender
        _transferFrom(msg.sender, address(this), inputAmount);

        // ~~~~~~ Interactions ~~~~~~ //

        // transfer base tokens out
        ERC20(baseToken).transfer(msg.sender, outputAmount);

        return outputAmount;
    }

    function remove(uint256 lpTokenAmount, uint256 minBaseTokenOutputAmount, uint256 minFractionalTokenOutputAmount)
        public
        returns (uint256, uint256)
    {
        // calculate the output amounts
        uint256 lpTokenSupply = ERC20(lpToken).totalSupply();
        uint256 baseTokenOutputAmount = (baseTokenReserves() * lpTokenAmount) / lpTokenSupply;
        uint256 fractionalTokenOutputAmount = (fractionalTokenReserves() * lpTokenAmount) / lpTokenSupply;

        // ~~~~~~ Checks ~~~~~~ //

        // check that the base token output amount is greater than the min amount
        require(baseTokenOutputAmount >= minBaseTokenOutputAmount, "Slippage: base token amount out");

        // check that the fractional token output amount is greater than the min amount
        require(fractionalTokenOutputAmount >= minFractionalTokenOutputAmount, "Slippage: fractional token amount out");

        // ~~~~~~ Effects ~~~~~~ //

        // transfer fractional tokens to sender
        _transferFrom(address(this), msg.sender, fractionalTokenOutputAmount);

        // ~~~~~~ Interactions ~~~~~~ //

        // transfer base tokens to sender
        ERC20(baseToken).transfer(msg.sender, baseTokenOutputAmount);

        // burn lp tokens from sender
        LpToken(lpToken).burn(msg.sender, lpTokenAmount);

        return (baseTokenOutputAmount, fractionalTokenOutputAmount);
    }

    // ====================== //
    // ===== Wrap logic ===== //
    // ====================== //

    function wrap(uint256[] calldata tokenIds) public returns (uint256) {
        uint256 fractionalTokenAmount = tokenIds.length * ONE;

        // ~~~~~~ Effects ~~~~~~ //

        // mint fractional tokens to sender
        _mint(msg.sender, fractionalTokenAmount);

        // ~~~~~~ Interactions ~~~~~~ //

        // transfer nfts from sender
        for (uint256 i = 0; i < tokenIds.length; i++) {
            ERC721(nft).safeTransferFrom(msg.sender, address(this), tokenIds[i]);
        }

        return fractionalTokenAmount;
    }

    function unwrap(uint256[] calldata tokenIds) public returns (uint256) {
        uint256 fractionalTokenAmount = tokenIds.length * ONE;

        // ~~~~~~ Effects ~~~~~~ //

        // burn fractional tokens from sender
        _burn(msg.sender, fractionalTokenAmount);

        // ~~~~~~ Interactions ~~~~~~ //

        // transfer nfts to sender
        for (uint256 i = 0; i < tokenIds.length; i++) {
            ERC721(nft).safeTransferFrom(address(this), msg.sender, tokenIds[i]);
        }

        return fractionalTokenAmount;
    }

    // ========================= //
    // ===== NFT AMM logic ===== //
    // ========================= //

    function nftAdd(uint256[] calldata tokenIds, uint256 baseTokenAmount, uint256 minLpTokenAmount)
        public
        returns (uint256)
    {
        uint256 fractionalTokenAmount = wrap(tokenIds);
        uint256 lpTokenAmount = add(baseTokenAmount, fractionalTokenAmount, minLpTokenAmount);

        return lpTokenAmount;
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
