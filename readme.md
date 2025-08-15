# Foundry — Solidity Projects (DeFi StableCoin, Raffle, NFT, FundMe)

A Foundry workspace with several Solidity projects and tests:

- **DeFi:** StableCoin (SCT) + DSCEngine (over-collateralized minting with Chainlink price feeds)
- **Smart Lottery:** Raffle using Chainlink VRF v2.5+
- **On-chain NFT:** MoodNFT with SVG metadata and mood flips
- **FundMe:** Pay-in-USD threshold (Chainlink) + small web front end  
  Demo: https://fundmepls.netlify.app/

---

## Contents

- [DeFi StableCoin (SCT) — Overview](#defi-stablecoin-sct--overview)
- [Smart Lottery (Raffle)](#smart-lottery-raffle)
- [MoodNFT](#moodnft)
- [FundMe](#fundme)
---

## DeFi StableCoin (SCT) — Overview

**Goal:** mint an ERC-20 stable coin against WETH/WBTC collateral with Chainlink USD feeds and conservative risk rules.

### Contracts

- `StableCoin.sol`  
  ERC20Burnable + Ownable token named **“StableCoint”** (`SCT`).  
  Owner-only `mint` and `burn` with basic input checks.

- `DSCEngine.sol`  
  Holds collateral and enforces risk limits.
  - Supported collateral: WETH, WBTC (addresses supplied at deploy)
  - Price feeds: Chainlink AggregatorV3 (8 decimals → scaled to 18)
  - Core flows:
    - `depositCollateral(token, amount)` → pulls tokens via `transferFrom`
    - `mintDsc(amount)` → mints SCT up to the cap
    - `burnDsc(amount)` → repays debt
    - `redeemCollateral(token, amount)` → withdraws collateral (health-factor check)
    - `depositCollateralAndMintDsc(token, amountCollateral, amountDsc)` → convenience

### Risk parameters and liquidation

| Parameter                       | Value / Rule |
|---------------------------------|--------------|
| Collateral factor (LTV)         | **50%** (you can mint up to 50% of your collateral USD value) |
| Minimum collateralization       | **200%** (collateral / debt ≥ 2.0) |
| Health factor (HF)              | `HF = (collateralUSD × 50%) / debtUSD` |
| Liquidation threshold           | `HF < 1.0` (position can be liquidated) |
| Liquidation bonus               | **10%** additional collateral to the liquidator |

**Interpretation:** a position is considered safe while `HF ≥ 1.0`. With a 50% collateral factor, users must stay at or above **200% over-collateralization** to avoid liquidation.

### “Algorithmic” mint/burn

SCT supply is controlled by **rules in `DSCEngine`**:
- Minting is permitted only within the 50% cap using live price feeds.
- Burning reduces debt and raises HF.  
This is “algorithmic” in the sense that issuance and redemption follow on-chain rules. It is **not** an uncollateralized or seigniorage system.

**Price math**  
Feeds return 8 decimals; `getUsdValue()` scales by `1e10` so all USD math uses 18 decimals.

### Deploy script

- `script/DeployEngine.s.sol`
  - Builds arrays of collateral and price feeds
  - Deploys `StableCoin` and `DSCEngine`
  - Transfers SCT ownership to the engine (engine becomes the minter)
  - Picks a public owner address by chain ID (Sepolia vs local)

---

## Smart Lottery (Raffle)

**Goal:** time-based raffle using **Chainlink VRF v2.5+** for randomness.

- `Raffle.sol`
  - `enterRaffle()` with `i_entranceFee`
  - `checkUpkeep()` / `performUpkeep()` gates by:
    - interval elapsed
    - state is OPEN
    - contract has balance
    - at least one player
  - `fulfillRandomWords()` picks a winner and transfers the full pot

**Helpers**

- `script/DeploySL.s.sol` — deploys `Raffle`
- `script/Interactions.s.sol` — create/fund subscription, add consumer  
  Uses `VRFCoordinatorV2_5Mock` on local chains.

---

## MoodNFT

**Goal:** fully on-chain SVG NFT that flips between **HAPPY** and **SAD**.

- `MoodNft.sol`
  - Stores two SVGs as base64 Data URIs
  - `mintNft()` mints sequential token IDs
  - `flipMood(tokenId)` toggles the mood (currently `onlyOwner`)
  - `tokenURI()` returns base64 JSON with the selected image

**Scripts**

- `script/DeployMoodNft.s.sol` — reads `./img/sad.svg` and `./img/happy.svg`, deploys
- `script/MintMoodNft.s.sol` — mints and flips mood

---

## FundMe

**Goal:** accept ETH only if the USD value meets a minimum **($5)** using Chainlink.

- `FundMe.sol`
  - `fund()` requires `msg.value` in USD ≥ `MINUSD`
  - `withdraw()` is owner-only
  - `PriceConverter` reads Chainlink and returns 18-decimals USD
- `script/DeployFundMe.s.sol` — deploys with an owner and feed address

**Front end**

- Static site: **https://fundmepls.netlify.app/**

---



