const generativeNFT = artifacts.require("generativeNFT");



module.exports = async function(deployer, network, accounts) {


  //Deploy generativeNFT

  await deployer.deploy(generativeNFT)
  const genNFT = await generativeNFT.deployed()


};