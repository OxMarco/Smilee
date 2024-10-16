// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IAdapter {
    function asset() external view returns(address);
    function side() external view returns(address);
    function balance(address target) external view returns(uint256); // portfolio balance
    function manage(int256 amount, bytes memory data) external; // allocate or deallocate
    function collateralise(int256 amount, bytes memory data) external; // borrow or repay
}
