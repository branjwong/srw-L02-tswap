// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {TSwapPool, PoolFactory, IERC20} from "../../src/PoolFactory.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {Handler} from "./Handler.t.sol";

contract TSwapTest is StdInvariant, Test {
    PoolFactory poolFactory;
    TSwapPool pool;
    ERC20Mock poolToken;
    ERC20Mock weth;

    uint256 minimumDepositAmount;
    Handler handler;

    address owner = makeAddr("owner");

    address liquidityProvider = makeAddr("liquidityProvider");
    address user = makeAddr("user");

    function setUp() public {
        weth = new ERC20Mock();
        poolToken = new ERC20Mock();

        poolFactory = new PoolFactory(address(weth));
        pool = TSwapPool(poolFactory.createPool(address(poolToken)));

        weth.mint(liquidityProvider, 200e18);
        poolToken.mint(liquidityProvider, 200e18);

        weth.mint(user, 10e18);
        poolToken.mint(user, 10e18);

        minimumDepositAmount = pool.getMinimumWethDepositAmount();

        handler = new Handler(
            pool,
            poolToken,
            weth,
            liquidityProvider,
            user,
            minimumDepositAmount
        );

        bytes4[] memory selectors = new bytes4[](2);
        selectors[0] = handler.swapExactInputWeth.selector;
        selectors[1] = handler.swapExactInputPoolToken.selector;

        targetSelector(
            FuzzSelector({addr: address(handler), selectors: selectors})
        );
        targetContract(address(handler));

        handler.deposit(100e18);
        handler.saveK();
    }

    // This is called at the end of every fuzz step in invariant fuzz campaign.
    function statefulFuzz_testConstantProductFormulaAlwaysHolds() public {
        assertEq(handler.getK(), handler.calculateK());
    }
}
