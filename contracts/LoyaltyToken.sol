// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/ILoyaltyToken.sol";

contract LoyaltyToken is ERC20, Ownable, ILoyaltyToken {
    constructor() ERC20("Loyalty Token", "LTY") Ownable(msg.sender) {}

    function mint(address to, uint256 amount) external override onlyOwner {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external override {
        require(msg.sender == from, "Only token holder can burn");
        _burn(from, amount);
    }
}