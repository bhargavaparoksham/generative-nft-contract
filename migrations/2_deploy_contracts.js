const generativeNFT = artifacts.require("generativeNFT");


//Rinkeby
// var ChainlinkVRFCoordinator = '0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B';
// var LINKTokenAddress = '0x01BE23585060835E02B77ef475b0Cc51aA1e0709';
// var ChainlinkKeyHash = '0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311';
// var ChainlinkFee = '100000000000000000'; // 0.1 LINK on Rinkeby
// var nftMintLimit = 10;
// var mintPrice = '25000000000000000'; //wei or 0.025 eth 25000000000000000
// var saleIsActive = false;
// var maxPurchase = 3;
// var maxWinners = 2;

/* baseURI = 'ipfs://QmVAqWSPcCK6evkd1yyxjCpWsNdFMiKTp8vNxvYWUREsdq/' */

/**
* 
* Network: Rinkeby
* Chainlink VRF Coordinator address: 0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B
* LINK token address: 0x01BE23585060835E02B77ef475b0Cc51aA1e0709
* Key Hash: 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311
*
**/


//Mainnet


 
var ChainlinkVRFCoordinator = '0xf0d54349aDdcf704F77AE15b96510dEA15cb7952';
var LINKTokenAddress = '0x514910771AF9Ca656af840dff83E8264EcF986CA';
var ChainlinkKeyHash = '0xAA77729D3466CA35AE8D28B3BBAC7CC36A5031EFDC430821C02BC31A238AF445';
var ChainlinkFee = '2000000000000000000'; // 2 LINK on Mainnet
var nftMintLimit = 10000;
var mintPrice = '25000000000000000'; //wei or 0.025 eth 25000000000000000
var saleIsActive = false;
var maxPurchase = 20;
var maxWinners = 10; 


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