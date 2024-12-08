// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract EnglishAuction is ReentrancyGuard {
    // Struct to store auction details
    struct Auction {
        address nft;                // Address of the NFT contract
        uint256 nftId;              // Token ID of the NFT
        address payable seller;     // Seller of the NFT
        uint256 highestBid;         // Highest bid so far
        address highestBidder;      // Address of the highest bidder
        uint32 endAt;               // End time of the auction
        bool started;               // Whether the auction has started
        bool ended;                 // Whether the auction has ended
        mapping(address => uint256) bids; // Track bids by address
    }

    // Struct to store lightweight auction info for active auctions
    struct ActiveAuctionInfo {
        uint256 auctionId;          // ID of the auction
        address nft;                // Address of the NFT contract
        uint256 nftId;              // Token ID of the NFT
        uint32 endAt;               // End time of the auction
        uint256 highestBid;         // Current highest bid
        address payable seller;
    }

    mapping(uint256 => Auction) public auctions;      // All auctions
    uint256 public auctionCounter;                    // Auction ID counter
    ActiveAuctionInfo[] public activeAuctions;        // Track active auctions with detailed info

    // Events
    event AuctionCreated(uint256 auctionId, address indexed nft, uint256 indexed nftId, uint256 startingBid);
    event BidPlaced(uint256 auctionId, address indexed bidder, uint256 amount);
    event AuctionEnded(uint256 auctionId, address winner, uint256 amount);

    constructor() ReentrancyGuard() {}

    /**
     * @dev Creates a new auction for an NFT.
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

        // Add detailed auction info to active auctions
        activeAuctions.push(
            ActiveAuctionInfo({
                auctionId: auctionCounter,
                nft: _nft,
                nftId: _nftId,
                endAt: auction.endAt,
                highestBid: _startingBid,
                seller: payable(msg.sender)
            })
        );

        IERC721(_nft).transferFrom(msg.sender, address(this), _nftId);

        emit AuctionCreated(auctionCounter, _nft, _nftId, _startingBid);
    }

    /**
     * @dev Ends an auction.
     */
    function endAuction(uint256 auctionId) external nonReentrant {
        Auction storage auction = auctions[auctionId];
        require(auction.started, "Auction not started");
        require(!auction.ended, "Auction already ended");
        // require(block.timestamp >= auction.endAt, "Auction not yet ended");
        require(msg.sender == auction.seller, "Only seller can end auction");

        auction.ended = true;

        if (auction.highestBidder != address(0)) {
            IERC721(auction.nft).transferFrom(address(this), auction.highestBidder, auction.nftId);
            auction.seller.transfer(auction.highestBid);
        } else {
            IERC721(auction.nft).transferFrom(address(this), auction.seller, auction.nftId);
        }

        // Remove from active auctions
        for (uint256 i = 0; i < activeAuctions.length; i++) {
            if (activeAuctions[i].auctionId == auctionId) {
                activeAuctions[i] = activeAuctions[activeAuctions.length - 1];
                activeAuctions.pop();
                break;
            }
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

         // Update activeAuctions entry
        for (uint256 i = 0; i < activeAuctions.length; i++) {
            if (activeAuctions[i].auctionId == auctionId) {
                activeAuctions[i].highestBid = msg.value;
                break;
            }
    }

    emit BidPlaced(auctionId, msg.sender, msg.value);
    }

    /**
     * @dev Returns all active (unended) auctions with detailed information.
     */
    function getActiveAuctions() external view returns (ActiveAuctionInfo[] memory) {
        return activeAuctions;
    }
}
