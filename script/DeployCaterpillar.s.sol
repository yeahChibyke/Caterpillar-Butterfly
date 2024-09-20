// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console2} from "forge-std/Script.sol";
import {Caterpillar} from "../src/Caterpillar.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract DeployCaterpillar is Script {
    string caterpillarSvg = vm.readFile("./img/caterpillar.svg");
    string caterpillarURI = svgToImageURI(caterpillarSvg);

    function run() external returns (address) {
        address proxy = deployCaterpillar();
        return proxy;
    }

    function deployCaterpillar() public returns (address) {
        vm.startBroadcast();
        Caterpillar caterpillar = new Caterpillar();
        ERC1967Proxy proxy = new ERC1967Proxy(address(caterpillar), "");
        Caterpillar(address(proxy)).initialize(caterpillarURI);
        vm.stopBroadcast();

        return address(proxy);
    }

    function svgToImageURI(string memory svg) public pure returns (string memory) {
        string memory baseURL = "data:image/svg+xml;base64,";
        string memory svgBase64Encoded = Base64.encode(bytes(string(abi.encodePacked(svg))));
        return string(abi.encodePacked(baseURL, svgBase64Encoded));
    }
}
