import { ethers } from "hardhat";

async function main() {
  console.log("Deploying contracts...");

  // Deploy LoyaltyToken
  const LoyaltyToken = await ethers.getContractFactory("LoyaltyToken");
  const loyaltyToken = await LoyaltyToken.deploy();
  await loyaltyToken.waitForDeployment();
  console.log("LoyaltyToken deployed to:", await loyaltyToken.getAddress());

  // Deploy ReviewSystem
  const ReviewSystem = await ethers.getContractFactory("ReviewSystem");
  const reviewSystem = await ReviewSystem.deploy();
  await reviewSystem.waitForDeployment();
  console.log("ReviewSystem deployed to:", await reviewSystem.getAddress());

  // Deploy Marketplace
  const Marketplace = await ethers.getContractFactory("Marketplace");
  const marketplace = await Marketplace.deploy(
    await loyaltyToken.getAddress(),
    await reviewSystem.getAddress()
  );
  await marketplace.waitForDeployment();
  console.log("Marketplace deployed to:", await marketplace.getAddress());

  // Transfer LoyaltyToken ownership to Marketplace
  await loyaltyToken.transferOwnership(await marketplace.getAddress());
  console.log("LoyaltyToken ownership transferred to Marketplace");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});