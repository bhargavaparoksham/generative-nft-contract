const generativeNFT = artifacts.require("generativeNFT");
var ChainlinkVRFCoordinator = '0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B';
var LINKTokenAddress = '0x01BE23585060835E02B77ef475b0Cc51aA1e0709';
var ChainlinkKeyHash = '0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311';
var ChainlinkFee = '100000000000000000'; // 0.1 LINK on Rinkeby
var nftMintLimit = 10;
var mintPrice = '25000000000000000'; //wei or 0.025 eth 25000000000000000
var saleIsActive = false;
var maxPurchase = 3;
var maxWinners = 2;

/* baseURI = 'ipfs://QmVAqWSPcCK6evkd1yyxjCpWsNdFMiKTp8vNxvYWUREsdq/' */

/**
* 
* Network: Rinkeby
* Chainlink VRF Coordinator address: 0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B
* LINK token address: 0x01BE23585060835E02B77ef475b0Cc51aA1e0709
* Key Hash: 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311
*
**/

module.exports = async function(deployer, network, accounts) {


  //Deploy generativeNFT

  await deployer.deploy(
  	generativeNFT,
  	ChainlinkVRFCoordinator, 
  	LINKTokenAddress, 
  	ChainlinkKeyHash, 
  	ChainlinkFee,
  	nftMintLimit,
  	mintPrice,
  	saleIsActive,
  	maxPurchase,
  	maxWinners
  	)
  const genNFT = await generativeNFT.deployed()


};