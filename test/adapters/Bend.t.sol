// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {console} from "forge-std/Test.sol";
import {BendAdapter} from "../../src/adapters/BendAdapter.sol";
import {BaseIntegrationTest} from "../BaseIntegrationTest.sol";

contract BendTest is BaseIntegrationTest {
    address public constant user = 0xB8D61141c3A4888b0c2B7977E98a823321DdEAcC;
    BendAdapter public adapter = new BendAdapter(
        honey, // base asset
        0x30A3039675E5b5cbEA49d9a5eacbc11f9199B86D, // Bend pool address
        0xD08391c5977ebF1a09bB5915908EF5cd95Edb7E0 // Honey aToken
    );
    IERC20 public honeyToken = IERC20(honey);

    constructor() BaseIntegrationTest("https://bartio.rpc.berachain.com", 5945940) {}

    function setUp() external {
        vm.prank(user);
        honeyToken.approve(address(adapter), type(uint256).max);
    }

    function testBase() external {
        int256 amount = 4919591501702647615;
        vm.deal(honey, uint256(amount));

        vm.startPrank(user);
        adapter.manage(amount, "");

        bytes memory data = abi.encode(uint256(amount - 1));
        adapter.manage(-amount, data);
        vm.stopPrank();
    }
}
