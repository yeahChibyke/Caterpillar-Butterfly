// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract Caterpillar is Initializable, ERC721Upgradeable, OwnableUpgradeable, UUPSUpgradeable {
    /// >------> errors
    error Caterpillar__NoMoreCaterpillars();
    error Caterpillar__OnlyOneCaterpillarPerWallet();
    error ERC721Metadata__URI_QueryFor_NonExistentToken();

    /// >------> variables
    uint256 private s_nextNftId;
    uint256 private s_maxSupply;
    uint256 private s_nftCounter;
    string private s_caterpillarSvgImageUri;
    address[] private s_minters;

    mapping(address => bool) private s_hasMinted;

    /// >------> events
    event CaterpillarMinted(address indexed minter, uint256 nftId);

    /// >------> modifiers
    modifier hasNotMinted(address caller) {
        if (s_hasMinted[caller]) {
            revert Caterpillar__OnlyOneCaterpillarPerWallet();
        }
        _;
    }

    modifier caterpillarsStillAvailable() {
        if (s_nftCounter == s_maxSupply) {
            revert Caterpillar__NoMoreCaterpillars();
        }
        _;
    }

    /// >------> constructor
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// >------> initializer function
    function initialize(string memory caterpillarSvgImageUri) public initializer {
        __ERC721_init("Caterpillar NFT", "CNFT");
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
        s_caterpillarSvgImageUri = caterpillarSvgImageUri;
        s_nftCounter = 0;
        s_maxSupply = 5;
    }

    /// >------> external functions
    function mintNft() external hasNotMinted(msg.sender) caterpillarsStillAvailable returns (string memory) {
        uint256 nftCounter = s_nftCounter;

        s_hasMinted[msg.sender] = true;
        s_minters.push(msg.sender);
        s_nftCounter++;

        _safeMint(msg.sender, nftCounter);

        emit CaterpillarMinted(msg.sender, nftCounter);

        return string(abi.encodePacked("There are ", Strings.toString(s_nftCounter), "Caterpillar NFTs remaining!"));
    }

    /// >------> public functions

    function nftURI(uint256 nftId) public view virtual returns (string memory) {
        if (ownerOf(nftId) == address(0)) {
            revert ERC721Metadata__URI_QueryFor_NonExistentToken();
        }

        string memory imageURI = s_caterpillarSvgImageUri;

        return string(
            abi.encodePacked(
                _baseURI(),
                Base64.encode(
                    bytes( // bytes casting actually unnecessary as 'abi.encodePacked()' returns a bytes
                        abi.encodePacked(
                            '{"name":"',
                            name(), // You can add whatever name here
                            '", "description":"Caterpillar NFT, 100% on Chain!", ',
                            '"attributes": [{"trait_type": "personality", "value": 100}], "image":"',
                            imageURI,
                            '"}'
                        )
                    )
                )
            )
        );
    }

    /// >------> internal functions
    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    /// >------> getter functions
    function getNftCounter() external view returns (uint256) {
        return s_nftCounter;
    }

    function getMaxSupply() external view returns (uint256) {
        return s_maxSupply;
    }

    function mintStatus(address toVerify) external view returns (bool) {
        if (s_hasMinted[toVerify]) {
            return true;
        } else {
            return false;
        }
    }

    function getNftOwner(uint256 nftId) external view returns (address) {
        return ownerOf(nftId);
    }

    function getMinters() external view onlyOwner returns (address[] memory) {
        return s_minters;
    }

    function getCaterpillarSvg() external view returns (string memory) {
        return s_caterpillarSvgImageUri;
    }
}
