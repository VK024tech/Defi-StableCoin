// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {DecentralizedStableCoin} from "./DecentralizedStableCoin.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/**
 * @title DSCEngine
 * @author Vivek
 * @notice This contract is the core of the Decentralized Stable Coin system.
 * This is designed to be as minimal as possible, and have the tokens maintain a 1 token == 1$ peg.
 *This stablecoin has the following properties:
 * - Exogenous Collateral (ETH, BTC)
 * - Algorithmic stable
 * - Dollar Pegged
 *
 * our dsc system should always be overcollateralized. at no point should the value of all the collateral <= the $ backed value of all the dsc.
 *
 * it is similar to DAI if DAI had no governance, no fees, and was only backed by WETH and WBTC.
 */

contract DSCEngine is ReentrancyGuard {
    ///////////////////////
    // Errors          ////
    ///////////////////////
    error DSCEngine__NeedsMoreThanZero();
    error DSCEngine__TokenAddressesAndPriceFeedsLengthMismatch();
    error DSCEngine__NotAllowedToken();
    error DSCEngine__TransferFailed();
    ///////////////////////
    // state varaibles ////
    ///////////////////////
    uint256 private constant ADDITIONAL_FEED_PRECISION = 1e10;
    uint256 private constant PRECISION = 1e18;

    mapping(address token => address priceFeed) private s_priceFeeds;
    mapping(address user => mapping(address token => uint256 amount)) private s_collateralDepposited;
    mapping(address user => uint256 amountDscMinted) private s_DSCMinted;
    address[] private s_collateralTokens;

    DecentralizedStableCoin private immutable i_dsc;

    ///////////////////////
    // Events          ////
    ///////////////////////

    event CollateralDeposited(address indexed user, address indexed token, uint256 indexed amount);

    ///////////////////////
    // Modifiers       ////
    ///////////////////////
    modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert DSCEngine__NeedsMoreThanZero();
        }
        _;
    }

    modifier isAllowedToken(address token) {
        if (s_priceFeeds[token] == address(0)) {
            revert DSCEngine__NotAllowedToken();
        }
        _;
    }

    ///////////////////////
    // Functions       ////
    ///////////////////////

    constructor(address[] memory tokenAddresses, address[] memory priceFeedAddresses, address dscAddress) {
        if (tokenAddresses.length != priceFeedAddresses.length) {
            revert DSCEngine__TokenAddressesAndPriceFeedsLengthMismatch();
        }

        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            s_priceFeeds[tokenAddresses[i]] = priceFeedAddresses[i];
            s_collateralTokens.push(tokenAddresses[i])
        }

        i_dsc = DecentralizedStableCoin(dscAddress);
    }

    ////////////////////////////////
    // External Functions       ////
    ///////////////////////////////

    function depositCollateralAndMintDsc() external {}

    /**
     *
     * @param tokenCollateralAddress The address of the collateral token (e.g., WETH, WBTC)
     * @param amountCollateral The amount of collateral to deposit
     */
    function depositCollateral(address tokenCollateralAddress, uint256 amountCollateral)
        external
        moreThanZero(amountCollateral)
        isAllowedToken(tokenCollateralAddress)
        nonReentrant
    {
        s_collateralDepposited[msg.sender][tokenCollateralAddress] += amountCollateral;
        emit CollateralDeposited(msg.sender, tokenCollateralAddress, amountCollateral);
        bool success = IERC20(tokenCollateralAddress).transferFrom(msg.sender, address(this), amountCollateral);
        if (!success) {
            revert DSCEngine__TransferFailed();
        }
    }

    function redeemCollateralForDsc() external {}

    function redeemCollateral() external {}

    /*
    *@notice follow cei
    * @param amountDscToMint the amount of Decentralized stablecoin to mint
    * @notice they must have more collateral value than the minimum threshold
    */

    function mintDsc(uint256 amountDscToMint) external moreThanZero(amountDscToMint) nonReentrant {
        s_DSCMinted[msg.sender] += amountDscToMint;

        revertIfHealthFactorIsBroken(msg.sender);
    }

    function burnDsc() external {}

    function liquidate() external {}

    function getHealthFactor() external {}

    
    ////////////////////////////////////////////////
    // Private & Internal view Functions   ////////
    //////////////////////////////////////////////

    function _getAccountInfromation(address user) private view returns(uint256 totalDscMinted, uint256 collateralValueInUSD){
        totalDscMinted = s_DSCMinted[user];
        collateralValueInUSD = getCollateralValue(user);
    }

    /*
    * Returns how close to liquidation a user is 
    * if a user goes below 1, then they can get liquidated
    */

    function _healthFactor(address user) private view returns(uint256) {
        (uint256 totalDscMinted, uint256 collateralValueInUSD) = _getAccountInfromation(user);
    }

    function _revertIfHealthFactorIsBroken(address user ) internal view {
         // 1. check health
    }

    ////////////////////////////////////////////////
    // public & External view Functions    ////////
    //////////////////////////////////////////////

    functions getAccountCollateralValue(address user) public view returns(uint256 totalCollateralValueInUSD){
        for(uint256 i = 0; i<s_collateralTokens.length; i++){
            address token = s_collateralTokens[i];
            uint256 amount = s_collateralDepposited[user][token];
            totalCollateralValueInUSD += getUsdValue(token, amount);
        }
        return totalCollateralValueInUSD;
    }

    function getUsdValue(address token, uint256 amount) public view returns(uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(s_priceFeeds[token]);
        (,int256 price,,,) = priceFeed.latestRoundData();
        return ((uint256(price) * ADDITIONAL_FEED_PRECISION) * amount) / PRECISION;
    }
}
