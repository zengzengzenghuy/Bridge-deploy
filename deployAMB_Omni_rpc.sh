#!/usr/bin/env bash
source .env

if [[$DESTINATION_VERIFIER=="blockscout"]]
then 
    VERIFIER_URL=`--verifier-url $DESTINATION_VERIFIER_URL`
    echo "Verifier URL" $VERIFIER_URL
else
    VERIFIER_URL = ""
fi


echo "Deploying Foreign AMB.......🤘🏻"
FOREIGN_VALIDATOR_PROXY=$(forge create --rpc-url $SOURCE_RPC_URL --private-key $DEPLOYER_PRIV_KEY -—verify -—verifier $SOURCE_VERIFIER —-etherscan-api-key $SOURCE_API_KEY tokenbridge-contracts/contracts/upgradeability/EternalStorageProxy.sol:EternalStorageProxy --json)
FOREIGN_VALIDATOR_PROXY_ADDRESS=$(jq -r '.deployedTo' <<< "$FOREIGN_VALIDATOR_PROXY")
echo "Foreign Validator Proxy deployed to " $FOREIGN_VALIDATOR_PROXY_ADDRESS


FOREIGN_VALIDATOR_IMPLEMENTATION=$(forge create --rpc-url $SOURCE_RPC_URL --private-key $DEPLOYER_PRIV_KEY —-verify —-verifier $SOURCE_VERIFIER -—etherscan-api-key $SOURCE_API_KEY tokenbridge-contracts/contracts/upgradeable_contracts/BridgeValidators.sol:BridgeValidators --json)
FOREIGN_VALIDATOR_IMPLEMENTATION_ADDRESS=$(jq -r '.deployedTo' <<< "$FOREIGN_VALIDATOR_IMPLEMENTATION")
echo "Validator Implementation deployed to " $FOREIGN_VALIDATOR_IMPLEMENTATION_ADDRESS
# Call upgrade


FOREIGN_VALIDATOR_UPGRADE_TX=$(cast send $FOREIGN_VALIDATOR_PROXY_ADDRESS "upgradeTo(uint256, address)" 1 $FOREIGN_VALIDATOR_IMPLEMENTATION_ADDRESS  --rpc-url $SOURCE_RPC_URL --private-key $DEPLOYER_PRIV_KEY --json)
FOREIGN_VALIDATOR_UPGRADE_TX_HASH=$(jq -r '.transactionHash' <<< "$FOREIGN_VALIDATOR_UPGRADE_TX")
echo "Binding proxy and implementation " $FOREIGN_VALIDATOR_UPGRADE_TX_HASH


FOREIGN_AMB_PROXY=$(forge create --rpc-url $SOURCE_RPC_URL --private-key $DEPLOYER_PRIV_KEY —-verify —-verifier $SOURCE_VERIFIER —-etherscan-api-key $SOURCE_API_KEY tokenbridge-contracts/contracts/upgradeability/EternalStorageProxy.sol:EternalStorageProxy --json)
FOREIGN_AMB_PROXY_ADDRESS=$(jq -r '.deployedTo' <<< "$FOREIGN_AMB_PROXY")
echo "Foreign AMB Proxy deployed to " $FOREIGN_AMB_PROXY_ADDRESS

FOREIGN_AMB_IMPLMENTATION=$(forge create --rpc-url $SOURCE_RPC_URL --private-key $DEPLOYER_PRIV_KEY —-verify —-verifier $SOURCE_VERIFIER —-etherscan-api-key $SOURCE_API_KEY tokenbridge-contracts/contracts/upgradeable_contracts/arbitrary_message/ForeignAMB.sol:ForeignAMB --json)
FOREIGN_AMB_IMPLEMENTATION_ADDRESS=$(jq -r '.deployedTo' <<< "$FOREIGN_AMB_IMPLMENTATION")
echo "Foreign AMB Implementation deployed to " $FOREIGN_AMB_IMPLEMENTATION_ADDRESS

FOREIGN_AMB_UPGRADE_TX=$(cast send $FOREIGN_AMB_PROXY_ADDRESS "upgradeTo(uint256, address)" 1 $FOREIGN_AMB_IMPLEMENTATION_ADDRESS  --rpc-url $SOURCE_RPC_URL --private-key $DEPLOYER_PRIV_KEY --json)
FOREIGN_UPGRADE_TX_HASH=$(jq -r '.transactionHash' <<< "$FOREIGN_AMB_UPGRADE_TX")
echo "Binding proxy and implementation " $FOREIGN_UPGRADE_TX_HASH

# call initialize
FOREIGN_INITIALIZE_TX=$(cast send $FOREIGN_AMB_PROXY_ADDRESS "initialize(uint256,uint256,address,uint256,uint256,uint256,address)" $FOREIGN_CHAIN_ID $HOME_CHAIN_ID $FOREIGN_VALIDATOR_PROXY_ADDRESS $MAX_GAS_PER_TX $GAS_PRICE $REQUIRED_BLOCK_CONFIRMATION $OWNER_ADDR --rpc-url $SOURCE_RPC_URL --private-key $DEPLOYER_PRIV_KEY --json)
FOREIGN_INITIALIZE_TX_HASH=$(jq -r '.transactionHash' <<< "$FOREIGN_INITIALIZE_TX")
echo "Foreign AMB initialized " $FOREIGN_INITIALIZE_TX_HASH



###   HOME

echo "Deploying Home AMB.......🤘🏻"
HOME_VALIDATOR_PROXY=$(forge create --rpc-url $DEST_RPC_URL --private-key $DEPLOYER_PRIV_KEY -—verify —-verifier $DEST_VERIFIER —-etherscan-api-key $DEST_API_KEY $VERIFIER_URL tokenbridge-contracts/contracts/upgradeability/EternalStorageProxy.sol:EternalStorageProxy --json)
HOME_VALIDATOR_PROXY_ADDRESS=$(jq -r '.deployedTo' <<< "$HOME_VALIDATOR_PROXY")
echo "Validator Proxy deployed to " $HOME_VALIDATOR_PROXY_ADDRESS


HOME_VALIDATOR_IMPLEMENTATION=$(forge create --rpc-url $DEST_RPC_URL --private-key $DEPLOYER_PRIV_KEY -—verify —-verifier $DEST_VERIFIER —-etherscan-api-key $DEST_API_KEY $VERIFIER_URL tokenbridge-contracts/contracts/upgradeable_contracts/BridgeValidators.sol:BridgeValidators --json)
HOME_VALIDATOR_IMPLEMENTATION_ADDRESS=$(jq -r '.deployedTo' <<< "$HOME_VALIDATOR_IMPLEMENTATION")
echo "Validator Implementation deployed to " $HOME_VALIDATOR_IMPLEMENTATION_ADDRESS
# Call upgrade


HOME_VALIDATOR_UPGRADE_TX=$(cast send $HOME_VALIDATOR_PROXY_ADDRESS "upgradeTo(uint256, address)" 1 $HOME_VALIDATOR_IMPLEMENTATION_ADDRESS  --rpc-url $DEST_RPC_URL --private-key $DEPLOYER_PRIV_KEY --json)
HOME_VALIDATOR_UPGRADE_TX_HASH=$(jq -r '.transactionHash' <<< "$HOME_VALIDATOR_UPGRADE_TX")
echo "Binding proxy and implementation " $HOME_VALIDATOR_UPGRADE_TX_HASH

# # Call initialize

HOME_AMB_PROXY=$(forge create --rpc-url $DEST_RPC_URL --private-key $DEPLOYER_PRIV_KEY  -—verify —-verifier $DEST_VERIFIER —-etherscan-api-key $DEST_API_KEY $VERIFIER_URL tokenbridge-contracts/contracts/upgradeability/EternalStorageProxy.sol:EternalStorageProxy --json)
HOME_AMB_PROXY_ADDRESS=$(jq -r '.deployedTo' <<< "$HOME_AMB_PROXY")
echo "HOME AMB Proxy deployed to " $HOME_AMB_PROXY_ADDRESS

HOME_AMB_IMPLMENTATION=$(forge create --rpc-url $DEST_RPC_URL --private-key $DEPLOYER_PRIV_KEY  -—verify —-verifier $DEST_VERIFIER —-etherscan-api-key $DEST_API_KEY $VERIFIER_URL tokenbridge-contracts/contracts/upgradeable_contracts/arbitrary_message/ForeignAMB.sol:ForeignAMB --json)
HOME_AMB_IMPLEMENTATION_ADDRESS=$(jq -r '.deployedTo' <<< "$HOME_AMB_IMPLMENTATION")
echo "Home AMB Implementation deployed to " $HOME_AMB_IMPLEMENTATION_ADDRESS

HOME_AMB_UPGRADE_TX=$(cast send $HOME_AMB_PROXY_ADDRESS "upgradeTo(uint256, address)" 1 $HOME_AMB_IMPLEMENTATION_ADDRESS  --rpc-url $DEST_RPC_URL --private-key $DEPLOYER_PRIV_KEY --json)
HOME_UPGRADE_TX_HASH=$(jq -r '.transactionHash' <<< "$HOME_AMB_UPGRADE_TX")
echo "Binding proxy and implementation " $HOME_UPGRADE_TX_HASH

HOME_INITIALIZE_TX=$(cast send  $HOME_AMB_PROXY_ADDRESS "initialize(uint256,uint256,address,uint256,uint256,uint256,address)" $HOME_CHAIN_ID $FOREIGN_CHAIN_ID $HOME_VALIDATOR_PROXY_ADDRESS $MAX_GAS_PER_TX $GAS_PRICE $REQUIRED_BLOCK_CONFIRMATION $OWNER_ADDR --rpc-url $DEST_RPC_URL --private-key $DEPLOYER_PRIV_KEY --json)
HOME_INITIALIZE_TX_HASH=$(jq -r '.transactionHash' <<< "$HOME_INITIALIZE_TX")
echo "HOME AMB initialized " $HOME_INITIALIZE_TX_HASH

HOME_AMB_HELPER=$(forge create --rpc-url $DEST_RPC_URL --private-key $DEPLOYER_PRIV_KEY  -—verify —-verifier $DEST_VERIFIER —-etherscan-api-key $DEST_API_KEY $VERIFIER_URL tokenbridge-contracts/contracts/helpers/AMBBridgeHelper.sol:AMBBridgeHelper --constructor-args $HOME_AMB_PROXY_ADDRESS --json)
HOME_AMB_HELPER_ADDRESS=$(jq -r '.deployedTo' <<< "$HOME_AMB_HELPER")
echo "Home AMB Bridge Helper deployed to " $HOME_AMB_HELPER_ADDRESS

echo "AMB deployment done ✅"

# jq -n --arg FOREIGN_AMB $FOREIGN_AMB_PROXY_ADDRESS --arg HOME_AMB $HOME_AMB_PROXY_ADDRESS '{ "Foreign AMB":"$FOREIGN_AMB", "Home AMB":"$HOME_AMB"}' > deploy.json


# Omnibridge
echo "Deploying Foreign Omnibridge.......🤘🏻"
FOREIGN_OMNIBRIDGE_PROXY=$(forge create --rpc-url $SOURCE_RPC_URL --private-key $DEPLOYER_PRIV_KEY —-verify —-verifier $SOURCE_VERIFIER —-etherscan-api-key $SOURCE_API_KEY tokenbridge-contracts/contracts/upgradeability/EternalStorageProxy.sol:EternalStorageProxy --json)
FOREIGN_OMNIBRIDGE_PROXY_ADDRESS=$(jq -r '.deployedTo' <<< "$FOREIGN_OMNIBRIDGE_PROXY")
echo "Foreign Omnibridge Proxy deployed to " $FOREIGN_OMNIBRIDGE_PROXY_ADDRESS

FOREIGN_OMNIBRIDGE_IMPLEMENTATION=$(forge create --rpc-url $SOURCE_RPC_URL --private-key $DEPLOYER_PRIV_KEY—-verify —-verifier $SOURCE_VERIFIER —-etherscan-api-key $SOURCE_API_KEY omnibridge/contracts/upgradeable_contracts/ForeignOmnibridge.sol:ForeignOmnibridge --constructor-args $FOREIGN_PREFIX --json)
echo $FOREIGN_OMNIBRIDGE_IMPLEMENTATION
FOREIGN_OMNIBRIDGE_IMPLEMENTATION_ADDRESS=$(jq -r '.deployedTo' <<< "$FOREIGN_OMNIBRIDGE_IMPLEMENTATION")
echo "Foreign Omnibridge Implementation deployed to " $FOREIGN_OMNIBRIDGE_IMPLEMENTATION_ADDRESS

FOREIGN_OMNIBRIDGE_UPGRADE_TX=$(cast send $FOREIGN_OMNIBRIDGE_PROXY_ADDRESS "upgradeTo(uint256, address)" 1 $FOREIGN_OMNIBRIDGE_IMPLEMENTATION_ADDRESS  --rpc-url $SOURCE_RPC_URL --private-key $DEPLOYER_PRIV_KEY --json)
FOREIGN_OMNIBRIDGE_UPGRADE_TX_HASH=$(jq -r '.transactionHash' <<< "$FOREIGN_OMNIBRIDGE_UPGRADE_TX")
echo "Binding proxy and implementation " $FOREIGN_OMNIBRIDGE_UPGRADE_TX_HASH

echo "Deploying Foreign Permittable Token......"
FOREIGN_PERMITTABLE_TOKEN=$(forge create --rpc-url $SOURCE_RPC_URL --private-key $DEPLOYER_PRIV_KEY —-verify —-verifier $SOURCE_VERIFIER —-etherscan-api-key $SOURCE_API_KEY omnibridge/precompiled/PermittableToken_flat.sol:PermittableToken  --constructor-args " " " " 18 $FOREIGN_CHAIN_ID --json)
FOREIGN_PERMITTABLE_TOKEN_ADDRESS=$(jq -r '.deployedTo' <<< "$FOREIGN_PERMITTABLE_TOKEN")
echo "Foreign Permittable Token deployed to " $FOREIGN_PERMITTABLE_TOKEN_ADDRESS

FOREIGN_TOKEN_FACTORY=$(forge create --rpc-url $SOURCE_RPC_URL --private-key $DEPLOYER_PRIV_KEY —-verify —-verifier $SOURCE_VERIFIER —-etherscan-api-key $SOURCE_API_KEY omnibridge/contracts/upgradeable_contracts/modules/factory/TokenFactory.sol:TokenFactory --constructor-args $OWNER_ADDR $FOREIGN_PERMITTABLE_TOKEN_ADDRESS --json)
FOREIGN_TOKEN_FACTORY_ADDRESS=$(jq -r '.deployedTo' <<< "$FOREIGN_TOKEN_FACTORY")
echo "Foreign Token Factory deployed to " $FOREIGN_TOKEN_FACTORY_ADDRESS

FOREIGN_FORWARDING_RULE=$(forge create --rpc-url $SOURCE_RPC_URL --private-key $DEPLOYER_PRIV_KEY —-verify —-verifier $SOURCE_VERIFIER —-etherscan-api-key $SOURCE_API_KEY omnibridge/contracts/upgradeable_contracts/modules/forwarding_rules/MultiTokenForwardingRulesManager.sol:MultiTokenForwardingRulesManager --constructor-args $OWNER_ADDR --json)
FOREIGN_FORWARDING_RULE_ADDRESS=$(jq -r '.deployedTo' <<< "$FOREIGN_FORWARDING_RULE")
echo "Foreign Forwarding Rules Manager deployed to " $FOREIGN_FORWARDING_RULE_ADDRESS

FOREIGN_SELECTOR_GAS_LIMIT=$(forge create --rpc-url $SOURCE_RPC_URL --private-key $DEPLOYER_PRIV_KEY —-verify —-verifier $SOURCE_VERIFIER —-etherscan-api-key $SOURCE_API_KEY omnibridge/contracts/upgradeable_contracts/modules/gas_limit/SelectorTokenGasLimitManager.sol:SelectorTokenGasLimitManager --constructor-args $FOREIGN_AMB_PROXY_ADDRESS $OWNER_ADDR $FOREIGN_REQUEST_GAS_LIMIT --json)
FOREIGN_SELECTOR_GAS_LIMIT_ADDRESS=$(jq -r '.deployedTo' <<< "$FOREIGN_SELECTOR_GAS_LIMIT")
echo "Foreign Selector Gas Limit Manager deployed to " $FOREIGN_SELECTOR_GAS_LIMIT_ADDRESS




HOME_LIMIT_ARR=($HOME_DAILY_LIMIT $HOME_MAX_PER_TX $HOME_MIN_PER_TX)
FOREIGN_LIMIT_ARR=($FOREIGN_DAILY_LIMIT $FOREIGN_MAX_PER_TX $FOREIGN_MIN_PER_TX)


# echo "Initialize Foreign Omnibridge " $FOREIGN_OMNI_INIT_TX_HASH
#  initialize(
#         address _bridgeContract,
#         address _mediatorContract, // omnibridge contract on the other side
#         uint256[3] calldata _dailyLimitMaxPerTxMinPerTxArray, // [ 0 = _dailyLimit, 1 = _maxPerTx, 2 = _minPerTx ]
#         uint256[2] calldata _executionDailyLimitExecutionMaxPerTxArray, // [ 0 = _executionDailyLimit, 1 = _executionMaxPerTx ]
#         uint256 _requestGasLimit,
#         address _owner,
#         address _tokenFactory
#     ) 


echo "Deploying HOME Omnibridge....."
HOME_OMNIBRIDGE_PROXY=$(forge create --rpc-url $DEST_RPC_URL --private-key $DEPLOYER_PRIV_KEY  -—verify —-verifier $DEST_VERIFIER —-etherscan-api-key $DEST_API_KEY $VERIFIER_URL tokenbridge-contracts/contracts/upgradeability/EternalStorageProxy.sol:EternalStorageProxy --json)
HOME_OMNIBRIDGE_PROXY_ADDRESS=$(jq -r '.deployedTo' <<< "$HOME_OMNIBRIDGE_PROXY")
echo "HOME Omnibridge Proxy deployed to " $HOME_OMNIBRIDGE_PROXY_ADDRESS

HOME_OMNIBRIDGE_IMPLEMENTATION=$(forge create --rpc-url $DEST_RPC_URL --private-key $DEPLOYER_PRIV_KEY  -—verify —-verifier $DEST_VERIFIER —-etherscan-api-key $DEST_API_KEY $VERIFIER_URL omnibridge/contracts/upgradeable_contracts/HomeOmnibridge.sol:HomeOmnibridge --constructor-args $HOME_PREFIX --json)
HOME_OMNIBRIDGE_IMPLEMENTATION_ADDRESS=$(jq -r '.deployedTo' <<< "$HOME_OMNIBRIDGE_IMPLEMENTATION")
echo "Home Omnibridge Implementation deployed to " $HOME_OMNIBRIDGE_IMPLEMENTATION_ADDRESS

HOME_OMNIBRIDGE_UPGRADE_TX=$(cast send $HOME_OMNIBRIDGE_PROXY_ADDRESS "upgradeTo(uint256, address)" 1 $HOME_OMNIBRIDGE_IMPLEMENTATION_ADDRESS  --rpc-url $DEST_RPC_URL --private-key $DEPLOYER_PRIV_KEY --json)
HOME_OMNIBRIDGE_UPGRADE_TX_HASH=$(jq -r '.transactionHash' <<< "$HOME_OMNIBRIDGE_UPGRADE_TX")
echo "Binding proxy and implementation " $HOME_OMNIBRIDGE_UPGRADE_TX_HASH


echo "Deploying Home Permittable Token......"
#(string memory _name, string memory _symbol, uint8 _decimals, uint256 _chainId)
HOME_PERMITTABLE_TOKEN=$(forge create --rpc-url $DEST_RPC_URL --private-key $DEPLOYER_PRIV_KEY  -—verify —-verifier $DEST_VERIFIER —-etherscan-api-key $DEST_API_KEY $VERIFIER_URL omnibridge/precompiled/PermittableToken_flat.sol:PermittableToken --constructor-args " " " " 18 $HOME_CHAIN_ID --json)
HOME_PERMITTABLE_TOKEN_ADDRESS=$(jq -r '.deployedTo' <<< "$HOME_PERMITTABLE_TOKEN")
echo "Home Permittable Token deployed to " $HOME_PERMITTABLE_TOKEN_ADDRESS

HOME_TOKEN_FACTORY=$(forge create --rpc-url $DEST_RPC_URL --private-key $DEPLOYER_PRIV_KEY  -—verify —-verifier $DEST_VERIFIER —-etherscan-api-key $DEST_API_KEY $VERIFIER_URL omnibridge/contracts/upgradeable_contracts/modules/factory/TokenFactory.sol:TokenFactory --constructor-args $OWNER_ADDR $HOME_PERMITTABLE_TOKEN_ADDRESS --json)
HOME_TOKEN_FACTORY_ADDRESS=$(jq -r '.deployedTo' <<< "$HOME_TOKEN_FACTORY")
echo "Home Token Factory deployed to " $HOME_TOKEN_FACTORY_ADDRESS

HOME_FORWARDING_RULE=$(forge create --rpc-url $DEST_RPC_URL --private-key $DEPLOYER_PRIV_KEY  -—verify —-verifier $DEST_VERIFIER —-etherscan-api-key $DEST_API_KEY $VERIFIER_URL omnibridge/contracts/upgradeable_contracts/modules/forwarding_rules/MultiTokenForwardingRulesManager.sol:MultiTokenForwardingRulesManager --constructor-args $OWNER_ADDR --json)
HOME_FORWARDING_RULE_ADDRESS=$(jq -r '.deployedTo' <<< "$HOME_FORWARDING_RULE")
echo "Home Forwarding Rules Manager deployed to " $HOME_FORWARDING_RULE_ADDRESS

echo $HOME_AMB_PROXY_ADDRESS $OWNER_ADDR $HOME_REQUEST_GAS_LIMIT
HOME_SELECTOR_GAS_LIMIT=$(forge create --rpc-url $DEST_RPC_URL --private-key $DEPLOYER_PRIV_KEY  -—verify —-verifier $DEST_VERIFIER —-etherscan-api-key $DEST_API_KEY $VERIFIER_URL omnibridge/contracts/upgradeable_contracts/modules/gas_limit/SelectorTokenGasLimitManager.sol:SelectorTokenGasLimitManager --constructor-args $HOME_AMB_PROXY_ADDRESS $OWNER_ADDR $HOME_REQUEST_GAS_LIMIT --json)
echo "Home selector" $HOME_SELECTOR_GAS_LIMIT
HOME_SELECTOR_GAS_LIMIT_ADDRESS=$(jq -r '.deployedTo' <<< "$HOME_SELECTOR_GAS_LIMIT")
echo "Home Selector Gas Limit Manager deployed to " $HOME_SELECTOR_GAS_LIMIT_ADDRESS

FEE_ARR=(0,0)
HOME_FEE_MANAGER=$(forge create --rpc-url $DEST_RPC_URL --private-key $DEPLOYER_PRIV_KEY  -—verify —-verifier $DEST_VERIFIER —-etherscan-api-key $DEST_API_KEY $VERIFIER_URL omnibridge/contracts/upgradeable_contracts/modules/fee_manager/OmnibridgeFeeManager.sol:OmnibridgeFeeManager --constructor-args $HOME_OMNIBRIDGE_PROXY_ADDRESS $OWNER_ADDR  [] [$FEE_ARR] --json)
HOME_FEE_MANAGER_ADDRESS=$(jq -r '.deployedTo' <<< "$HOME_FEE_MANAGER")
echo "Home Fee Manager deployed to " $HOME_FEE_MANAGER_ADDRESS

HOME_OMNI_INIT=$(cast send $HOME_OMNIBRIDGE_PROXY_ADDRESS "initialize(address,address,uint256[3],uint256[2],address,address,address,address,address)" $HOME_AMB_PROXY_ADDRESS $HOME_OMNIBRIDGE_PROXY_ADDRESS   ["${HOME_LIMIT_ARR[0]}","${HOME_LIMIT_ARR[1]}","${HOME_LIMIT_ARR[2]}"]  ["${FOREIGN_LIMIT_ARR[0]}","${FOREIGN_LIMIT_ARR[1]}"] $HOME_SELECTOR_GAS_LIMIT_ADDRESS $OWNER_ADDR $HOME_TOKEN_FACTORY_ADDRESS $HOME_FEE_MANAGER_ADDRESS $HOME_FORWARDING_RULE_ADDRESS --rpc-url $DEST_RPC_URL --private-key $DEPLOYER_PRIV_KEY --json)
HOME_OMNI_INIT_TX_HASH=$(jq -r '.transactionHash' <<< "$HOME_OMNI_INIT")
echo "Initialize Home Omnibridge " $HOME_OMNI_INIT_TX_HASH

FOREIGN_OMNI_INIT=$(cast send $FOREIGN_OMNIBRIDGE_PROXY_ADDRESS "initialize(address,address,uint256[3],uint256[2],uint256,address,address)" $FOREIGN_AMB_PROXY_ADDRESS $HOME_OMNIBRIDGE_PROXY_ADDRESS ["${FOREIGN_LIMIT_ARR[0]}","${FOREIGN_LIMIT_ARR[1]}","${FOREIGN_LIMIT_ARR[2]}"] ["${HOME_LIMIT_ARR[0]}",${HOME_LIMIT_ARR[1]}] $FOREIGN_REQUEST_GAS_LIMIT $OWNER_ADDR $FOREIGN_TOKEN_FACTORY_ADDRESS  --rpc-url $SOURCE_RPC_URL --private-key $DEPLOYER_PRIV_KEY --json)
FOREIGN_OMNI_INIT_TX_HASH=$(jq -r '.transactionHash' <<< "$FOREIGN_OMNI_INIT")
echo "Initialize Foreign Omnibridge " $FOREIGN_OMNI_INIT_TX_HASH



#

# initialize(
#         uint256 _sourceChainId,
#         uint256 _destinationChainId,
#         address _validatorContract,
#         uint256 _maxGasPerTx,
#         uint256 _gasPrice,
#         uint256 _requiredBlockConfirmations,
#         address _owner
#     ) 
# For Omnibridge