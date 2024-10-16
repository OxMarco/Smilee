// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IOracle} from "./interfaces/IOracle.sol";

contract Oracle is IOracle {
    Allocation[] private allocations;

    function addAllocation(ActionType action, address token, int256 amount, address adapter) external {
        allocations.push(Allocation(action, token, amount, adapter, block.timestamp));
    }

    function changeAllocation(uint256 index, ActionType action, address token, int256 amount, address adapter) external {
        require(index < allocations.length, "Invalid index");
        allocations[index] = Allocation(action, token, amount, adapter, block.timestamp);
    }

    function removeAllocation(uint256 index) external {
        assert(index < allocations.length);

        allocations[index] = allocations[allocations.length - 1];
        allocations.pop();
    }

    function get() external view override returns (Allocation[] memory) {
        return allocations;
    }
}
