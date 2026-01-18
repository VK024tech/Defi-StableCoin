// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

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

contract DSCEngine {
    ///////////////////////
    // Errors          ////
    ///////////////////////
    error DSCEngine__NeedsMoreThanZero();
    ///////////////////////
    // state varaibles ////
    ///////////////////////

    

    ///////////////////////
    // Modifiers       ////
    ///////////////////////
    modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert DSCEngine__NeedsMoreThanZero();
        }
        _;
    }

    // modifier isAllowedToken(address token) {

    // }

    ///////////////////////
    // Functions       ////
    ///////////////////////

    constructor() {}

    ////////////////////////////////
    // External Functions       ////
    ///////////////////////////////

    function depositCollateralAndMintDsc() external {}

    /**
     *
     * @param tokenCollateralAddress The address of the collateral token (e.g., WETH, WBTC)
     * @param amountCollateral The amount of collateral to deposit
     */
    function depositCollateral(
        address tokenCollateralAddress,
        uint256 amountCollateral
    ) external moreThanZero(amountCollateral) {}

    function redeemCollateralForDsc() external {}

    function redeemCollateral() external {}

    function mintDsc() external {}

    function burnDsc() external {}

    function liquidate() external {}

    function getHealthFactor() external {}
}
