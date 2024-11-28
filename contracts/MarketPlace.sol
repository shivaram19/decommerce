// SPDX-License-Identifier:MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./interfaces/IMarketPlace.sol";
import "./LoyaltyToken.sol";
import "./ReviewSystem.sol";

contract Marketplace is IMarketPlace, Ownable, ReentrancyGuard {
    LoyaltyToken public loyaltyToken;
    ReviewSystem public reviewSystem;
    uint256 private _listingIds;
    
    mapping(uint256 => Listing) public listings;
    mapping(address => uint256[]) public sellerListings;
    
    uint256 public constant LOYALTY_REWARD_RATE = 100; // 1%
    
    constructor(address _loyaltyToken, address _reviewSystem) Ownable(msg.sender) {
        loyaltyToken = LoyaltyToken(_loyaltyToken);
        reviewSystem = ReviewSystem(_reviewSystem);
    }

    function createListing(uint256 price, string memory ipfsHash) 
        external 
        override 
        returns (uint256) 
    {
        require(price > 0, "Price must be greater than 0");
        require(bytes(ipfsHash).length > 0, "IPFS hash required");
        
        uint256 listingId = _listingIds++;
        
        listings[listingId] = Listing({
            id: listingId,
            seller: msg.sender,
            price: price,
            isActive: true,
            ipfsMetadataHash: ipfsHash,
            createdAt: block.timestamp
        });
        
        sellerListings[msg.sender].push(listingId);
        emit ListingCreated(listingId, msg.sender, price);
        return listingId;
    }

    function buyListing(uint256 listingId) 
        external 
        payable 
        override 
        nonReentrant 
    {
        Listing storage listing = listings[listingId];
        require(listing.id == listingId, "Invalid listing ID");
        require(listing.isActive, "Listing not active");
        require(msg.value == listing.price, "Incorrect price");
        require(msg.sender != listing.seller, "Cannot buy own listing");

        listing.isActive = false;
        
        uint256 loyaltyReward = (listing.price * LOYALTY_REWARD_RATE) / 10000;
        loyaltyToken.mint(msg.sender, loyaltyReward);

        (bool sent, ) = payable(listing.seller).call{value: listing.price}("");
        require(sent, "Failed to send payment");

        emit ListingSold(listingId, msg.sender, listing.price);
    }

    function cancelListing(uint256 listingId) 
        external 
        override 
    {
        Listing storage listing = listings[listingId];
        require(listing.id == listingId, "Invalid listing ID");
        require(listing.isActive, "Listing not active");
        require(msg.sender == listing.seller, "Not the seller");

        listing.isActive = false;
        emit ListingCancelled(listingId);
    }

    function getSellerListings(address seller) 
        external 
        view 
        override 
        returns (uint256[] memory) 
    {
        return sellerListings[seller];
    }
}