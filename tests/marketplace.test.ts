// test/marketplace.test.ts
import { expect } from "chai";
import "@nomicfoundation/hardhat-ethers";
import "@nomicfoundation/hardhat-chai-matchers";
import { ethers }  from "hardhat";

describe("Marketplace System", function() {
    let marketplace: any;
    let loyaltyToken: any;
    let reviewSystem: any;
    let owner: any;
    let seller: any;
    let buyer: any;
    let price: bigint;

    beforeEach(async function() {
        [owner, seller, buyer] = await ethers.getSigners();
        price = ethers.parseEther("1.0");

        const LoyaltyToken = await ethers.getContractFactory("LoyaltyToken");
        loyaltyToken = await LoyaltyToken.deploy();

        const ReviewSystem = await ethers.getContractFactory("ReviewSystem");
        reviewSystem = await ReviewSystem.deploy();

        const Marketplace = await ethers.getContractFactory("Marketplace");
        marketplace = await Marketplace.deploy(
          await loyaltyToken.getAddress(),
          await reviewSystem.getAddress()
        )
        // Grant minter role to marketplace
        await loyaltyToken.transferOwnership(await marketplace.getAddress());
    });

    describe("Listing Operations", function() {
        it("Should create a listing", async function() {
            const tx = await marketplace.connect(seller).createListing(
              price,
              "ipfs://test"
            );
            console.log("1")
            expect(tx)

            const listing = await marketplace.listings(0);
            expect(listing.seller).to.equal(seller.address);
            expect(listing.price).to.equal(price);
            expect(listing.isActive).to.be.true;
        });

        it("Should buy a listing", async function() {
            await marketplace.connect(seller).createListing(price, "ipfs://test");
            
            const tx = await marketplace.connect(buyer).buyListing(0, {
              value: price
            });

            await expect(tx)
                .to.emit(marketplace, "ListingSold")
                .withArgs(0, buyer.address, price);

            const listing = await marketplace.listings(0);
            expect(listing.isActive).to.be.false;
        });

        it("Should cancel a listing", async function() {
            await marketplace.connect(seller).createListing(price, "ipfs://test");
            
            const tx = await marketplace.connect(seller).cancelListing(0);
            
            await expect(tx)
                .to.emit(marketplace, "ListingCancelled")
                .withArgs(0);

            const listing = await marketplace.listings(0);
            expect(listing.isActive).to.be.false;
        });
    });

    describe("Review System", function() {
        beforeEach(async function() {
            await marketplace.connect(seller).createListing(price, "ipfs://test");
            await marketplace.connect(buyer).buyListing(0, { value: price });
        });

        it("Should add a review", async function() {
            const tx = await reviewSystem.connect(buyer).addReview(
                0,
                5,
                "Great product!"
            );

            await expect(tx)
                .to.emit(reviewSystem, "ReviewAdded")
                .withArgs(0, buyer.address, 5);

            const reviews = await reviewSystem.getListingReviews(0);
            expect(reviews[0].rating).to.equal(5);
            expect(reviews[0].reviewer).to.equal(buyer.address);
        });

        it("Should prevent double reviews", async function() {
            await reviewSystem.connect(buyer).addReview(0, 5, "Great!");
            
            await expect(
                reviewSystem.connect(buyer).addReview(0, 4, "Good!")
            ).to.be.revertedWith("Already reviewed");
        });
    });

    describe("Loyalty Token", function() {
        it("Should mint loyalty tokens on purchase", async function() {
            await marketplace.connect(seller).createListing(price, "ipfs://test");
            await marketplace.connect(buyer).buyListing(0, { value: price });

            const loyaltyReward = (price * BigInt(100)) / BigInt(10000); // 1%
            const balance = await loyaltyToken.balanceOf(buyer.address);
            expect(balance).to.equal(loyaltyReward);
        });
    });

    describe("Error Cases", function() {
        it("Should fail with zero price", async function() {
            await expect(
                marketplace.connect(seller).createListing(0, "ipfs://test")
            ).to.be.revertedWith("Price must be greater than 0");
        });

        it("Should fail when buying own listing", async function() {
            await marketplace.connect(seller).createListing(price, "ipfs://test");
            
            await expect(
                marketplace.connect(seller).buyListing(0, { value: price })
            ).to.be.revertedWith("Cannot buy own listing");
        });

        it("Should fail with incorrect payment", async function() {
            await marketplace.connect(seller).createListing(price, "ipfs://test");
            
            await expect(
                marketplace.connect(buyer).buyListing(0, { 
                    value: price - BigInt(1) 
                })
            ).to.be.revertedWith("Incorrect price");
        });
    });
});