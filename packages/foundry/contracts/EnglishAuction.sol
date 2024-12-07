// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract EnglishAuction is ReentrancyGuard {
    struct Auction {
        address nft; // Address of the NFT contract
        uint256 nftId; // Token ID of the NFT
        address payable seller; // Seller of the NFT
        uint256 highestBid; // Highest bid so far
        address highestBidder; // Address of the highest bidder
        uint32 endAt; // End time of the auction
        bool started; // Whether the auction has started
        bool ended; // Whether the auction has ended
        mapping(address => uint256) bids; // Track bids by address
    }

    mapping(uint256 => Auction) public auctions;
    uint256 public auctionCounter;

    event AuctionCreated(uint256 auctionId, address indexed nft, uint256 indexed nftId, uint256 startingBid);
    event BidPlaced(uint256 auctionId, address indexed bidder, uint256 amount);
    event AuctionEnded(uint256 auctionId, address winner, uint256 amount);

    constructor() ReentrancyGuard() {}

    /**
     * @dev Create a new auction. Any user can call this function.
     * @param _nft Address of the ERC721 NFT contract.
     * @param _nftId Token ID of the NFT to be auctioned.
     * @param _startingBid Minimum bid to start the auction.
     * @param _duration Duration of the auction in seconds.
     */
    function createNftAuction(
        address _nft,
        uint256 _nftId,
        uint256 _startingBid,
        uint32 _duration
    ) external {
        require(_nft != address(0), "Invalid NFT address");
        require(_duration > 0, "Invalid duration");

        auctionCounter++;
        Auction storage auction = auctions[auctionCounter];
        auction.nft = _nft;
        auction.nftId = _nftId;
        auction.seller = payable(msg.sender);
        auction.highestBid = _startingBid;
        auction.endAt = uint32(block.timestamp + _duration);
        auction.started = true;

        // Transfer the NFT to this contract
        IERC721(_nft).transferFrom(msg.sender, address(this), _nftId);

        emit AuctionCreated(auctionCounter, _nft, _nftId, _startingBid);
    }

    /**
     * @dev Place a bid on an auction.
     * @param auctionId The ID of the auction.
     */
    function bid(uint256 auctionId) external payable nonReentrant {
        Auction storage auction = auctions[auctionId];
        require(auction.started, "Auction not started");
        require(block.timestamp < auction.endAt, "Auction ended");
        require(msg.value > auction.highestBid, "Bid too low");

        if (auction.highestBidder != address(0)) {
            auction.bids[auction.highestBidder] += auction.highestBid;
        }

        auction.highestBid = msg.value;
        auction.highestBidder = msg.sender;

        emit BidPlaced(auctionId, msg.sender, msg.value);
    }

    /**
     * @dev End an auction and transfer the NFT to the highest bidder.
     * @param auctionId The ID of the auction.
     */
    function endAuction(uint256 auctionId) external nonReentrant {
        Auction storage auction = auctions[auctionId];
        require(auction.started, "Auction not started");
        require(!auction.ended, "Auction already ended");
        require(block.timestamp >= auction.endAt, "Auction not yet ended");
        require(msg.sender == auction.seller, "Only seller can end auction");

        auction.ended = true;

        if (auction.highestBidder != address(0)) {
            IERC721(auction.nft).transferFrom(address(this), auction.highestBidder, auction.nftId);
            auction.seller.transfer(auction.highestBid);
        } else {
            IERC721(auction.nft).transferFrom(address(this), auction.seller, auction.nftId);
        }

        emit AuctionEnded(auctionId, auction.highestBidder, auction.highestBid);
    }

    /**
     * @dev Withdraw funds for outbid bidders.
     * @param auctionId The ID of the auction.
     */
    function withdraw(uint256 auctionId) external nonReentrant {
        Auction storage auction = auctions[auctionId];
        uint256 amount = auction.bids[msg.sender];
        require(amount > 0, "No funds to withdraw");

        auction.bids[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
}
