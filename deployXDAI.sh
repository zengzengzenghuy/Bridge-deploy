#!/usr/bin/env bash
source .env

# =============== xDAI ===============
echo "Deploying Foreign xDAI.......🤘🏻"
FOREIGN_VALIDATOR_PROXY=$(forge create --rpc-url $LOCAL_RPC_URL --private-key $ANVIL_PRIV_KEY tokenbridge-contracts/contracts/upgradeability/EternalStorageProxy.sol:EternalStorageProxy --json)
FOREIGN_VALIDATOR_PROXY_ADDRESS=$(jq -r '.deployedTo' <<< "$FOREIGN_VALIDATOR_PROXY")
echo "Foreign Validator Proxy deployed to " $FOREIGN_VALIDATOR_PROXY_ADDRESS


FOREIGN_VALIDATOR_IMPLEMENTATION=$(forge create --rpc-url $LOCAL_RPC_URL --private-key $ANVIL_PRIV_KEY tokenbridge-contracts/contracts/upgradeable_contracts/BridgeValidators.sol:BridgeValidators --json)
FOREIGN_VALIDATOR_IMPLEMENTATION_ADDRESS=$(jq -r '.deployedTo' <<< "$FOREIGN_VALIDATOR_IMPLEMENTATION")
echo "Validator Implementation deployed to " $FOREIGN_VALIDATOR_IMPLEMENTATION_ADDRESS
# Call upgrade


FOREIGN_VALIDATOR_UPGRADE_TX=$(cast send $FOREIGN_VALIDATOR_PROXY_ADDRESS "upgradeTo(uint256, address)" 1 $FOREIGN_VALIDATOR_IMPLEMENTATION_ADDRESS  --rpc-url $LOCAL_RPC_URL --private-key $ANVIL_PRIV_KEY --json)
FOREIGN_VALIDATOR_UPGRADE_TX_HASH=$(jq -r '.transactionHash' <<< "$FOREIGN_VALIDATOR_UPGRADE_TX")
echo "Binding proxy and implementation " $FOREIGN_VALIDATOR_UPGRADE_TX_HASH


FOREIGN_AMB_PROXY=$(forge create --rpc-url $LOCAL_RPC_URL --private-key $ANVIL_PRIV_KEY tokenbridge-contracts/contracts/upgradeability/EternalStorageProxy.sol:EternalStorageProxy --json)
FOREIGN_AMB_PROXY_ADDRESS=$(jq -r '.deployedTo' <<< "$FOREIGN_AMB_PROXY")
echo "Foreign AMB Proxy deployed to " $FOREIGN_AMB_PROXY_ADDRESS







###   HOME

echo "Deploying Home xDAI.......🤘🏻"
HOME_VALIDATOR_PROXY=$(forge create --rpc-url $LOCAL_RPC_URL --private-key $ANVIL_PRIV_KEY tokenbridge-contracts/contracts/upgradeability/EternalStorageProxy.sol:EternalStorageProxy --json)
HOME_VALIDATOR_PROXY_ADDRESS=$(jq -r '.deployedTo' <<< "$HOME_VALIDATOR_PROXY")
echo "Validator Proxy deployed to " $HOME_VALIDATOR_PROXY_ADDRESS


HOME_VALIDATOR_IMPLEMENTATION=$(forge create --rpc-url $LOCAL_RPC_URL --private-key $ANVIL_PRIV_KEY tokenbridge-contracts/contracts/upgradeable_contracts/BridgeValidators.sol:BridgeValidators --json)
HOME_VALIDATOR_IMPLEMENTATION_ADDRESS=$(jq -r '.deployedTo' <<< "$HOME_VALIDATOR_IMPLEMENTATION")
echo "Validator Implementation deployed to " $HOME_VALIDATOR_IMPLEMENTATION_ADDRESS
# Call upgrade


HOME_VALIDATOR_UPGRADE_TX=$(cast send $HOME_VALIDATOR_PROXY_ADDRESS "upgradeTo(uint256, address)" 1 $HOME_VALIDATOR_IMPLEMENTATION_ADDRESS  --rpc-url $LOCAL_RPC_URL --private-key $ANVIL_PRIV_KEY --json)
HOME_VALIDATOR_UPGRADE_TX_HASH=$(jq -r '.transactionHash' <<< "$HOME_VALIDATOR_UPGRADE_TX")
echo "Binding proxy and implementation " $HOME_VALIDATOR_UPGRADE_TX_HASH