
pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

import "./subcontracts/ERC721URIStorage.sol";
import "./libraries/Ownable.sol";


contract generativeNFT is ERC721URIStorage, Ownable {

    uint256 public nftsMinted;
    uint256 public mintPrice;
    uint256 public nftMintLimit;


    constructor() ERC721 ("Generative NFT","GNFT") {  
        nftsMinted = 0;
        nftMintLimit = 10000;
    }

    function mintNFT(string[] memory tokenURI, uint256 _numNFTs) public payable returns (uint256[] memory) {

        require(_numNFTs > 0, "Cannot purchase 0 NFTs.");

        require(tokenURI.length == _numNFTs, "tokenURI & numNFTs mismatch");

        require((_numNFTs + nftsMinted) < nftMintLimit, "Can't mint more than 10,000 NFTs");

        require(msg.value == (_numNFTs * mintPrice), "Insufficient ETH provided to mint NFTs.");

        uint256[] memory newItemIds;


        for (uint256 i = 0; i < _numNFTs; i++) {

            newItemIds[i] = nftsMinted;
            _safeMint(msg.sender, newItemIds[i]);
            _setTokenURI(newItemIds[i], tokenURI[i]);
            nftsMinted = nftsMinted + 1;

        }

        return newItemIds;

    }


    function transferETH(address _to, uint256 _amount) public onlyOwner {

        require(_amount <= address(this).balance, "Transfer Amount is higher than contract balance");

        payable(_to).transfer(_amount);

    }




}







