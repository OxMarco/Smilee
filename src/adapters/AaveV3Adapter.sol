// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IPool} from "@aave/v3-core/contracts/interfaces/IPool.sol";
import {IPoolAddressesProvider} from "@aave/v3-core/contracts/interfaces/IPoolAddressesProvider.sol";
import {IAToken} from "@aave/v3-core/contracts/interfaces/IAToken.sol";
import {IAdapter} from "../interfaces/IAdapter.sol";

contract AaveV3Adapter is IAdapter {
    using SafeERC20 for IERC20;

    IERC20 public immutable baseAsset;
    IPool public immutable lendingPool;
    IAToken public immutable aToken;

    constructor(
        address _baseAsset,
        address _poolAddressesProvider
    ) {
        baseAsset = IERC20(_baseAsset);

        // Get the Lending Pool from the provider
        IPoolAddressesProvider provider = IPoolAddressesProvider(_poolAddressesProvider);
        lendingPool = IPool(provider.getPool());

        // Get the corresponding AToken address
        address aTokenAddress = lendingPool.getReserveData(_baseAsset).aTokenAddress;
        aToken = IAToken(aTokenAddress);
    }

    function asset() external view override returns(address) {
        return address(baseAsset);
    }

    function side() external view override returns(address) {
        return address(aToken);
    }

    function balance(address target) external view override returns (uint256) {
        return aToken.balanceOf(target);
    }

    function manage(int256 amount, bytes memory) external override {
        if (amount > 0) {
            uint256 depositAmount = uint256(amount);
            if(baseAsset.allowance(address(this), address(lendingPool)) < depositAmount)
                baseAsset.approve(address(lendingPool), depositAmount);

            //baseAsset.safeTransferFrom(msg.sender, address(this), depositAmount);
            lendingPool.deposit(address(baseAsset), depositAmount, address(this), 0);
        } else if (amount < 0) {
            uint256 withdrawAmount = uint256(-amount);
            lendingPool.withdraw(address(baseAsset), withdrawAmount, address(this));
        }
    }

    function collateralise(int256, bytes memory) external override {
        // TBD
    }
}
