// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IOracle {
    struct Allocation {
        int256 amount;
        address adapter;
        uint256 timestamp;
    }

    function get() external view returns (Allocation[] memory allocations);
}
