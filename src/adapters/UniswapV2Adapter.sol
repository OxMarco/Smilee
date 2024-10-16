// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IUniswapV2Router02} from "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import {IAdapter} from "../interfaces/IAdapter.sol";

contract UniswapV2Adapter is IAdapter {
    using SafeERC20 for IERC20;

    IERC20 public immutable baseAsset;
    IERC20 public immutable lpToken;
    IUniswapV2Router02 public immutable uniswapRouter;
    IUniswapFactory public immutable uniswapFactory;

    constructor(
        address _baseAsset,
        address _uniswapRouter
    ) {
        baseAsset = IERC20(_baseAsset);
        uniswapRouter = IUniswapV2Router02(_uniswapRouter);
        uniswapFactory = IUniswapFactory(uniswapRouter.factory);
        lpToken = IERC20(UniswapV2Library.pairFor(factory, path[0], path[1]));
    }

    function asset() external view override returns(address) {
        return address(baseAsset);
    }

    function side() external view override returns(address) {
        return address(lpToken);
    }

    function balance(address target) external view override returns (uint256) {
        return lpToken.balanceOf(target);
    }

    function manage(int256 amount) external override {
        if (amount > 0) {
            uint256 depositAmount = uint256(amount);
            if(baseAsset.allowance(address(this), address(uniswapRouter)) < depositAmount)
                baseAsset.approve(address(uniswapRouter), depositAmount);

        } else if (amount < 0) {
            uint256 withdrawAmount = uint256(-amount);
        }
    }

    function collateralise(int256 amount) external override {
        // TBD
    }

    function zap(address _tokenA, address _tokenB, uint256 _amountA) external {
        require(_tokenA == WETH || _tokenB == WETH, "!weth");

        IERC20(_tokenA).transferFrom(msg.sender, address(this), _amountA);

        address pair = IUniswapV2Factory(FACTORY).getPair(_tokenA, _tokenB);
        (uint256 reserve0, uint256 reserve1,) =
            IUniswapV2Pair(pair).getReserves();

        uint256 swapAmount;
        if (IUniswapV2Pair(pair).token0() == _tokenA) {
            // swap from token0 to token1
            swapAmount = getSwapAmount(reserve0, _amountA);
        } else {
            // swap from token1 to token0
            swapAmount = getSwapAmount(reserve1, _amountA);
        }

        _swap(_tokenA, _tokenB, swapAmount);
        _addLiquidity(_tokenA, _tokenB);
    }

    function _swap(address _from, address _to, uint256 _amount) internal {
        IERC20(_from).approve(ROUTER, _amount);

        address[] memory path = new address[](2);
        path = new address[](2);
        path[0] = _from;
        path[1] = _to;

        IUniswapV2Router(ROUTER).swapExactTokensForTokens(
            _amount, 1, path, address(this), block.timestamp
        );
    }

    function _addLiquidity(address _tokenA, address _tokenB) internal {
        uint256 balA = IERC20(_tokenA).balanceOf(address(this));
        uint256 balB = IERC20(_tokenB).balanceOf(address(this));
        IERC20(_tokenA).approve(ROUTER, balA);
        IERC20(_tokenB).approve(ROUTER, balB);

        IUniswapV2Router(ROUTER).addLiquidity(
            _tokenA, _tokenB, balA, balB, 0, 0, address(this), block.timestamp
        );
    }
}
