// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console2} from "forge-std/Test.sol";
import {DeployCaterpillar} from "../script/DeployCaterpillar.s.sol";
import {UpgradeCaterpillarToButterfly} from "../script/UpgradeCaterpillarToButterfly.s.sol";
import {Caterpillar} from "../src/Caterpillar.sol";
import {Butterfly} from "../src/Butterfly.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract DeployAndUpgradeTest is StdCheats, Test {
    DeployCaterpillar deployCaterpillar;
    UpgradeCaterpillarToButterfly upgradeCaterpillar;
    address public Owner = address(1);
    address Alice;
    address Bob;
    address Clara;
    address Dan;
    address Ethan;

    string NFT_NAME = "Caterpillar NFT";
    string NFT_SYMBOL = "CNFT";

    function setUp() public {
        deployCaterpillar = new DeployCaterpillar();
        upgradeCaterpillar = new UpgradeCaterpillarToButterfly();

        Alice = makeAddr("Alice");
        Bob = makeAddr("Bob");
        Clara = makeAddr("Clara");
        Dan = makeAddr("Dan");
        Ethan = makeAddr("Ethan");
    }

    /// >------> Caterpillar Tests
    function testDeploymentIsCaterpillar() public {
        address proxyAddress = deployCaterpillar.deployCaterpillar();
        uint256 falseMaxSupply = 10;

        assert(falseMaxSupply != Caterpillar(proxyAddress).getMaxSupply());
    }

    function testCaterpillarWorks() public {
        address proxyAddress = deployCaterpillar.deployCaterpillar();
        uint256 expectedMaxSupply = 5;

        assert(expectedMaxSupply == Caterpillar(proxyAddress).getMaxSupply());
        assert(keccak256(abi.encodePacked(NFT_NAME)) == keccak256(abi.encodePacked(Caterpillar(proxyAddress).name())));
        assert(
            keccak256(abi.encodePacked(NFT_SYMBOL)) == keccak256(abi.encodePacked(Caterpillar(proxyAddress).symbol()))
        );
    }

    function testCanMintCaterpillarAndViewURI() public {
        address proxyAddress = deployCaterpillar.deployCaterpillar();

        vm.prank(Alice);
        Caterpillar(proxyAddress).mintNft();
        // console2.log(Caterpillar(proxyAddress).nftURI(0));

        assert(Caterpillar(proxyAddress).balanceOf(Alice) == 1);
        assert(Caterpillar(proxyAddress).ownerOf(0) == Alice);
    }

    function testMultiMintCaterpillar() public {
        address proxyAddress = deployCaterpillar.deployCaterpillar();

        vm.prank(Bob);
        Caterpillar(proxyAddress).mintNft();
        assert(Caterpillar(proxyAddress).balanceOf(Bob) == 1);
        assert(Caterpillar(proxyAddress).ownerOf(0) == Bob);
        assert(Caterpillar(proxyAddress).getNftCounter() == 1);

        vm.prank(Clara);
        Caterpillar(proxyAddress).mintNft();
        assert(Caterpillar(proxyAddress).balanceOf(Clara) == 1);
        assert(Caterpillar(proxyAddress).ownerOf(1) == Clara);
        assert(Caterpillar(proxyAddress).getNftCounter() == 2);

        vm.prank(Dan);
        Caterpillar(proxyAddress).mintNft();
        assert(Caterpillar(proxyAddress).balanceOf(Dan) == 1);
        assert(Caterpillar(proxyAddress).ownerOf(2) == Dan);
        assert(Caterpillar(proxyAddress).getNftCounter() == 3);

        vm.prank(Ethan);
        Caterpillar(proxyAddress).mintNft();
        assert(Caterpillar(proxyAddress).balanceOf(Ethan) == 1);
        assert(Caterpillar(proxyAddress).ownerOf(3) == Ethan);
        assert(Caterpillar(proxyAddress).getNftCounter() == 4);
    }

    function testNotMintThanOneCaterpillar() public {
        address proxyAddress = deployCaterpillar.deployCaterpillar();

        vm.prank(Alice);
        Caterpillar(proxyAddress).mintNft();

        assert(Caterpillar(proxyAddress).balanceOf(Alice) == 1);

        // try to mint again
        vm.prank(Alice);
        vm.expectRevert(Caterpillar.Caterpillar__OnlyOneCaterpillarPerWallet.selector);
        Caterpillar(proxyAddress).mintNft();
    }

    function testNotMintThanMaxSupplyCaterpillars() public {
        address proxyAddress = deployCaterpillar.deployCaterpillar();

        vm.prank(Alice);
        Caterpillar(proxyAddress).mintNft();
        assert(Caterpillar(proxyAddress).balanceOf(Alice) == 1);

        vm.prank(Bob);
        Caterpillar(proxyAddress).mintNft();
        assert(Caterpillar(proxyAddress).balanceOf(Bob) == 1);

        vm.prank(Clara);
        Caterpillar(proxyAddress).mintNft();
        assert(Caterpillar(proxyAddress).balanceOf(Clara) == 1);

        vm.prank(Dan);
        Caterpillar(proxyAddress).mintNft();
        assert(Caterpillar(proxyAddress).balanceOf(Dan) == 1);

        vm.prank(Ethan);
        Caterpillar(proxyAddress).mintNft();
        assert(Caterpillar(proxyAddress).balanceOf(Ethan) == 1);

        assert(Caterpillar(proxyAddress).getNftCounter() == 5);

        address pranker = makeAddr("pranker");
        vm.prank(pranker);
        vm.expectRevert(Caterpillar.Caterpillar__NoMoreCaterpillars.selector);
        Caterpillar(proxyAddress).mintNft();
    }

    /// >------> Butterfly Tests
    function testUpgradeWorks() public {
        address proxyAddress = deployCaterpillar.deployCaterpillar();
        Butterfly butterfly = new Butterfly();

        vm.prank(Caterpillar(proxyAddress).owner());
        Caterpillar(proxyAddress).transferOwnership(msg.sender);

        address proxy = upgradeCaterpillar.upgradeCaterpillarToButterfly(proxyAddress, address(butterfly));

        uint256 expectedMaxSupply = 10;
        console2.log(Butterfly(proxy).getMaxSupply());
        assert(expectedMaxSupply == Butterfly(proxy).getMaxSupply());
    }
    /// @note this test is currently failing. Something is wrong with the initialization from the scripts (i guess)
}
