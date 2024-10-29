// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IInfraredGauge {
    function stake(uint256 amount) external;
    function withdraw(uint256 _shareAmt) external;
    function getReward() external;
}
