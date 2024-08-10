// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "./Mytoken_HelPet.sol";

contract LostDogReward {
    struct Claim {
        address claimant;
        bool isClaimed;
        bool isConfirmed;
    }
    
    struct Reward {
        uint256 amount;
        address owner;
        address confirmedClaimant;
        bool isActive;
        mapping(address => Claim) claims;
        address[] claimantList;
    }

    mapping(uint256 => Reward) public rewards;
    uint256 public rewardCounter;
    uint256 public constant CANCEL_FEE_PERCENT = 3; // Tarifa de cancelación del 3%

    HelpetToken public helpetToken; // Dirección del contrato del token HPT
    uint256 public postTokenAmount; // Monto fijo de tokens HPT para la persona que publica la búsqueda
    uint256 public rescueTokenAmount; // Monto fijo de tokens HPT para la persona que rescata al perro

    enum TimePeriod { Week, Month }
    TimePeriod public postingPeriod;
    uint256 public maxPosts; // Número máximo de posteos permitidos por período

    mapping(address => uint256) public postCount;
    mapping(address => uint256) public lastPostTimestamp;

    event RewardCreated(uint256 rewardId, address owner, uint256 amount);
    event ClaimSubmitted(uint256 rewardId, address claimant);
    event ClaimConfirmed(uint256 rewardId, address claimant);
    event RewardPaid(uint256 rewardId, address claimant, uint256 amount);
    event RewardCancelled(uint256 rewardId, address owner, uint256 refundedAmount);

    constructor(
        address _tokenAddress,
        uint256 _postTokenAmount,
        uint256 _rescueTokenAmount,
        uint256 _maxPosts,
        TimePeriod _postingPeriod
    ) {
        helpetToken = HelpetToken(_tokenAddress);
        postTokenAmount = _postTokenAmount;
        rescueTokenAmount = _rescueTokenAmount;
        maxPosts = _maxPosts;
        postingPeriod = _postingPeriod;
    }

    receive() external payable {}

    function createReward(uint256 amount) external {
        require(amount > 10, "Reward amount must be greater than 10");

        uint256 currentTime = block.timestamp;
        uint256 resetTime = postingPeriod == TimePeriod.Week ? 1 weeks : 4 weeks;

        // Reset post count if period has passed
        if (currentTime > lastPostTimestamp[msg.sender] + resetTime) {
            postCount[msg.sender] = 0;
            lastPostTimestamp[msg.sender] = currentTime;
        }

        require(postCount[msg.sender] < maxPosts, "Post limit reached for this period");

        rewardCounter++;
        Reward storage reward = rewards[rewardCounter];
        reward.amount = amount;
        reward.owner = msg.sender;
        reward.isActive = true;

        postCount[msg.sender]++;

        // Recompensa con tokens HPT por publicar la búsqueda
        helpetToken.mint(msg.sender, postTokenAmount);

        emit RewardCreated(rewardCounter, msg.sender, amount);
    }

    function submitClaim(uint256 rewardId) external {
        Reward storage reward = rewards[rewardId];
        require(reward.isActive, "Reward is not active");
        require(!reward.claims[msg.sender].isClaimed, "Claim already submitted");

        reward.claims[msg.sender] = Claim({
            claimant: msg.sender,
            isClaimed: true,
            isConfirmed: false
        });
        
        reward.claimantList.push(msg.sender);

        emit ClaimSubmitted(rewardId, msg.sender);
    }

    function confirmClaim(uint256 rewardId, address claimant) external {
        Reward storage reward = rewards[rewardId];
        require(msg.sender == reward.owner, "Only the owner can confirm");
        require(reward.isActive, "Reward is not active");
        require(reward.claims[claimant].isClaimed, "Claim does not exist");
        require(!reward.claims[claimant].isConfirmed, "Claim already confirmed");

        reward.claims[claimant].isConfirmed = true;
        reward.confirmedClaimant = claimant;
        
        // Pago automático de la recompensa y entrega de tokens HPT al rescatista
        uint256 rewardAmount = reward.amount;
        uint256 paymentAmount = (rewardAmount * (100 - CANCEL_FEE_PERCENT)) / 100;
        
        reward.isActive = false;
        payable(claimant).transfer(paymentAmount);

        // Entrega de tokens HPT al rescatista
        helpetToken.mint(claimant, rescueTokenAmount);

        emit ClaimConfirmed(rewardId, claimant);
        emit RewardPaid(rewardId, claimant, paymentAmount);
    }

    function cancelReward(uint256 rewardId) external {
        Reward storage reward = rewards[rewardId];
        require(msg.sender == reward.owner, "Only the owner can cancel the reward");
        require(reward.isActive, "Reward is not active");
        require(reward.confirmedClaimant == address(0), "Cannot cancel after a claim has been confirmed");

        uint256 rewardAmount = reward.amount;
        uint256 refundAmount = (rewardAmount * (100 - CANCEL_FEE_PERCENT)) / 100;

        reward.isActive = false;
        payable(reward.owner).transfer(refundAmount);

        emit RewardCancelled(rewardId, reward.owner, refundAmount);
    }
}
