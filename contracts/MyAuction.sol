// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyAuction {

    event AuctionCreated(uint16 auctionId, string item, uint256 base, uint256 duration, address owner);
    event BidPlaced(uint16 auctionId, address bidder, uint256 bid);
    event AuctionEnded(uint16 auctionId, address highestBidder, uint256 highestBid);

    uint16 public counter = 0;

    mapping (uint16 => Auction) public auctions;
    mapping (address => uint256) public collections;

    struct Auction {
        string item;
        uint256 base;
        uint256 highestBid;
        address highestBidder;
        uint256 startTime;
        uint256 duration;
        bool active;
        address owner;
    }

    modifier activeAuction(uint16 _id) {
        require(auctions[_id].active == true, "The auction has ended");
        if(block.timestamp - auctions[_id].startTime > auctions[_id].duration) {
            auctions[_id].active = false;
            revert("The auction has ended due to timeout");
        }
        _;
    }

    function createAuction(string memory _item, uint256 _base, uint256 _duration) external returns(uint16) {
        auctions[counter] = Auction({
            item: _item,
            base: _base,
            highestBid: 0,
            highestBidder: address(0),
            startTime: block.timestamp,
            duration: _duration,
            active: true,
            owner: msg.sender
        });
        emit AuctionCreated(counter, _item, _base, _duration, msg.sender);
        return counter++;
    }

    function placeBid(uint16 _id) external payable activeAuction(_id) {
        Auction storage auction = auctions[_id];
        require(msg.value > auction.highestBid, "You do not have a higher bid");

        // Refund the previous highest bidder
        if (auction.highestBidder != address(0)) {
            payable(auction.highestBidder).transfer(auction.highestBid);
        }

        auction.highestBid = msg.value;
        auction.highestBidder = msg.sender;
        emit BidPlaced(_id, msg.sender, msg.value);
    }

    function endAuction(uint16 _id) external {
        Auction storage auction = auctions[_id];
        require(auction.owner == msg.sender, "You have no right to end the Auction");
        require(auction.active == true, "The auction has already ended");
        require(block.timestamp - auction.startTime > auction.duration, "Auction duration has not yet ended");

        auction.active = false;
        collections[auction.owner] += auction.highestBid;
        emit AuctionEnded(_id, auction.highestBidder, auction.highestBid);
    }

    function withdrawFunds() external {
        uint256 amount = collections[msg.sender];
        require(amount > 0, "No funds to withdraw");
        collections[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    function getAuctionDetails(uint16 _id) external view returns(Auction memory) {
        return auctions[_id];
    }
}
