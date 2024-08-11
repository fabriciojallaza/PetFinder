// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Register.sol";
import "./IHelpetToken.sol";

contract Apadrinar {
    Register private register = Register(0x7b96aF9Bd211cBf6BA5b0dd53aa61Dc5806b6AcE);
    HelpetToken private helPetToken = HelpetToken(0x540d7E428D5207B30EE03F2551Cbb5751D3c7569);

    address payable constant DONATION_FEE_ADDRESS = payable (0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);

    struct Post {
        string description;
        string vetLocation;
        uint256 amountNeeded;
        string sightingLocation;
        address payable poster;
        string dogImage;
        uint256 amountRaised;
        bool isClosed;
    }

    uint256 private nextPostId = 0;
    mapping(uint256 => Post) private posts;

    event PostCreated(uint256 indexed postId, address indexed poster, uint256 amountNeeded);
    event DonationMade(uint256 indexed postId, address indexed donor, uint256 amount, uint256 tokenAmount);
    event PostClosed(uint256 indexed postId);

    modifier onlyVerified() {
        (bool isRegistered, bool isVerified) = register.isPersonRegistered(msg.sender);
        require(isRegistered && isVerified, "Not verified");
        _;
    }

    function createPost(
        string memory _description,
        string memory _vetLocation,
        uint256 _amountNeeded,
        string memory _sightingLocation,
        string memory _dogImage
    ) public onlyVerified {
        uint256 postId = nextPostId++;

        posts[postId] = Post({
            description: _description,
            vetLocation: _vetLocation,
            amountNeeded: _amountNeeded,
            sightingLocation: _sightingLocation,
            poster: payable(msg.sender),
            dogImage: _dogImage,
            amountRaised: 0,
            isClosed: false
        });

        emit PostCreated(postId, msg.sender, _amountNeeded);
    }

    function donate(uint256 _postId) public payable onlyVerified  {
        Post storage post = posts[_postId];
        require(!post.isClosed, "Post is closed");
        require(msg.value > 0, "Donation must be greater than 0");
        require(post.amountRaised + msg.value <= post.amountNeeded, "Donation exceeds amount needed");

        uint256 donationFee = (msg.value * 3) / 100;
        uint256 amountToPoster = msg.value - donationFee;

        require(amountToPoster > 0, "Donation amount too low");

        post.amountRaised += amountToPoster;
        if (post.amountRaised >= post.amountNeeded) {
            post.isClosed = true;
            emit PostClosed(_postId);
        }

        (bool sentToPoster, ) = post.poster.call{value: amountToPoster}("");
        require(sentToPoster, "Failed to send Ether to poster");

        (bool sentFee, ) = DONATION_FEE_ADDRESS.call{value: donationFee}("");
        require(sentFee, "Failed to send Ether to donation fee address");

        helPetToken.mint(msg.sender, 1);
        emit DonationMade(_postId, msg.sender, msg.value, 1);
    }

    function getPost(uint256 _postId) public view returns (
        string memory description,
        string memory vetLocation,
        uint256 amountNeeded,
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
            post.amountNeeded,
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