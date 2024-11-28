// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;


interface IMarketPlace{
  struct Listing{
    uint256 id;
    address seller;
    uint256 price;
    string ipfsMetadataHash;
    bool isActive;
    uint256 createdAt;
  }

  event ListingCreated(
    uint256 indexed listingId,
    address indexed seller,
    uint256 price
  );
  event ListingSold(
    uint256 indexed listingId,
    address indexed buyer,
    uint256 price
  );
  event ListingCancelled(
    uint256 indexed listingId
  );

  function createListing(uint256 price, string memory ipfsMetadataHash)external returns (uint256);
  function buyListing(uint256 listingId) external payable;
  function cancelListing(uint256 listingId) external;
  function getSellerListings(address seller) external view returns (uint256[] memory);

}