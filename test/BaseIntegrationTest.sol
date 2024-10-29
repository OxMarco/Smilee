// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";

contract BaseIntegrationTest is Test {
    address public constant admin = address(uint160(uint256(keccak256(abi.encodePacked("admin")))));

    address public constant honey = 0x0E4aaF1351de4c0264C5c7056Ef3777b41BD8e03;
    address public constant wbera = 0x7507c1dc16935B82698e4C63f2746A2fCf994dF8;
    address public constant ibgt = 0x46eFC86F0D7455F135CC9df501673739d513E982;

    constructor(string memory rpcUrl, uint256 blockNumber) {
        uint256 forkId = vm.createFork(rpcUrl, blockNumber);
        vm.selectFork(forkId);
        vm.deal(admin, 1 ether);
    }
}
