
pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT


// ============ Imports ============

import "./subcontracts/ERC721.sol";
import "./interfaces/IERC20.sol";
import "./libraries/Ownable.sol";
import "./subcontracts/VRFConsumerBase.sol";


contract generativeNFT is ERC721, Ownable, VRFConsumerBase {

    // ============ Mutable storage ============

    // Number of nfts minted as of mow
    uint public nftsMinted;
    // Minting Price
    uint256 public mintPrice;
    // Maximum number of nfts that can be minted
    uint public nftMintLimit;
    // Sale status
    bool public saleIsActive;
    // Maximum number of nfts that can be made at a time
    uint public maxPurchase;
    // Maxium number of lottery prize winners
    uint public maxWinners;
    // Number of winners selected as of now
    uint public winnersCount;
    // Number of winners disbursed
    uint public winnersDisbursed;
    // Array of nfts IDs that won the lottery.
    uint[] public winnerIDs;
    // Array of prize money percent w.r.t total prize money pool that will be disbursed to each winner
    uint[] public prizeMoneyPercent = [40, 4, 2, 2, 2, 2, 2, 2, 2, 2];
    // Chainlink oracle fee
    uint256 public ChainlinkFee;
    // Chainlink network VRF key hash
    bytes32 public ChainlinkKeyHash;
    // Chainlink LINK token address
    address public LINKTokenAddress;
    // Chainlink VRF coordinator address
    address public ChainlinkVRFCoordinator;
    // Chainlink Available in the contract
    uint256 public chainlinkAvailable;


    // ============ Events ============

    // Status of the sale
    event SaleActive(bool saleIsActive);
    // Address of nft minter and number of nfts minted
    event NFTsMinted(address indexed minter, uint256 numNFTs);
    // Chainlink VRF request ID, winner position & winner nft ID
    event WinnerSelected(bytes32 id, uint winnerPosition, uint winnerID);

    // ============ Constructor ============

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


    // ============ Functions ============


    /**
    * Set Base URI.
    */
    function setBaseURI(string memory baseURI) public onlyOwner {
        _setBaseURI(baseURI);
    }

    /**
    * Start the nft sale
    */
    function flipSaleState() public onlyOwner {
        // Flip sale status
        saleIsActive = !saleIsActive;
        // Emit sale status
        emit SaleActive(saleIsActive);
    }

    /**
    * Set minting price
    */    
    function setMintPrice(uint256 _mintPrice) public onlyOwner {
        mintPrice = _mintPrice;
    }

    /**
    * Mints Generative Art
    */  
    function mintNFT(uint _numNFTs) public payable {
        // Require that sale is active
        require(saleIsActive, "Generative Art: Sale must be active to mint Generative Art");
        // Require that number of nfts to be minted is greater than 0
        require(_numNFTs > 0, "Generative Art: Cannot mint 0 NFTs.");
        // Require that number of nfts to be minted is less than or equal to max purchase allowed
        require(_numNFTs <= maxPurchase, "Generative Art: Can only mint 20 tokens at a time");
        // Require total nfts that will be minted is less than the nft limit.
        require((_numNFTs + nftsMinted) < nftMintLimit, "Generative Art: Can't mint more than 10,000 NFTs");
        // Require sufficient Eth is provided to mint nfts
        require(msg.value == (_numNFTs * mintPrice), "Generative Art: Insufficient ETH provided to mint NFTs.");
        // Mint the number of nfts requested.
        for (uint i = 0; i < _numNFTs; i++) {
            // Safe mint nft.
            _safeMint(msg.sender, (nftsMinted));
            // Increment nfts minted
            nftsMinted = nftsMinted + 1;
        }
        // Emit nfts minted event
        emit NFTsMinted(msg.sender, _numNFTs);
    }


    /**
    * Withdraw ETH from contract
    */  
    function withdrawETH(address _to, uint256 _amount) public onlyOwner {
        require(_amount <= address(this).balance, "Generative Art: Transfer Amount is less than or equal to contract balance");
        payable(_to).transfer(_amount);

    }

    /**
    * Set Chainlink VRF
    */  
    function setChainLinkVRF(
        bytes32 _ChainlinkKeyHash,
        uint256 _ChainlinkFee
        ) public onlyOwner {
        ChainlinkKeyHash = _ChainlinkKeyHash;
        ChainlinkFee = _ChainlinkFee;
    }

    /**
    * Set prize money percentage that each winner can win.
    */ 
    function setPrizeMoneyPercent(uint _winnerPosition, uint _winningAmountPercent) public onlyOwner {
        prizeMoneyPercent[_winnerPosition] = _winningAmountPercent;
    }

    /**
    * Collects randomness from Chainlink VRF to propose winners.
    */
    function collectRandomWinner() external returns (bytes32 requestId) {
        // Require at least 1 nft to be minted
        require(nftsMinted > 0, "Generative Art: No NFTs are minted yet.");
        // Require caller to be contract owner or all 10K NFTs need to be minted.
        require(msg.sender == owner() || nftsMinted == nftMintLimit , "Generative Art: Only Owner can collectWinner. All 10k NFTs need to be minted for others to collectWinner.");
        // Require chainlinkAvailable >= Chainlink VRF fee
        require(chainlinkAvailable >= ChainlinkFee, "Generative Art: Insufficient LINK. Please deposit LINK.");
        // Call for random number
        return requestRandomness(ChainlinkKeyHash, ChainlinkFee);
    }

    /**
    * Collects random numbers from Chainlink VRF
    */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {        
        //Update winner IDs with a random number between 0 & nftsMinted.
        winnerIDs[winnersCount] = (randomness % nftsMinted);
        // Increment winnersCount
        winnersCount = winnersCount + 1;
        // Update chainlink available
        chainlinkAvailable = chainlinkAvailable - ChainlinkFee;
        // Emit winner selected event
        emit WinnerSelected(requestId, winnersCount, winnerIDs[winnersCount-1]);

    }

    /**
    * Withdraw Link from the contract.
    */
    function withdrawLink(address _to) public onlyOwner {
        IERC20(LINKTokenAddress).transfer(_to, chainlinkAvailable);
    }

    /**
    * Deposit Link tp the contract.
    */
    function depositLink(uint256 _depositAmount) public {
        // Transfer LINK to contract
        IERC20(LINKTokenAddress).transferFrom(msg.sender, address(this), _depositAmount);
        // Update chainlink available
        chainlinkAvailable = chainlinkAvailable + _depositAmount;
    }

    /**
    * Disburses prize money to winners
    */
    function disburseWinners() external {
        // Require at least 1 nft to be minted
        require(nftsMinted > 0, "Generative Art: No NFTs are minted.");
        // Require caller to be contract owner or all 10K NFTs need to be minted
        require(msg.sender == owner() || nftsMinted == nftMintLimit , "Generative Art: Only Owner can disburseWinner. All 10k NFTs need to be minted for others to disburseWinner.");
        // Require that all winners be selected first before disbursing
        require(winnersCount >= maxWinners, "Generative Art: Please wait for Chainlink VRF to update the winners first.");    
        // While winners disbursed is less than total winners
        while (winnersDisbursed < maxWinners) {
            // Get winner
            address winner = ownerOf(winnerIDs[winnersDisbursed]);
            // Transfer Prize Money to winner
            payable(winner).transfer(((address(this).balance)*prizeMoneyPercent[winnersDisbursed])/100);
            // Increment winnersDisbursed
            winnersDisbursed++;
        }
    }

}







