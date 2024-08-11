# HelPet

HelPet is a decentralized application (dApp) built on the Avalanche blockchain, designed to help users find lost dogs and facilitate donations. The application leverages smart contracts to manage lost dog posts, donations, and reward distribution. It also integrates the HelPet Token (HPT) for rewarding users and covering transaction fees.

## Features

- **Lost Dog Posts**: Users can create posts for lost dogs, including details and reward amounts.
- **Dog Finding and Verification**: Users can report found dogs and receive rewards upon verification.
- **Donations**: Users can make donations to support lost dog posts.
- **HelPet Token Integration**: HelPet Token (HPT) is used for transactions and rewards within the app.

## Smart Contracts

### 1. `HelpetToken`

- **ERC20 Token**: The HelPet Token (HPT) contract is an ERC20 token with minting and burning functions.
- **Rewards**: It allows minting of tokens to reward users and restricts transfers.

### 2. `Register`

- **User Registration**: Manages the registration and verification of individuals and entities.
- **Permission Management**: Allows permissioned users to verify or revoke verification for registered users.

### 3. `Apadrinar`

- **Post Creation**: Allows users to create posts for lost dogs.
- **Donations**: Users can donate to posts, and donations are split between the poster and a donation fee address.
- **Rewards**: Donors receive HelPet Tokens as a reward.

### 4. `Canjear`

- **Item Redemption**: Manages items that can be redeemed using HelPet Tokens.
- **Stock Management**: Allows adding items and handling stock levels.

### 5. `Donar`

- **Post Creation**: Enables entities to create posts for lost dogs.
- **Donations**: Users can donate to posts and receive HelPet Tokens as a reward.
- **Post Closure**: Allows the poster to close the post once the goal is met.

### 6. `LostDogReward`

- **Post Creation**: Users can create posts for lost dogs with a reward amount.
- **Dog Finding**: Users can report found dogs and receive a find report.
- **Reward Distribution**: Rewards are distributed upon verification of the find report.

## Deployment

1. **Compile Contracts**: Use the Solidity compiler to compile all smart contracts.
2. **Deploy Contracts**: Deploy the contracts to the Avalanche blockchain using a tool like Remix or Hardhat.

## Usage

1. **Register**: Register as an individual or entity using the `Register` contract.
2. **Create Posts**: Create lost dog posts using `Apadrinar` or `Donar`.
3. **Donate**: Make donations to support lost dog posts.
4. **Find Dogs**: Report found dogs and receive rewards upon verification.
5. **Redeem Items**: Use `Canjear` to redeem items with HelPet Tokens.

## Tokens

- **Token Name**: HelPet Token
- **Symbol**: HPT
- **Decimals**: 18

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contact

For questions or support, please contact [fabriciojallaza@gmail.com](fabriciojallaza@gmail.com).

