# Deployment script for tokenbridge-contracts

This is a deployment script for tokenbridge-contract & omnibridge using Foundry `forge create` cli.

## Version of packages
```
forge install Openzeppelin/openzeppelin-solidity@v1.12.0     
forge install Openzeppelin/openzeppelin-contracts@v"3.2.2-solc-0.7"
```

# xDAI bridge

1. In Foreign xDAI bridge, DAI token is hardcoded in CompoundConnector.sol::daiToken(), the default value is DAI on Ethereum(0x6B175474E89094C44Da98b954EedeAC495271d0F). You'll need to modify the address according to the network.
2. The new xDAI bridge has to be registered in the blockReward contract to 'mint' new xDAI. (Another option is to deploy new BlockRewardAura contract and  register in the blockchain client code (i.e. [Nethermind](https://github.com/NethermindEth/nethermind/blob/master/src/Nethermind/Chains/chiado.json#L28)) )

# FAQ
1. Why not use Foundry script?
    Most tokenbridge-contracts use Solidity 0.4.24, while Foundry script uses at least 0.6.0. Using Foundry script will give compiler error.
2. Why there is posdao-contracts?
    Gnosis Chain is previously PoA Network, which uses PoSDAO consensus instead of the currently used PoS(Proof of Stake). In PosDAO, a set of permissioned validators take turn to submit the block and the validator set is changed periodically. All the operation logic can be found in `/posdao-contracts`. 
    In production, only `BlockRewardAuRa.sol` is still being called by Home xDAI bridge. 