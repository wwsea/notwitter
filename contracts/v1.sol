pragma solidity ^0.4.24;

contract NoTwitter{
    struct UserProfile{
        uint headId;
        string name;
    }
    struct FeedItem{
        address  sender;
        uint64   commentNum;
        uint64   postTime;
        uint128  parentId;
        uint     resourceId;
        string   message;
    }

    uint public constant MAX_POST_FEE = 20 finney; // 0.02 ether
    uint64 public constant MAX_COMMENT = 10;

    FeedItem[] private feeds;
    mapping (address => UserProfile) public userProfileOf;
    address public owner;
    uint public postFee = MAX_POST_FEE;

    modifier onlyOwner {
        assert(owner == msg.sender);
        _;
    }

    constructor() public {
        owner = msg.sender;
    }
    
    function setPostFee(uint _postFee) onlyOwner public {
        require(_postFee <= MAX_POST_FEE);
        postFee = _postFee;
    }

    function flushEther() public {
	require(this.balance > 0);
	owner.call.value(this.balance)();
    }

    function postFeed(string _message, uint128 _parentId,  uint256 _resourceId) payable public {
        require(msg.value >= postFee);
        
        if (_parentId > 0) {
           require(_parentId <= feeds.length); // id == index + 1

           FeedItem storage parentItem = feeds[_parentId - 1];
           ++parentItem.commentNum;
           require(parentItem.commentNum <= MAX_COMMENT);
        }
        
        
        FeedItem memory newItem;
        newItem.sender = msg.sender;
        newItem.parentId = _parentId;
        newItem.postTime = uint64(now);
        newItem.message = _message;
        newItem.resourceId = _resourceId;
        feeds.push(newItem);
        
        // TODO: log event
    }
    
    function getLastFeedId() view public returns (uint)
    {
	return feeds.length;
    }

    function setUserProfile(uint _headId, string _name) public {
        userProfileOf[msg.sender].headId = _headId;
        userProfileOf[msg.sender].name = _name;
    }
    
    function getFeedItem(uint feedId) view public
        returns (address _sender, uint128 _parentId, uint64 _postTime, uint _resourceId, string _message)
    {
        require(feedId > 0);
        uint index = feedId - 1;
        require(index < feeds.length);
        FeedItem storage item = feeds[index];
        return (item.sender, item.parentId, item.postTime, item.resourceId, item.message);
    }
}

