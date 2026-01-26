// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";

contract MockFailedMintDSC is DecentralizedStableCoin {
    function mint(address, uint256) external pure override returns (bool) {
        return false;
    }
}
