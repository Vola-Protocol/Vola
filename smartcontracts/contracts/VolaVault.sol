//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@aave/core-v3/contracts/interfaces/IPool.sol";

contract VolaVault is ERC4626, Ownable{
    mapping(address => uint256) public shareHolders;
    uint256 public totalLiquidity;
    uint256 public reserveLiquidiy;

    constructor(
        ERC20 _asset,
        string memory _name,
        string memory _symbol
    ) ERC4626(_asset) ERC20(_name, _symbol){}

    /**
     * @notice function to deposit assets and receive vault tokens in exchange
     * @param _assets amount of the asset token
     */
    function _deposit(uint _assets) public {
        require(_assets > 0, "Deposit less than Zero");
        uint256 amountDeposited = deposit(_assets, msg.sender);
        shareHolders[msg.sender] = shareHolders[msg.sender] + amountDeposited;
        totalLiquidity = totalLiquidity + amountDeposited;
    }

    /**
     * @notice Function to allow msg.sender to withdraw their deposit plus accrued interest
     * @param _shares amount of shares the user wants to convert
     * @param _receiver address of the user who will receive the assets
     */
    function _withdraw(uint _shares, address _receiver) public {
        require(_shares > 0, "withdraw must be greater than Zero");
        require(_receiver != address(0), "Zero Address");
        require(shareHolders[msg.sender] >= _shares, "Not enough shares");

        // Calculate the maximum withdrawable shares based on the percentage of liquidity contributed by the user
        uint256 maxWithdrawable = (shareHolders[msg.sender] * (totalLiquidity - reserveLiquidiy)) / totalLiquidity;

        require(_shares <= maxWithdrawable, "Exceeds maximum withdrawable amount");

        redeem(_shares, _receiver, msg.sender);
        shareHolders[msg.sender] -= _shares;
        totalLiquidity -= _shares;
    }

    /**
    * @notice function to reserve assets
    * @param _assets amount of the asset token to be reserved
    */
    function _reserve_liquidity(uint _assets) public onlyOwner {
        require(_assets > 0, "Reserve amount must be greater than Zero");
        require(_assets <= totalLiquidity, "Not enough liquidity in the vault");

        // Update reserve liquidity and total liquidity
        reserveLiquidiy = reserveLiquidiy + _assets;
        totalLiquidity = totalLiquidity - _assets;
    }

    /**
    * @notice Function to release reserved liquidity back into the vault
    * @param _assets amount of the asset token to be released
    */
    function _release_liquidity(uint _assets) public onlyOwner {
        require(_assets > 0, "Release amount must be greater than Zero");
        require(_assets <= reserveLiquidiy, "Not enough reserved liquidity");

        // Update reserve liquidity and total liquidity
        reserveLiquidiy = reserveLiquidiy - _assets;
        totalLiquidity = totalLiquidity + _assets;
    }

    /**
     * @notice Returns the total balance of a user
     * @param _user Address of the user
     */
    function totalAssetsOfUser(address _user) public view returns (uint256) {
        return shareHolders[_user];
    }

    function _decimalsOffset() internal pure override returns (uint8) {
        return 3;
    }

}