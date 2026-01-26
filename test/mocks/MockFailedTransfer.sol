// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ERC20Mock} from "./ERC20Mock.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract MockFailedTransfer is ERC20Mock, Ownable {
    constructor() ERC20Mock("Mock Failed Transfer", "MFT", msg.sender, 0) Ownable(msg.sender) {}

    function transfer(address, uint256) public pure override returns (bool) {
        return false;
    }
}
