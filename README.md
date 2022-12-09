# generative-nft-contract

Generative-nft-contract is a simple NFT contract with a built in lottery function.

1. The contract has been deployed on ethereum mainnet, where anyone can mint cool generative artworks as an NFT.
2. There are a maximum of 10k NFTs, once all of them are sold the built in lottery will become active. 
3. Once lottery is active anyone can call getRandomness & selectRandomWinners functions which selects 10 lucky winners using chainlink VRF and part of the money pooled from the NFT sales is transfered to them as a giveaway!

Frontend for the contract: https://github.com/bhargavaparoksham/generative-nft-frontend
