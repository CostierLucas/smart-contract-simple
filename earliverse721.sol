//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

/// @author Earliverse

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract EarliverseContract is ERC721Enumerable, Ownable {
    //To increment the id of the NFTs
    using Counters for Counters.Counter;

    //To concatenate the URL of an NFT
    using Strings for uint256;

    //Id of the next NFT to mint
    Counters.Counter private _tokenIds;

    //Number of NFTs in the collection
    uint256 public constant MAX_SUPPLY = 500;
    //Maximum number of NFTs an address can mint
    uint256 public max_mint_allowed = 1;
    //Price of one NFT in sale
    uint256 public priceSale = 0.000001 ether;

    //URI of the NFTs when revealed
    string public baseURI;
    string public baseExtension = ".json";
    bool public paused = false;

    //Keep a track of the number of tokens per address
    mapping(address => uint256) nftsPerWallet;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _initBaseURI
    ) ERC721(_name, _symbol) {
        setBaseURI(_initBaseURI);
        _tokenIds.increment();
    }

    // internal
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    // public
    function mint(address _to, uint256 _mintAmount) public payable {
        uint256 supply = totalSupply();
        require(nftsPerWallet[_to] < 1, "You can only get 1 NFT");
        require(!paused);
        require(_mintAmount > 0);
        require(_mintAmount <= max_mint_allowed);
        require(supply + _mintAmount <= MAX_SUPPLY, "sold out");

        nftsPerWallet[_to]++;

        _safeMint(_to, _tokenIds.current());

        _tokenIds.increment();
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        tokenId.toString(),
                        baseExtension
                    )
                )
                : "";
    }

    // OWNER ONLY
    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }
}
