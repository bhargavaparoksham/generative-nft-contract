
pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

import "./subcontracts/ERC721.sol";
import "./interfaces/IERC20.sol";
import "./libraries/Ownable.sol";
import "./subcontracts/VRFConsumerBase.sol";


contract generativeNFT is ERC721, Ownable, VRFConsumerBase {

    uint public nftsMinted;
    uint256 public mintPrice;
    uint public nftMintLimit;
    bool public saleIsActive;
    uint public maxPurchase;
    uint public maxWinners;
    uint public winnersCount;
    uint public winnersDisbursed;
    uint[] public winnerIDs;
    uint[] public prizeMoneyRatio = [40,4,2,2,2,2,2,2,2,2];
    // Chainlink oracle fee
    uint256 public ChainlinkFee;
    // Chainlink network VRF key hash
    bytes32 public ChainlinkKeyHash;
    // Chainlink LINK token address
    address public LINKTokenAddress;
    // Chainlink VRF coordinator address
    address public ChainlinkVRFCoordinator;
    // Chainlink Available
    uint256 public chainlinkAvailable;


    constructor(
        address _ChainlinkVRFCoordinator,
        address _LINKTokenAddress,
        bytes32 _ChainlinkKeyHash,
        uint256 _ChainlinkFee,
        uint _nftMintLimit,
        uint256 _mintPrice,
        bool _saleIsActive,
        uint _maxPurchase,
        uint _maxWinners
        ) ERC721 ("Generative NFT","GNFT") VRFConsumerBase(_ChainlinkVRFCoordinator, _LINKTokenAddress) {  
        nftsMinted = 0;
        ChainlinkVRFCoordinator = _ChainlinkVRFCoordinator;
        LINKTokenAddress = _LINKTokenAddress;
        nftMintLimit = _nftMintLimit;
        mintPrice = _mintPrice; 
        saleIsActive = _saleIsActive;
        maxPurchase = _maxPurchase;
        maxWinners = _maxWinners;
        winnersCount = 0;
        winnersDisbursed = 0;
        ChainlinkKeyHash = _ChainlinkKeyHash;
        ChainlinkFee = _ChainlinkFee;

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


    function withdrawETH(address _to, uint256 _amount) public onlyOwner {
        require(_amount <= address(this).balance, "Transfer Amount is higher than contract balance");
        payable(_to).transfer(_amount);

    }


    function setChainLinkVRF(
        bytes32 _ChainlinkKeyHash,
        uint256 _ChainlinkFee
        ) public onlyOwner {
        ChainlinkKeyHash = _ChainlinkKeyHash;
        ChainlinkFee = _ChainlinkFee;
    }

    function setPrizeMoneyRatio(uint _winnerPosition, uint _winningAmountRatio) public onlyOwner {
        prizeMoneyRatio[_winnerPosition] = _winningAmountRatio;
    }

    /**
    * Collects randomness from Chainlink VRF to propose winners.
    */
    function collectRandomWinner() external returns (bytes32 requestId) {
        // Require at least 1 nft to be minted
        require(nftsMinted > 0, "No NFTs are minted.");
        // Require caller to be contract owner or all 10K NFTs need to be minted.
        require(msg.sender == owner() || nftsMinted == nftMintLimit , "Only Owner can collectWinner. All 10k NFTs need to be minted for others to collectWinner.");
        // Require chainlinkAvailable >= Chainlink VRF fee
        require(chainlinkAvailable >= ChainlinkFee, "Insufficient LINK. Please deposit LINK.");
        // Call for random number
        return requestRandomness(ChainlinkKeyHash, ChainlinkFee);
    }

    /**
    * Collects random numbers from Chainlink VRF
    */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {        
        //Random Number between 0 to nftsMinted.
        winnerIDs[winnersCount] = (randomness % nftsMinted);
        winnersCount = winnersCount + 1;
        chainlinkAvailable = chainlinkAvailable - ChainlinkFee;
    }

    function withdrawLink(address _to) public onlyOwner {
        //Witdraw Link
        IERC20(LINKTokenAddress).transfer(_to, chainlinkAvailable);

    }

    function depositLink(uint256 _depositAmount) public {
        // Transfer LINK to contract
        IERC20(LINKTokenAddress).transferFrom(msg.sender, address(this), _depositAmount);
        chainlinkAvailable = chainlinkAvailable + _depositAmount;

    }

    /**
    * Disburses prize money to winners
    */
    function disburseWinners() external {
        // Require at least 1 nft to be minted
        require(nftsMinted > 0, "No NFTs are minted.");
        // Require caller to be contract owner or all 10K NFTs need to be minted.
        require(msg.sender == owner() || nftsMinted == nftMintLimit , "Only Owner can disburseWinner. All 10k NFTs need to be minted for others to disburseWinner.");
        // Require that the random result is not 0
        require(winnersCount >= maxWinners, "Please wait for Chainlink VRF to update the winners first.");    
        while (winnersDisbursed < maxWinners) {
            // Get winner
            address winner = ownerOf(winnerIDs[winnersDisbursed]);
            // Transfer Prize Money to winner
            payable(winner).transfer(((address(this).balance)*prizeMoneyRatio[winnersDisbursed])/100);
            // Increment winnersDisbursed
            winnersDisbursed++;
        }
    }

}







