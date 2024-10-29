// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IAdapter} from "./interfaces/IAdapter.sol";
import {IOracle} from "./interfaces/IOracle.sol";

contract Treasury is ERC20, Ownable {
    using SafeERC20 for IERC20;

    IERC20 public immutable baseAsset;
    IOracle public immutable oracle;
    uint256 public lastRebalance;

    event Rebalanced();

    error InsufficientLiquidity();

    constructor(address _baseAsset, address _oracle) ERC20("aaa", "AAA") Ownable(msg.sender) {
        baseAsset = IERC20(_baseAsset);
        oracle = IOracle(_oracle);
    }

    function asset() external view returns (address) {
        return address(baseAsset);
    }

    function mint(address to, uint256 amount) external {
        baseAsset.safeTransferFrom(msg.sender, address(this), amount);
        _mint(to, amount);
    }

    function burn(address to, uint256 amount) external {
        if (baseAsset.balanceOf(address(this)) < amount) revert InsufficientLiquidity();

        _burn(msg.sender, amount);
        baseAsset.safeTransfer(to, amount);
    }

    function rebalance() external {
        IOracle.Allocation[] memory allocations = oracle.get();

        uint256 length = allocations.length;
        for (uint16 i = 0; i < length; i++) {
            if (allocations[i].timestamp < lastRebalance) continue;

            // TODO should we use a delegate call or a normal call?
            (bool success,) = allocations[i].adapter.delegatecall(
                abi.encodeWithSelector(IAdapter.manage.selector, allocations[i].amount)
            );
            assert(success);
        }
        lastRebalance = block.timestamp;

        emit Rebalanced();
    }
}
