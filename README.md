# 🚀 CrowdFund-DeFi

A decentralized crowdfunding smart contract that ensures transparency and trust by using Chainlink price feeds to validate the USD value of contributions.

---

## 🧰 Tech Stack

- **Solidity (v0.8.18+)** — smart contract programming  
- **Chainlink Price Feeds** — for real-time ETH/USD conversion  
- **Foundry** — for compiling, testing, and deploying smart contracts  
- **JavaScript / Node.js** *(optional)* — for deployment automation  
- **Ethers.js / Hardhat** *(optional)* — for integration testing or frontend interaction  

---

## 🎯 Purpose / Problem Solved

Traditional crowdfunding platforms rely on centralized intermediaries, which can lead to trust issues, delayed withdrawals, or manipulation.  

**CrowdFund-DeFi** solves this by allowing anyone to contribute ETH transparently, ensuring:  
- Each contribution meets a minimum USD value (checked in real time).  
- Funds can only be withdrawn by the contract owner.  
- Every funder’s contribution is stored on-chain for full visibility.  
- Even direct ETH transfers are handled safely.  

This project demonstrates **trustless crowdfunding** powered by **DeFi principles**.

---

## ⚙️ How It Works

1. **Price Feed Integration:**  
   The contract connects to a Chainlink ETH/USD price feed to get the latest exchange rate. This ensures contributions are valued accurately in USD terms, not just ETH amounts.

2. **Funding Logic (`fund()`):**  
   - A user calls `fund()` and sends ETH.  
   - The contract checks if the sent ETH equals or exceeds the minimum USD requirement.  
   - If valid, the sender’s address and amount are recorded in mappings and arrays.

3. **Receiving ETH Directly:**  
   - If someone sends ETH directly without calling `fund()`, the contract automatically triggers `fund()` through `receive()` or `fallback()` functions.  
   - This ensures no ETH is lost or stuck.

4. **Withdrawal (`withdraw()` / `cheaperWithdraw()`):**  
   - Only the contract owner can withdraw all accumulated funds.  
   - The contract resets funders’ balances and sends the full balance to the owner’s wallet.  
   - The `cheaperWithdraw()` function uses optimized gas logic for efficiency.

5. **Price Update (`setPriceFeed()`):**  
   - Allows the owner to update the price feed address if needed (for example, when deploying on different networks).

---

## 🚦 How to Run / Test on a Testnet

### 1️⃣ Install Dependencies  
```
forge install
forge build
```

### 2️⃣ Configure Environment
Create a .env file and include:
```
PRIVATE_KEY=<your_wallet_private_key>
RPC_URL=<your_testnet_rpc_url>
```

### 3️⃣ Deploy to Testnet
```
forge script script/DeployFundMe.s.sol \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast
```
### 4️⃣ Interact with the Contract


Use Foundry scripts, Remix, or Etherscan.


Send ETH using `fund()`.


Call `withdraw()` as the contract owner.


### 5️⃣ Run Tests
```
forge test --fork-url $RPC_URL
```


## 💡 What I Learned / Challenges Overcome


Real-time data integration: Learning how to use Chainlink’s price feed oracle for live ETH/USD pricing.


Gas optimization: Reducing transaction costs using immutable, constant, and efficient loops.


Security best practices: Implementing onlyOwner modifiers and custom errors.


DeFi contract design: Handling edge cases like direct ETH transfers.


Deployment setup: Configuring testnets, private keys, and scripts for smooth deployment.

## 🧠 Future Improvements

. Add time-based funding goals or deadlines

. Enable multiple campaigns per contract

. Integrate frontend UI using Next.js or React + Ethers.js

. Add automated fund release based on milestones

## 📘 Summary
CrowdFund-DeFi showcases the power of on-chain transparency and trustless funding.
It’s a perfect foundation for anyone learning how to build real-world DeFi applications that interact with price oracles and handle ETH securely.


💬 Feel free to contribute, fork, or suggest improvements. Let’s keep building open and decentralized systems together.


