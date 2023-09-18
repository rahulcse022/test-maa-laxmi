// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// 8.1 First Presale
// The first presale phase will offer 1 Billion LAXMI tokens to early contributors
// and supporters of the Maa Laxmi project.
contract Presale_1 {
    // uint256 Month = 30 days; // 60
    uint256 Month = 60;

    uint256 public lockupPeriod = 4 * Month; // Initial lock-up period
    uint256 first4Month = 4 * Month; // Duration of each release period
    uint256 next4Month = 4 * Month; // Duration of each release period

    uint256 releaseStartTime; // Timestamp when the release starts

    address public owner;
    address public TokenContract;
    uint256 public TokensForSale = 1000000000 * 1 ether; // 1 B tokens for presale 1
    uint256 public RATE; // = 1900000; //  tokens in 1 BNB.;
    uint256 public START;
    uint256 public END;
    uint256 public SOLDOUT;

    struct user {
        uint256 token; // total tokens
        uint256 eth; // total deposit eth
        uint256 releasedTokens; // claimed
    }
    mapping(address => user) public userInfo;
    event tokenBuy(uint256 _eth, uint256 _token, address _user);

    constructor(
        address _tokenContract,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _rate
    ) {
        owner = msg.sender;
        START = _startTime;
        END = _endTime;
        releaseStartTime = _endTime;
        TokenContract = _tokenContract;
        RATE = _rate;
    }

    function setSaleTime(uint256 _startTime, uint256 _endTime) public {
        require(msg.sender == owner, "Caller is not owner");
        START = _startTime;
        END = _endTime;
        releaseStartTime = _endTime;
    }

    function setRate(uint256 _rate) public {
        require(msg.sender == owner, "Caller is not owner");
        RATE = _rate;
    }

    function AvailableTokens() public view returns (uint256) {
        return (TokensForSale - SOLDOUT);
    }

    function buy() public payable {
        require(block.timestamp > START, "Sale not started yet");
        require(END > block.timestamp, "Sale time ended");
        require(msg.value > 0, "Zero BNB not allowed");
        uint256 tokens = msg.value * RATE;
        require(AvailableTokens() >= tokens, "Insufficient token to buy");

        // Fund Transfer
        payable(owner).transfer(msg.value);

        // Capture the data
        userInfo[msg.sender].token += tokens;
        userInfo[msg.sender].eth += msg.value;
        SOLDOUT += tokens;
        emit tokenBuy(msg.value, tokens, msg.sender);
    }

    function sell(uint256 _tokenAmount, address _userAddress) public {
        require(msg.sender == owner, "Caller is not owner");
        require(block.timestamp > START, "Sale not started yet");
        require(END > block.timestamp, "Sale time ended");
        
        require(_tokenAmount > 0, "Zero token amount not allowed");
        uint256 _ethAmount = _tokenAmount / RATE;
        require(AvailableTokens() >= _tokenAmount, "Insufficient token to buy");

        // Capture the data
        userInfo[_userAddress].token += _tokenAmount;
        userInfo[_userAddress].eth += _ethAmount;
        SOLDOUT += _tokenAmount;
        emit tokenBuy(_ethAmount, _tokenAmount, _userAddress);
    }

    function claim() public {
        require(block.timestamp > END, "Sale not ended");
        uint256 tokensToRelease = getAvailableTokens();
        require(tokensToRelease > 0, "No tokens available for release");
        IERC20(TokenContract).transfer(msg.sender, tokensToRelease);
        userInfo[msg.sender].releasedTokens += tokensToRelease;
    }

    function elapsedTime() public view returns (uint256) {
        return block.timestamp - releaseStartTime;
    }

    function elapsedPeriods() public view returns (uint256) {
        return (elapsedTime() - lockupPeriod + Month) / Month;
    }

    function getAvailableTokens() public view returns (uint256) {
        if (elapsedTime() < lockupPeriod) {
            return 0; // No tokens available during the lock-up period
        } else if (elapsedTime() >= lockupPeriod + first4Month + next4Month) {
            return
                userInfo[msg.sender].token -
                userInfo[msg.sender].releasedTokens; // All tokens released after 8 months
        } else {
            uint256 tokensPerPeriod = elapsedPeriods() <= 4
                ? (userInfo[msg.sender].token * 10) / 100
                : (userInfo[msg.sender].token * 15) / 100;
            uint256 availableToken;

            if (elapsedPeriods() <= 4) {
                availableToken = elapsedPeriods() * tokensPerPeriod;
            } else {
                availableToken =
                    ((4 * userInfo[msg.sender].token) / 10) +
                    (elapsedPeriods() - 4) *
                    tokensPerPeriod;
            }
            return availableToken - userInfo[msg.sender].releasedTokens;
        }
    }

    function retrieveERC20(address _tokenAddress) public {
        require(msg.sender == owner, "Caller is not owner");
        IERC20 Token = IERC20(_tokenAddress);
        uint256 _tokenBalance = Token.balanceOf(address(this));
        Token.transfer(msg.sender, _tokenBalance);
    }
    
    function transferOwnership(address _newOwner) public  {
        require(msg.sender == owner, "Caller is not owner");
        owner = _newOwner;
    }
}
