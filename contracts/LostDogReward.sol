// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Register.sol";
import "./IHelpetToken.sol";

contract LostDogReward {
    Register private register = Register(0x7b96aF9Bd211cBf6BA5b0dd53aa61Dc5806b6AcE);
    HelpetToken private helPetToken = HelpetToken(0x540d7E428D5207B30EE03F2551Cbb5751D3c7569);

    address payable constant DONATION_FEE_ADDRESS = payable(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);

    struct Post {
        string dogImage;
        string dogName;
        string sightingLocation;
        uint256 rewardAmount; // Amount in wei
        address payable poster;
        bool isClosed;
        bool isVerified; // To track if the dog has been verified
        uint256 findReportId; // ID for the find report
    }

    struct FindReport {
        address finder;
        uint256 postId;
        bool isVerified; // To track if the find report has been verified
    }

    constructor() {
        helPetToken.setRewardContract(address(this));
    }

    uint256 private nextPostId = 0;
    uint256 private nextFindReportId = 0;

    mapping(uint256 => Post) private posts;
    mapping(uint256 => FindReport) private findReports;

    event PostCreated(uint256 indexed postId, address indexed poster, uint256 rewardAmount);
    event DogFound(uint256 indexed findReportId, uint256 indexed postId, address indexed finder);
    event RewardDistributed(uint256 indexed findReportId, uint256 indexed postId, address indexed finder, uint256 rewardAmount, uint256 feeAmount);
    event PostClosed(uint256 indexed postId);

    modifier onlyVerified() {
        (bool isRegistered, bool isVerified) = register.isPersonRegistered(msg.sender);
        require(isRegistered && isVerified, "Not verified");
        _;
    }

    function createPost(
        string memory _dogImage,
        string memory _dogName,
        string memory _sightingLocation
    ) public onlyVerified payable {
        require(msg.value > 0, "Reward amount must be greater than 0");

        uint256 postId = nextPostId++;

        posts[postId] = Post({
            dogImage: _dogImage,
            dogName: _dogName,
            sightingLocation: _sightingLocation,
            rewardAmount: msg.value,
            poster: payable(msg.sender),
            isClosed: false,
            isVerified: false,
            findReportId: 0 // Initialize findReportId to 0
        });

        emit PostCreated(postId, msg.sender, msg.value);
    }

    function findDog(uint256 _postId) public onlyVerified returns (uint256) {
        Post storage post = posts[_postId];
        require(!post.isClosed, "Post is closed");
        require(!post.isVerified, "Post is already verified");

        uint256 findReportId = nextFindReportId++;
        findReports[findReportId] = FindReport({
            finder: msg.sender,
            postId: _postId,
            isVerified: false
        });

        post.findReportId = findReportId;

        emit DogFound(findReportId, _postId, msg.sender);
        return findReportId;
    }

    function verifyDog(uint256 _findReportId, bool _isVerified) public {
        FindReport storage findReport = findReports[_findReportId];
        Post storage post = posts[findReport.postId];

        require(post.poster == msg.sender, "Only the poster can verify the find");
        require(!findReport.isVerified, "Find report is already verified");

        if (_isVerified) {
            uint256 donationFee = (post.rewardAmount * 3) / 100;
            uint256 amountToFinder = post.rewardAmount - donationFee;

            require(address(this).balance >= post.rewardAmount, "Insufficient balance in contract");

            (bool sentToFinder, ) = findReport.finder.call{value: amountToFinder}("");
            require(sentToFinder, "Failed to send Ether to finder");

            (bool sentFee, ) = DONATION_FEE_ADDRESS.call{value: donationFee}("");
            require(sentFee, "Failed to send Ether to donation fee address");

            helPetToken.mint(findReport.finder, 1);

            emit RewardDistributed(_findReportId, findReport.postId, findReport.finder, amountToFinder, donationFee);
        } else {
            // Keep the post open if not verified
            post.isVerified = false;
            findReport.isVerified = false;
        }

        emit PostClosed(findReport.postId); // Use post.postId here
    }

    function closePost(uint256 _postId) public {
        Post storage post = posts[_postId];
        require(post.poster == msg.sender, "Only the poster can close the post");
        require(!post.isClosed, "Post is already closed");

        if (address(this).balance >= post.rewardAmount) {
            (bool sentToPoster, ) = post.poster.call{value: post.rewardAmount}("");
            require(sentToPoster, "Failed to send Ether back to the poster");
        }

        post.isClosed = true;
        emit PostClosed(_postId);
    }

    function getPost(uint256 _postId) public view returns (
        string memory dogImage,
        string memory dogName,
        string memory sightingLocation,
        uint256 rewardAmount,
        address poster,
        bool isClosed,
        bool isVerified,
        uint256 findReportId
    ) {
        Post storage post = posts[_postId];
        return (
            post.dogImage,
            post.dogName,
            post.sightingLocation,
            post.rewardAmount,
            post.poster,
            post.isClosed,
            post.isVerified,
            post.findReportId
        );
    }

    function getFindReport(uint256 _findReportId) public view returns (
        address finder,
        uint256 postId,
        bool isVerified
    ) {
        FindReport storage findReport = findReports[_findReportId];
        return (
            findReport.finder,
            findReport.postId,
            findReport.isVerified
        );
    }
}