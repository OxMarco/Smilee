// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IGauge {
    function deposit(uint256 amount, address account) external;

    function withdraw(uint256 amount) external;

    // solhint-disable-next-line func-name-mixedcase
    function claim_rewards(address account) external;

    // solhint-disable-next-line func-name-mixedcase
    function staking_token() external returns (address);
}
