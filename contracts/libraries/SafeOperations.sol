// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

library SafeOperations {
  function calculateFee(uint256 amount , uint256 feePercent) internal pure returns(uint256) {
    require(feePercent <= 10000, "Fee percent exceeds 100%");
    return (amount * feePercent) / 10000;
  }

  function getTimeExpired(uint256 startTime , uint256 duration) internal view returns(bool) {
    return block.timestamp >= startTime + duration ;
  }
}