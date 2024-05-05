

forge install Openzeppelin/openzeppelin-solidity@v1.12.0
forge install Openzeppelin/openzeppelin-contracts@v"3.2.2-solc-0.7"



# xDAI bridge
1. In Foreign xDAI bridge, DAI token is hardcoded in `CompoundConnector.sol::daiToken()`, the default value is DAI on Ethereum(0x6B175474E89094C44Da98b954EedeAC495271d0F). You'll need to modify the address according to the network.
2. BlockRewardAuRa contract has to be "registered" in the blockchain client code (i.e. Nethermind) in order to mint xDAI.