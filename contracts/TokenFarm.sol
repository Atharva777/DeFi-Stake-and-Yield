//stake tokens
//unstake tokens
//issue tokens
//add allowed tokens
//get eth value function
//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract TokenFarm is Ownable{
    //some type of mapping which maps token address to staker address to the amount
    mapping(address => mapping(address => uint256)) public stakingBalance;
    mapping(address => uint256) public uniqueTokensStaked;
    mapping (address => address) public tokenPriceFeedMapping;
    address[] public stakers;
    
    address[] public allowedTokens;
    IERC20 public dappToken;

    constructor(address _dappTokenAddress) public {
        dappToken = IERC20(_dappTokenAddress);

    }

    function setPriceFeedContract(address _token, address _priceFeed) public onlyOwner{
        tokenPriceFeedMapping[_token] = _priceFeed;
    }
    
    
    
    function issueTokens() public onlyOwner {
        //issue tokens to all stakers
        for (uint256 stakersIndex = 0;
        stakersIndex < stakers.length;
        stakersIndex++){
            address recipent = stakers[stakersIndex];
            uint256 userTotalValue = getUserTotalValue(recipent);
            
            //send them a token reward based on their total value locked
            dappToken.transfer(recipent,userTotalValue );

        }
    }

    function getUserTotalValue(address _user) public view returns (uint256){
        uint256 totalValue = 0;
        require(uniqueTokensStaked[_user] > 0, "No tokens staked bruh :(");
        for (uint256 allowedTokensIndex = 0;
        allowedTokensIndex < allowedTokens.length;
        allowedTokensIndex++){
            totalValue = totalValue + getUserSingleTokenValue(_user, allowedTokens[allowedTokensIndex]);
        }
        return totalValue;

        

    }

    function getUserSingleTokenValue(address _user, address _token) public view returns (uint256) {
        //if they staked 1 eth and if its price is 2k$ then give them 2k$
        if (uniqueTokensStaked[_user] <= 0) {
            return 0;
        }

        //price of the token and then mulitply them by the staking balance of the user's token
        //price of the token * stakingBalance[_token][_user]
        (uint256 price, uint256 decimals) =getTokenValue(_token);
        return (stakingBalance[_token][_user] * price / (10 ** decimals));
    }

    function getTokenValue(address _token) public view returns (uint256, uint256) {
        //price feed address
        address priceFeedAddress = tokenPriceFeedMapping[_token];
        AggregatorV3Interface priceFeed = AggregatorV3Interface(priceFeedAddress);
        (, int256 price,,,)=priceFeed.latestRoundData();
        uint256 decimals = uint256(priceFeed.decimals());
        return (uint256(price), decimals);
    }

    
    
    
    
    
    function stakeTokens(uint256 _amount, address _token) public {
        //what tokens can be staked and how much
        require(_amount > 0, "Amount must be more than zero you broke motherfucker");
        require(tokenIsAllowed(_token), "Token is currently not allowed bitch");
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);
        updateUniqueTokensStaked(msg.sender, _token);
        stakingBalance[_token][msg.sender] = stakingBalance[_token][msg.sender] + _amount;
        if (uniqueTokensStaked[msg.sender]  ==  1){
            stakers.push(msg.sender);
        }
    }



    function unstakeTokens(address _token) public {
        uint256 balance = stakingBalance[_token][msg.sender];
        require(balance > 0, "Staking balance cannot be 0 bruhh");
        IERC20(_token).transfer(msg.sender, balance);
        stakingBalance[_token][msg.sender] = 0;
        uniqueTokensStaked[msg.sender] = uniqueTokensStaked[msg.sender] - 1;

    }

    function updateUniqueTokensStaked(address _user, address _token) internal {

        if (stakingBalance[_token][_user] <=0){
            uniqueTokensStaked[_user] = uniqueTokensStaked[_user] + 1;
        }
    }


    function addAllowedTokens(address _token) public onlyOwner {
        allowedTokens.push(_token);
    }

    function tokenIsAllowed(address _token) public returns (bool)  {
        for( uint256 allowedTokensIndex = 0; allowedTokensIndex < allowedTokens.length; allowedTokensIndex++)
         if(
             allowedTokens[allowedTokensIndex] == _token){
                 return true;
            }
            return false;
    }
}