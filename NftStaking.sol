// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract ERC721Staking is ReentrancyGuard {

    using SafeERC20 for IERC20;
    
    // Interface for ERC20 and ERC721 token
    IERC20 public immutable rewardToken;
    IERC721 public immutable nftCollection;

    // Constructor to set the rewards token and nft collection
    constructor(IERC721 _nftCollection, IERC20 _rewardToken) {
        nftCollection = _nftCollection;
        rewardToken = _rewardToken;
    }

    // Struct to store staked token
    struct StakedToken {
        address staker;
        uint256 tokenId;
    } 

    // Struck to store staker info
    struct Staker {
        uint256 amountStaked;
        StakedToken[] stakedTokens;
        uint256 timeOfLastUpdate;
        uint256 unclaimedRewards;
    }

    uint256 private rewardsPerHour = 100000;
    mapping(address => Staker) public stakers;
    mapping(uint256 => address) public stakerAddress;

    // Function to stake token
    function stakeToken(uint256 _tokenId) external nonReentrant {

        if(stakers[msg.sender].amountStaked > 0) {
            uint256 pendingRewards = calculateRewards(msg.sender);
            stakers[msg.sender].unclaimedRewards += pendingRewards;
        }

        require(nftCollection.ownerOf(_tokenId) == msg.sender, "You dont't own this token");

        nftCollection.transferFrom(msg.sender, address(this), _tokenId); 

        StakedToken memory stakedToken = StakedToken(msg.sender, _tokenId);

        stakers[msg.sender].stakedTokens.push(stakedToken);

        stakers[msg.sender].amountStaked ++;

        stakerAddress[_tokenId] = msg.sender;

        stakers[msg.sender].timeOfLastUpdate = block.timestamp;
    }
}