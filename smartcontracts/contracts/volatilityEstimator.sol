// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol"; // Import Chainlink's AggregatorV3Interface
import "./math.sol";

contract Volatility {

    int256 public lastVolatility;
    int256 public decayFactor = 10000000;
    int256 public lastPrice;
    int256 public newPrice;
    address public priceFeedAddress; // Address of Chainlink Price Feed
    
    constructor(
        int256 price,
        int256 volatility,
        address FeedAddress
    ){
        lastPrice = price;
        newPrice = price;
        lastVolatility = volatility;
        priceFeedAddress = FeedAddress;
    }

    // Allows the owner to update the asset price and funding rate
    function updatePrice(int256 _newPrice) public {
        lastPrice = newPrice;
        newPrice = _newPrice * int256(MathVol.decimals);
    }

    // Function to update the asset price from Chainlink's Price Feed
    function updatePriceFromChainlink() public {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(priceFeedAddress);
        (, int256 price, , , ) = priceFeed.latestRoundData();
        lastPrice = newPrice;
        newPrice = price;

    }

    function computeVolatility() public returns(int256){
        int256 delta = newPrice - lastPrice;
        int256 instantVolatility = MathVol.multiply(delta, delta);
        lastVolatility = MathVol.multiply(instantVolatility, decayFactor) + 
            MathVol.multiply(lastVolatility, int256(MathVol.decimals) - decayFactor);
        return lastVolatility;
    }     

    

}