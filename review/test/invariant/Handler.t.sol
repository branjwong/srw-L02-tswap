// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {TSwapPool} from "../../src/PoolFactory.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

contract Handler is Test {
    TSwapPool pool;
    ERC20Mock poolToken;
    ERC20Mock weth;

    uint256 minimumDepositAmount;

    address liquidityProvider;
    address user;

    constructor(
        TSwapPool _tswapPool,
        ERC20Mock _poolToken,
        ERC20Mock _weth,
        address _liquidityProvider,
        address _user,
        uint256 _minimumDepositAmount
    ) {
        pool = _tswapPool;
        poolToken = _poolToken;
        weth = _weth;

        liquidityProvider = _liquidityProvider;
        user = _user;

        minimumDepositAmount = _minimumDepositAmount;
    }

    function deposit(uint256 _amount) public {
        uint256 amount = bound(
            _amount,
            minimumDepositAmount,
            weth.balanceOf(liquidityProvider)
        );

        vm.startPrank(liquidityProvider);
        weth.approve(address(pool), amount);
        poolToken.approve(address(pool), amount);
        pool.deposit(amount, amount, amount, uint64(block.timestamp));
        vm.stopPrank();
    }

    function withdraw(uint256 _amount) public {
        uint256 amount = bound(_amount, 0, pool.balanceOf(liquidityProvider));

        vm.startPrank(liquidityProvider);
        pool.approve(address(pool), 100e18);
        pool.withdraw(amount, 1, 1, uint64(block.timestamp));
        vm.stopPrank();
    }
}
