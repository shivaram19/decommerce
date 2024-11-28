// SPDX-License-Identifier:MIT
pragma solidity ^0.8.19;


interface ILoyaltyToken {
  function mint(address to , uint256 amount) external;
  function burn(address from , uint256 amount) external;
}