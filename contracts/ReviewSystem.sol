// SPDX-License-Identifier:MIT

pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";

contract ReviewSystem is Ownable {
    struct Review {
      uint256 listingId;
      address reviewer;
      uint8 rating;
      string comment;
      uint256 timestamp;
      bool verified;
      bool exists;
    }

    mapping(uint256 => Review[]) private listingReviews;
    mapping(address => mapping(uint256 => bool)) private hasReviewed;
    
    event ReviewAdded(uint256 indexed listingId, address indexed reviewer, uint8 rating);
    event ReviewVerified(uint256 indexed listingId, uint256 reviewIndex);
    
    constructor() Ownable(msg.sender) {}

    function addReview(
      uint256 listingId,
      uint8 rating,
      string memory comment
    ) external {
        require(!hasReviewed[msg.sender][listingId], "Already reviewed");
        require(rating >= 1 && rating <= 5, "Invalid rating");
        require(bytes(comment).length > 0, "Empty comment");
        
        Review memory review = Review({
          listingId: listingId,
          reviewer: msg.sender,
          rating: rating,
          comment: comment,
          timestamp: block.timestamp,
          verified: false,
          exists: true
        });
        
        listingReviews[listingId].push(review);
        hasReviewed[msg.sender][listingId] = true;
        
        emit ReviewAdded(listingId, msg.sender, rating);
    }
    
    function verifyReview(uint256 listingId, uint256 reviewIndex) external onlyOwner {
        require(reviewIndex < listingReviews[listingId].length, "Review not found");
        require(!listingReviews[listingId][reviewIndex].verified, "Already verified");
        
        listingReviews[listingId][reviewIndex].verified = true;
        emit ReviewVerified(listingId, reviewIndex);
    }
    
    function getListingReviews(uint256 listingId) external view returns (Review[] memory) {
        return listingReviews[listingId];
    }

    function getReviewCount(uint256 listingId) external view returns (uint256) {
        return listingReviews[listingId].length;
    }

    function hasUserReviewed(address user, uint256 listingId) external view returns (bool) {
        return hasReviewed[user][listingId];
    }
}