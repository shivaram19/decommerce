# Decentralized Marketplace

A Web3 marketplace enabling secure P2P buying and selling with cryptocurrency.

## Installation

### Prerequisites
- Node.js (v16+)
- npm/yarn
- MetaMask wallet

### Setup Steps
```bash
# Clone repository
git clone [repo-url]
cd [repo-name]

# Install dependencies
npm install

# Create environment file
cp .env.example .env
# Add keys to .env:
# INFURA_KEY=
# PRIVATE_KEY=
# ETHERSCAN_API_KEY=

# Compile contracts
npx hardhat compile

# Run tests
npx hardhat test

# Deploy locally
npx hardhat node
npx hardhat run scripts/deploy.ts --network localhost
```

## Architecture

```mermaid
graph TD
   A[User Connects Wallet] --> B[Browse Marketplace]
   
   B --> C[Create Listing]
   B --> D[View Listings]
   
   C --> C1[Set Price]
   C1 --> C2[Upload to IPFS]
   C2 --> C3[Create Contract Listing]
   
   D --> E[Buy Item]
   D --> F[View Reviews]
   
   E --> E1[Pay via ETH]
   E1 --> E2[Create Escrow]
   E2 --> E3[Wait Delivery]
   
   E3 --> E4[Release Escrow]
   E3 --> E5[Dispute]
   
   E4 --> G[Get Loyalty Tokens]
   E4 --> H[Write Review]
   
   E5 --> E6[Admin Resolution]
   E6 --> E7[Release/Refund]
   
   F --> F1[View Rating]
   F --> F2[Check Verified Status]

```

## Features

### ✅ Completed
- [x] Core smart contracts
 - Marketplace: Product listing and buying
 - Escrow: Secure payment handling
 - Reviews: Verified feedback system
 - LoyaltyToken: ERC20 rewards
- [x] Testing & Security
 - Unit tests
 - Integration tests
 - Security features
 - Contract verification
- [x] Loyalty System
 - Token minting
 - Reward distribution
 - Balance tracking

### 🚧 Upcoming
- [ ] Frontend Build
 - React components
 - Web3 integration
 - Wallet connection
- [ ] IPFS Integration
 - Product metadata
 - Image storage
- [ ] User Features
 - Profiles
 - Dashboard
 - Search/Filter
 - Mobile support


