// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "solmate/auth/Owned.sol";
import "solmate/tokens/ERC20.sol";

contract LpToken is Owned, ERC20 {
    constructor(string memory _name, string memory _symbol, uint8 _decimals)
        Owned(msg.sender)
        ERC20(_name, _symbol, _decimals)
    {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}
