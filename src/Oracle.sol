// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IOracle} from "./interfaces/IOracle.sol";

contract Oracle is IOracle {
    uint256 public constant SCALING_FACTOR = 10_000;
    Allocation[] private allocations;

    error InvalidIndex();
    error InvalidAddress();

    function addAllocation(int256 amount, address adapter) external {
        if (adapter == address(0)) revert InvalidAddress();

        allocations.push(Allocation(amount, adapter, block.timestamp));
    }

    function changeAllocation(uint256 index, int256 amount, address adapter) external {
        if (index > allocations.length) revert InvalidIndex();
        if (adapter == address(0)) revert InvalidAddress();

        allocations[index] = Allocation(amount, adapter, block.timestamp);
    }

    function removeAllocation(uint256 index) external {
        if (index > allocations.length) revert InvalidIndex();

        allocations[index] = allocations[allocations.length - 1];
        allocations.pop();
    }

    function get() external view override returns (Allocation[] memory) {
        return allocations;
    }
}
