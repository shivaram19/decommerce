// SPDX-License-Identifier:MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IEscrow.sol";

contract Escrow is IEscrow, ReentrancyGuard, Ownable {
    uint256 private _escrowIds;
    
    mapping(uint256 => EscrowData) private escrows;
    mapping(address => uint256[]) private buyerEscrows;
    mapping(address => uint256[]) private sellerEscrows;
    
    uint256 public constant DISPUTE_TIMELOCK = 7 days;
    uint256 public constant AUTO_RELEASE_TIME = 14 days;
    
    constructor() Ownable(msg.sender) {}

    function createEscrow(address seller, uint256 listingId) 
        external 
        payable 
        override 
        returns (uint256) 
    {
        require(msg.value > 0, "Amount must be greater than 0");
        require(seller != address(0) && seller != msg.sender, "Invalid seller");
        
        uint256 escrowId = _escrowIds++;
        
        EscrowData memory newEscrow = EscrowData({
            id: escrowId,
            buyer: msg.sender,
            seller: seller,
            amount: msg.value,
            listingId: listingId,
            status: Status.Funded,
            createdAt: block.timestamp,
            completedAt: 0
        });
        
        escrows[escrowId] = newEscrow;
        buyerEscrows[msg.sender].push(escrowId);
        sellerEscrows[seller].push(escrowId);
        
        emit EscrowCreated(escrowId, msg.sender, seller, msg.value);
        emit EscrowFunded(escrowId, msg.value);
        
        return escrowId;
    }

    function releaseEscrow(uint256 escrowId) 
        external 
        override 
        nonReentrant 
    {
        EscrowData storage escrow = escrows[escrowId];
        require(escrow.buyer == msg.sender, "Only buyer can release");
        require(escrow.status == Status.Funded, "Invalid status");
        
        escrow.status = Status.Released;
        escrow.completedAt = block.timestamp;
        
        (bool success, ) = payable(escrow.seller).call{value: escrow.amount}("");
        require(success, "Transfer failed");
        
        emit EscrowReleased(escrowId, escrow.amount);
    }

    function refundEscrow(uint256 escrowId) 
        external 
        override 
        nonReentrant 
    {
        EscrowData storage escrow = escrows[escrowId];
        require(
            msg.sender == escrow.seller || 
            block.timestamp >= escrow.createdAt + AUTO_RELEASE_TIME,
            "Not authorized or timelock active"
        );
        require(escrow.status == Status.Funded, "Invalid status");
        
        escrow.status = Status.Refunded;
        escrow.completedAt = block.timestamp;
        
        (bool success, ) = payable(escrow.buyer).call{value: escrow.amount}("");
        require(success, "Transfer failed");
        
        emit EscrowRefunded(escrowId, escrow.amount);
    }

    function disputeEscrow(uint256 escrowId) 
        external 
        override 
    {
        EscrowData storage escrow = escrows[escrowId];
        require(
            msg.sender == escrow.buyer || msg.sender == escrow.seller,
            "Not authorized"
        );
        require(escrow.status == Status.Funded, "Invalid status");
        require(
            block.timestamp <= escrow.createdAt + DISPUTE_TIMELOCK,
            "Dispute period ended"
        );
        
        escrow.status = Status.Disputed;
        emit EscrowDisputed(escrowId, msg.sender);
    }

    function resolveDispute(uint256 escrowId, bool releaseToSeller) 
        external 
        override 
        onlyOwner 
        nonReentrant 
    {
      EscrowData storage escrow = escrows[escrowId];
      require(escrow.status == Status.Disputed, "Not disputed");
      
      address payable recipient = releaseToSeller ? 
          payable(escrow.seller) : 
          payable(escrow.buyer);
          
      escrow.status = releaseToSeller ? Status.Released : Status.Refunded;
      escrow.completedAt = block.timestamp;
      
      (bool success, ) = recipient.call{value: escrow.amount}("");
      require(success, "Transfer failed");
      
      if (releaseToSeller) {
        emit EscrowReleased(escrowId, escrow.amount);
      } else {
        emit EscrowRefunded(escrowId, escrow.amount);
      }
    }

    function getEscrow(uint256 escrowId) 
        external 
        view 
        override 
        returns (EscrowData memory) 
    {
        return escrows[escrowId];
    }

    function getEscrowsByBuyer(address buyer) 
        external 
        view 
        override 
        returns (uint256[] memory) 
    {
        return buyerEscrows[buyer];
    }

    function getEscrowsBySeller(address seller) 
        external 
        view 
        override 
        returns (uint256[] memory) 
    {
        return sellerEscrows[seller];
    }
}