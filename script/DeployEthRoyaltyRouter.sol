// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import "../src/CaviarEthRoyaltyRouter.sol";

contract DeployEthRoyaltyRouterScript is Script {
    using stdJson for string;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        CaviarEthRoyaltyRouter router = new CaviarEthRoyaltyRouter(vm.envAddress("MANIFOLD_ROYALTY_REGISTRY"));

        console.log("caviar eth royalty router:", address(router));
    }
}
