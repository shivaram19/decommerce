import { expect } from "chai";
import "@nomicfoundation/hardhat-ethers";
import "@nomicfoundation/hardhat-chai-matchers";
import { ethers }  from "hardhat";

describe("review system contract ",() => {
  // listingId => list a product
  let reviewSystem : any;
  let marketplace : any;
  let owner : any;
  let seller : any;
  let buyer : any;
  let price : bigint;

  beforeEach(async () => {
    [owner, buyer, seller] = await ethers.getSigners();
    price = ethers.parseEther("1.0");
    
    const Marketplace = await ethers.getContractFactory("MarketPlace");
    marketplace = await Marketplace.deploy();
    const marketplacedeploytxn = await Marketplace.getDeployTransaction();
    console.log(marketplacedeploytxn);


    const ReviewSystem = await ethers.getContractFactory("ReviewSystem");
    reviewSystem = await ReviewSystem.deploy();

    
  })
})