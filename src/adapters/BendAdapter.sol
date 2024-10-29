// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IPool} from "@aave/v3-core/contracts/interfaces/IPool.sol";
import {IPoolAddressesProvider} from "@aave/v3-core/contracts/interfaces/IPoolAddressesProvider.sol";
import {IAToken} from "@aave/v3-core/contracts/interfaces/IAToken.sol";
import {IAdapter} from "../interfaces/IAdapter.sol";

contract BendAdapter is IAdapter {
    using SafeERC20 for IERC20;

    IERC20 public immutable baseAsset;
    IPool public immutable lendingPool;
    IAToken public immutable aToken;

    constructor(address _baseAsset, address _pool, address _aToken) {
        baseAsset = IERC20(_baseAsset);

        /*
        IPoolAddressesProvider provider = IPoolAddressesProvider(_poolAddressesProvider);
        lendingPool = IPool(provider.getPool());
        address aTokenAddress = lendingPool.getReserveData(_baseAsset).aTokenAddress;
        aToken = IAToken(aTokenAddress);
        */

        lendingPool = IPool(_pool);
        aToken = IAToken(_aToken);
    }

    function kind() external pure returns (string memory) {
        return "Bend";
    }

    function asset() external view override returns (address) {
        return address(baseAsset);
    }

    function lpToken() external view override returns (address) {
        return address(aToken);
    }

    function balance(address target) external view override returns (uint256) {
        return aToken.balanceOf(target);
    }

    function manage(int256 amount, bytes memory data) external override {
        if (amount > 0) {
            uint256 depositAmount = uint256(amount);
            if (baseAsset.allowance(address(this), address(lendingPool)) < depositAmount) {
                baseAsset.approve(address(lendingPool), depositAmount);
            }

            baseAsset.safeTransferFrom(msg.sender, address(this), depositAmount);
            lendingPool.deposit(address(baseAsset), depositAmount, address(this), 0);
        } else if (amount < 0) {
            (uint256 amountOutMin) = abi.decode(data, (uint256));
            uint256 withdrawAmount = uint256(-amount);
            assert(lendingPool.withdraw(address(baseAsset), withdrawAmount, address(this)) >= amountOutMin);
        }
    }

    function withExtraRewards() external view returns (address[] memory tokens) {}

    function sweepExtraRewards(address[] memory) external view returns (uint256[] memory) {}
}
