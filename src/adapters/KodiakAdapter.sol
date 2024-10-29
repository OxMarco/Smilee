// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IAdapter} from "../interfaces/IAdapter.sol";
import {IKodiakV1RouterStaking} from "../interfaces/external/kodiak/IKodiakV1RouterStaking.sol";
import {IKodiakVaultV1} from "../interfaces/external/kodiak/IKodiakVaultV1.sol";
import {IInfraredGauge} from "../interfaces/external/infrared/IInfraredGauge.sol";

contract KodiakAdapter is IAdapter {
    using SafeERC20 for IERC20;

    IERC20 public immutable baseAsset;
    IERC20 public immutable sideAsset;
    IERC20 public immutable pool;
    IKodiakV1RouterStaking public immutable router;
    IKodiakVaultV1 public immutable kodiakVault;
    IInfraredGauge public immutable infraredGauge;

    constructor(address _baseAsset, address _kodiakVault, address _router, address _infraredGauge) {
        baseAsset = IERC20(_baseAsset);
        kodiakVault = IKodiakVaultV1(_kodiakVault);

        if (kodiakVault.token0() == baseAsset) sideAsset = kodiakVault.token1();
        else sideAsset = kodiakVault.token0();

        pool = IERC20(address(kodiakVault.pool()));
        router = IKodiakV1RouterStaking(_router);
        infraredGauge = IInfraredGauge(_infraredGauge);

        pool.approve(_infraredGauge, type(uint256).max);
    }

    function kind() external pure returns (string memory) {
        return "Kodiak finance";
    }

    function asset() external view override returns (address) {
        return address(baseAsset);
    }

    function lpToken() external view override returns (address) {
        return address(pool);
    }

    function balance(address target) external view override returns (uint256) {
        return pool.balanceOf(target);
    }

    function manage(int256 amount, bytes memory data) external override {
        if (amount > 0) {
            uint256 depositAmount = uint256(amount);
            baseAsset.safeTransferFrom(msg.sender, address(this), depositAmount);

            (uint256 amount0Max, uint256 amount1Max, uint256 amount0Min, uint256 amount1Min, uint256 amountSharesMin) =
                abi.decode(data, (uint256, uint256, uint256, uint256, uint256));

            // TODO swap in from base asset to side asset

            if (baseAsset.allowance(address(this), address(router)) < amount0Max) {
                baseAsset.approve(address(router), amount0Max);
            }

            if (sideAsset.allowance(address(this), address(router)) < amount1Max) {
                sideAsset.approve(address(router), amount1Max);
            }

            router.addLiquidity(
                kodiakVault, amount0Max, amount1Max, amount0Min, amount1Min, amountSharesMin, address(this)
            );
        } else if (amount < 0) {
            (uint256 burnAmount, uint256 amount0Min, uint256 amount1Min) = abi.decode(data, (uint256, uint256, uint256));

            router.removeLiquidity(kodiakVault, burnAmount, amount0Min, amount1Min, address(this));

            // TODO swap out from side asset to base asset
        }
    }

    function withExtraRewards() external view returns (address[] memory tokens) {}

    function sweepExtraRewards(address[] memory) external view returns (uint256[] memory) {}
}
