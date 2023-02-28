// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import "../src/CaviarZapRouter.sol";

contract DeployZapRouterScript is Script {
    using stdJson for string;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        CaviarZapRouter router = new CaviarZapRouter();

        console.log("caviar eth zap router:", address(router));
    }
}
