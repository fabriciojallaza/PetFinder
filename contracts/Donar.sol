// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Register.sol";
import "./IHelpetToken.sol";

contract Donar {
    HelpetToken private helPetToken = HelpetToken(0xE6e5aF029ed89Bf93D80Baea93BCBd9350dbFfb8);
    Register private register = Register(0x181A6c2359A39628415aB91bD99306c2927DfAb9);

    address payable constant DONATION_FEE_ADDRESS = payable(0x3a15D6F3F4c0557fC51753cAc56d5D01B4a5c71A);

    struct Post {
        string description;
        string vetLocation;
        string sightingLocation;
        address payable poster;
        string dogImage;
        uint256 amountRaised;
        bool isClosed;
    }

    constructor(){
        helPetToken.setRewardContract(address(this));
    }

    uint256 private nextPostId = 0;
    mapping(uint256 => Post) private posts;

    event PostCreated(uint256 indexed postId, address indexed poster);
    event DonationMade(uint256 indexed postId, address indexed donor, uint256 amount, uint256 tokenAmount);
    event PostClosed(uint256 indexed postId);

    modifier onlyVerifiedEntity() {
        (bool isRegistered, bool isVerified) = register.isEntityRegistered(msg.sender);
        require(isRegistered && isVerified, "Not a verified entity");
        _;
    }

    modifier onlyVerified() {
        (bool isRegistered, bool isVerified) = register.isPersonRegistered(msg.sender);
        require(isRegistered && isVerified, "Not verified");
        _;
    }

    function createPost(
        string memory _description,
        string memory _vetLocation,
        string memory _sightingLocation,
        string memory _dogImage
    ) public onlyVerifiedEntity {
        uint256 postId = nextPostId++;

        posts[postId] = Post({
            description: _description,
            vetLocation: _vetLocation,
            sightingLocation: _sightingLocation,
            poster: payable(msg.sender),
            dogImage: _dogImage,
            amountRaised: 0,
            isClosed: false
        });

        emit PostCreated(postId, msg.sender);
    }

    function donate(uint256 _postId) public payable onlyVerified {
        Post storage post = posts[_postId];
        require(!post.isClosed, "Post is closed");
        require(msg.value > 0, "Donation must be greater than 0");

        uint256 donationFee = (msg.value * 3) / 100;
        uint256 amountToPoster = msg.value - donationFee;

        require(amountToPoster > 0, "Donation amount too low");

        post.amountRaised += amountToPoster;

        (bool sentToPoster, ) = post.poster.call{value: amountToPoster}("");
        require(sentToPoster, "Failed to send Ether to poster");

        (bool sentFee, ) = DONATION_FEE_ADDRESS.call{value: donationFee}("");
        require(sentFee, "Failed to send Ether to donation fee address");

        helPetToken.mint(msg.sender, 1);
        emit DonationMade(_postId, msg.sender, msg.value, 1);
    }

    function closePost(uint256 _postId) public {
        Post storage post = posts[_postId];
        require(post.poster == msg.sender, "Only the poster can close the post");
        require(!post.isClosed, "Post is already closed");

        post.isClosed = true;
        emit PostClosed(_postId);
    }

    function getPost(uint256 _postId) public view returns (
        string memory description,
        string memory vetLocation,
        string memory sightingLocation,
        address poster,
        string memory dogImage,
        uint256 amountRaised,
        bool isClosed
    ) {
        Post storage post = posts[_postId];
        return (
            post.description,
            post.vetLocation,
            post.sightingLocation,
            post.poster,
            post.dogImage,
            post.amountRaised,
            post.isClosed
        );
    }

    function getTotalDonated(uint256 _postId) public view returns (uint256) {
        Post storage post = posts[_postId];
        return post.amountRaised;
    }
}
