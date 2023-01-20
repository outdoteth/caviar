// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import "../src/Caviar.sol";
import "../src/StolenNftFilterOracle.sol";

contract DeployScript is Script {
    using stdJson for string;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        StolenNftFilterOracle s = new StolenNftFilterOracle();
        Caviar c = new Caviar(address(s));

        console.log("caviar:", address(c));
        console.log("stolen nft filter oracle:", address(s));
    }
}
