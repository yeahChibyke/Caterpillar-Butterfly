// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console2} from "forge-std/Script.sol";
import {Caterpillar} from "../src/Caterpillar.sol";
import {Butterfly} from "../src/Butterfly.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {DevOpsTools} from "Foundry-DevOps/src/DevOpsTools.sol";

contract UpgradeCaterpillarToButterfly is Script {
    string butterflySvg = vm.readFile("./img/butterfly.svg");
    string upgradeURI = svgToImageURI(butterflySvg);

    function run() external returns (address) {
        address mostRecentlyDeployedProxy = DevOpsTools.get_most_recent_deployment("ERC1967Proxy", block.chainid);

        vm.startBroadcast();
        Butterfly butterfly = new Butterfly();
        vm.stopBroadcast();
        address proxy = upgradeCaterpillarToButterfly(mostRecentlyDeployedProxy, address(butterfly));
        return proxy;
    }

    function upgradeCaterpillarToButterfly(address proxyAddress, address butterfly) public returns (address) {
        vm.startBroadcast();
        Caterpillar proxy = Caterpillar(payable(proxyAddress));
        // Butterfly(address(proxy)).initialize(upgradeURI); /// @note This line is making all tests for Butterfly to fail. But, I need a way to initialize the Butterfly contract
        // bytes memory data = abi.encodeWithSelector(Butterfly.initialize.selector, "upgradeURI");
        // proxy.upgradeToAndCall(address(butterfly), data);
        proxy.upgradeToAndCall(address(butterfly), "");
        vm.stopBroadcast();
        return address(proxy);
    }

    function svgToImageURI(string memory svg) public pure returns (string memory) {
        string memory baseURL = "data:image/svg+xml;base64,";
        string memory svgBase64Encoded = Base64.encode(bytes(string(abi.encodePacked(svg))));
        return string(abi.encodePacked(baseURL, svgBase64Encoded));
    }
}
