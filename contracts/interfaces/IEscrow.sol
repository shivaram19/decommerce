// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

interface IEscrow{
  enum Status{
    Created,
    Funded,
    Released,
    Refunded,
    Disputed
  }
  struct EscrowData {
    uint256 id;
    address buyer;
    address seller;
    uint256 amount;
    uint256 listingId;
    Status status;
    uint256 createdAt;
    uint256 completedAt;
  }
  event EscrowCreated(uint256 indexed escrowId, address buyer, address seller, uint256 amount);
  event EscrowFunded(uint256 indexed escrowId, uint256 amount);
  event EscrowReleased(uint256 indexed escrowId, uint256 amount);
  event EscrowRefunded(uint256 indexed escrowId, uint256 amount);
  event EscrowDisputed(uint256 indexed escrowId, address disputedBy);


  function createEscrow(address seller, uint256 listingId) external payable returns (uint256);
  function releaseEscrow(uint256 escrowId) external;
  function refundEscrow(uint256 escrowId) external;
  function disputeEscrow(uint256 escrowId) external;
  function resolveDispute(uint256 escrowId, bool releaseToSeller) external;
  function getEscrow(uint256 escrowId) external view returns (EscrowData memory);
  function getEscrowsByBuyer(address buyer) external view returns (uint256[] memory);
  function getEscrowsBySeller(address seller) external view returns (uint256[] memory);
}