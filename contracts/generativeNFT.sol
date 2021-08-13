
pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

import "./subcontracts/ERC721.sol";
import "./libraries/Ownable.sol";


contract generativeNFT is ERC721, Ownable {

    uint256 public nftsMinted;
    uint256 public mintPrice;
    uint256 public nftMintLimit;
    bool public saleIsActive = false;
    uint public constant maxPurchase = 20;


    constructor() ERC721 ("Generative NFT","GNFT") {  
        nftsMinted = 0;
        nftMintLimit = 10000;
        mintPrice = 100000000000000000; //wei or 0.1 Eth
    }


    function setBaseURI(string memory baseURI) public onlyOwner {
        _setBaseURI(baseURI);
    }

    function flipSaleState() public onlyOwner {
        saleIsActive = !saleIsActive;
    }


    function mintNFT(uint256 _numNFTs) public payable returns (uint256[] memory) {

        require(saleIsActive, "Sale must be active to mint Generative Art");

        require(_numNFTs > 0, "Cannot purchase 0 NFTs.");

        require(_numNFTs <= maxPurchase, "Can only mint 20 tokens at a time");

        require((_numNFTs + nftsMinted) < nftMintLimit, "Can't mint more than 10,000 NFTs");

        require(msg.value == (_numNFTs * mintPrice), "Insufficient ETH provided to mint NFTs.");

        uint256[] memory mintedIds;

        for (uint256 i = 0; i < _numNFTs; i++) {

            mintedIds[i] = nftsMinted;
            _safeMint(msg.sender, mintedIds[i]);
            nftsMinted = nftsMinted + 1;

        }

        return mintedIds;

    }


    function setMintPrice(uint256 _mintPrice) public onlyOwner {

        mintPrice = _mintPrice;

    }


    function transfer(address _to, uint256 _amount) public onlyOwner {

        require(_amount <= address(this).balance, "Transfer Amount is higher than contract balance");

        payable(_to).transfer(_amount);

    }


}







