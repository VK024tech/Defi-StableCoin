// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract MockMoreDebtDSC is DecentralizedStableCoin {
    address public priceFeed;

    constructor(address _priceFeed) {
        priceFeed = _priceFeed;
    }

    function mint(address account, uint256 amount) external override returns (bool) {
        // Mint double the amount
        _mint(account, amount * 2);
        return true;
    }
}
