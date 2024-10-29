// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {console} from "forge-std/Test.sol";
import {KodiakAdapter} from "../../src/adapters/KodiakAdapter.sol";
import {BaseIntegrationTest} from "../BaseIntegrationTest.sol";

contract KodiakTest is BaseIntegrationTest {
    address public constant user = 0xB8D61141c3A4888b0c2B7977E98a823321DdEAcC;
    KodiakAdapter public adapter = new KodiakAdapter(
        wbera, // base asset
        0x7fd165B73775884a38AA8f2B384A53A3Ca7400E6, // kodiak vault
        0x4d41822c1804ffF5c038E4905cfd1044121e0E85, // kodiak router
        0x763F65E5F02371aD6C24bD60BCCB0b14E160d49b // infrared gague
    );
    IERC20 public wberaToken = IERC20(wbera);
    IERC20 public ibgtToken = IERC20(ibgt);

    constructor() BaseIntegrationTest("https://bartio.rpc.berachain.com", 5949617) {}

    function setUp() external {
        vm.startPrank(user);
        wberaToken.approve(address(adapter), type(uint256).max);
        ibgtToken.approve(address(adapter), type(uint256).max);
        vm.stopPrank();
    }

    function testKodiakBase() external {
        int256 amount = 4919591501702647615;
        vm.deal(wbera, uint256(amount));
        vm.deal(ibgt, uint256(amount));

        vm.startPrank(user);
        adapter.manage(amount, "");

        bytes memory data = abi.encode(uint256(amount - 1));
        adapter.manage(-amount, data);
        vm.stopPrank();
    }
}
