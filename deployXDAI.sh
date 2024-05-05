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


FOREIGN_XDAI_PROXY=$(forge create --rpc-url $LOCAL_RPC_URL --private-key $ANVIL_PRIV_KEY tokenbridge-contracts/contracts/upgradeability/EternalStorageProxy.sol:EternalStorageProxy --json)
FOREIGN_XDAI_PROXY_ADDRESS=$(jq -r '.deployedTo' <<< "$FOREIGN_XDAI_PROXY")
echo "Foreign XDAI Proxy deployed to " $FOREIGN_XDAI_PROXY_ADDRESS


FOREIGN_XDAI_IMPLEMENTATION=$(forge create --rpc-url $LOCAL_RPC_URL --private-key $ANVIL_PRIV_KEY tokenbridge-contracts/contracts/upgradeable_contracts/erc20_to_native/XDaiForeignBridge.sol:XDaiForeignBridge --json)
FOREIGN_XDAI_IMPLEMENTATION_ADDRESS=$(jq -r '.deployedTo' <<< "$FOREIGN_XDAI_IMPLEMENTATION")
echo "Foreign XDAI Implementation deployed to " $FOREIGN_XDAI_IMPLEMENTATION_ADDRESS

FOREIGN_XDAI_UPGRADE_TX=$(cast send $FOREIGN_XDAI_PROXY_ADDRESS "upgradeTo(uint256, address)" 1 $FOREIGN_XDAI_IMPLEMENTATION_ADDRESS  --rpc-url $LOCAL_RPC_URL --private-key $ANVIL_PRIV_KEY --json)
FOREIGN_XDAI_UPGRADE_TX=$(jq -r '.transactionHash' <<< "$FOREIGN_XDAI_UPGRADE_TX")
echo "Binding proxy and implementation " $FOREIGN_XDAI_UPGRADE_TX_HASH

FOREIGN_LIMIT_ARR=($FOREIGN_DAILY_LIMIT $FOREIGN_MAX_PER_TX $FOREIGN_MIN_PER_TX)
HOME_LIMIT_ARR=($HOME_DAILY_LIMIT $HOME_MAX_PER_TX $HOME_MIN_PER_TX)


# Foreign.initialize(
#         address _validatorContract,
#         address _erc20token,
#         uint256 _requiredBlockConfirmations,
#         uint256 _gasPrice,
#         uint256[3] _dailyLimitMaxPerTxMinPerTxArray, // [ 0 = _dailyLimit, 1 = _maxPerTx, 2 = _minPerTx ]
#         uint256[2] _homeDailyLimitHomeMaxPerTxArray, //[ 0 = _homeDailyLimit, 1 = _homeMaxPerTx ]
#         address _owner,
#         int256 _decimalShift,
#         address _bridgeOnOtherSide
#     )


###   HOME

echo "Deploying Home xDAI.......🤘🏻"
HOME_VALIDATOR_PROXY=$(forge create --rpc-url $LOCAL_RPC_URL --private-key $ANVIL_PRIV_KEY tokenbridge-contracts/contracts/upgradeability/EternalStorageProxy.sol:EternalStorageProxy --json)
HOME_VALIDATOR_PROXY_ADDRESS=$(jq -r '.deployedTo' <<< "$HOME_VALIDATOR_PROXY")
echo "Home Validator Proxy deployed to " $HOME_VALIDATOR_PROXY_ADDRESS


HOME_VALIDATOR_IMPLEMENTATION=$(forge create --rpc-url $LOCAL_RPC_URL --private-key $ANVIL_PRIV_KEY tokenbridge-contracts/contracts/upgradeable_contracts/BridgeValidators.sol:BridgeValidators --json)
HOME_VALIDATOR_IMPLEMENTATION_ADDRESS=$(jq -r '.deployedTo' <<< "$HOME_VALIDATOR_IMPLEMENTATION")
echo "Validator Implementation deployed to " $HOME_VALIDATOR_IMPLEMENTATION_ADDRESS
# Call upgrade


HOME_VALIDATOR_UPGRADE_TX=$(cast send $HOME_VALIDATOR_PROXY_ADDRESS "upgradeTo(uint256, address)" 1 $HOME_VALIDATOR_IMPLEMENTATION_ADDRESS  --rpc-url $LOCAL_RPC_URL --private-key $ANVIL_PRIV_KEY --json)
HOME_VALIDATOR_UPGRADE_TX_HASH=$(jq -r '.transactionHash' <<< "$HOME_VALIDATOR_UPGRADE_TX")
echo "Binding proxy and implementation " $HOME_VALIDATOR_UPGRADE_TX_HASH

HOME_XDAI_PROXY=$(forge create --rpc-url $LOCAL_RPC_URL --private-key $ANVIL_PRIV_KEY tokenbridge-contracts/contracts/upgradeability/EternalStorageProxy.sol:EternalStorageProxy --json)
HOME_XDAI_PROXY_ADDRESS=$(jq -r '.deployedTo' <<< "$HOME_XDAI_PROXY")
echo "Home xDAI Proxy deployed to " $HOME_XDAI_PROXY_ADDRESS

HOME_XDAI_IMPLEMENTATION=$(forge create --rpc-url $LOCAL_RPC_URL --private-key $ANVIL_PRIV_KEY tokenbridge-contracts/contracts/upgradeable_contracts/erc20_to_native/HomeBridgeErcToNative.sol:HomeBridgeErcToNative --json)
HOME_XDAI_IMPLEMENTATION_ADDRESS=$(jq -r '.deployedTo' <<< "$HOME_XDAI_IMPLEMENTATION")
echo "Home xDAI Implementation deployed to " $HOME_XDAI_IMPLEMENTATION_ADDRESS

HOME_XDAI_UPGRADE_TX=$(cast send $HOME_XDAI_PROXY_ADDRESS "upgradeTo(uint256, address)" 1 $HOME_XDAI_IMPLEMENTATION_ADDRESS  --rpc-url $LOCAL_RPC_URL --private-key $ANVIL_PRIV_KEY --json)
HOME_XDAI_UPGRADE_TX_HASH=$(jq -r '.transactionHash' <<< "$HOME_XDAI_UPGRADE_TX")
echo "Binding proxy and implementation " $HOME_XDAI_UPGRADE_TX_HASH

HOME_BLOCK_REWARD=$(forge create --rpc-url $LOCAL_RPC_URL --private-key $ANVIL_PRIV_KEY  posdao-contracts/contracts/BlockRewardAuRa.sol:BlockRewardAuRa --json)
HOME_BLOCK_REWARD_ADDRESS=$(jq -r '.deployedTo' <<< "$HOME_BLOCK_REWARD")
echo "Home block reward  deployed to " $HOME_BLOCK_REWARD_ADDRESS

HOME_INIT=$(cast send $HOME_XDAI_PROXY_ADDRESS "initialize(address,uint256[3],uint256,uint256,address,uint256[2],address,int256)" $HOME_VALIDATOR_PROXY_ADDRESS ["${HOME_LIMIT_ARR[0]}","${HOME_LIMIT_ARR[1]}","${HOME_LIMIT_ARR[2]}"]  $GAS_PRICE $REQUIRED_BLOCK_CONFIRMATION $HOME_BLOCK_REWARD_ADDRESS ["${FOREIGN_LIMIT_ARR[0]}","${FOREIGN_LIMIT_ARR[1]}"] $OWNER_ADDR  0  --rpc-url $LOCAL_RPC_URL --private-key $ANVIL_PRIV_KEY --json)
HOME_INIT_TX_HASH=$(jq -r '.transactionHash' <<< "$HOME_INIT")
echo "Home xDAI init tx " $HOME_INIT_TX_HASH

FOREIGN_INIT=$(cast send $FOREIGN_XDAI_PROXY_ADDRESS "initialize(address,address,uint256,uint256,uint256[3],uint256[2],address,int256,address)"  $FOREIGN_VALIDATOR_PROXY_ADDRESS  $DAI_SEPOLIA  $REQUIRED_BLOCK_CONFIRMATION $GAS_PRICE ["${FOREIGN_LIMIT_ARR[0]}","${FOREIGN_LIMIT_ARR[1]}","${FOREIGN_LIMIT_ARR[2]}"] ["${HOME_LIMIT_ARR[0]}","${HOME_LIMIT_ARR[1]}"]  $OWNER_ADDR 0 $HOME_XDAI_PROXY_ADDRESS $BLOCK_REWARD_ADDR --rpc-url $LOCAL_RPC_URL --private-key $ANVIL_PRIV_KEY --json)
FOREIGN_INIT_TX_HASH=$(jq -r '.transactionHash' <<< "$FOREIGN_INIT")
echo "Foreign xDAI init tx " $FOREIGN_INIT_TX_HASH

# TODO: call setErcToNativeBridgesAllowed



# Home.initialize(
#         address _validatorContract,
#         uint256[3] _dailyLimitMaxPerTxMinPerTxArray, // [ 0 = _dailyLimit, 1 = _maxPerTx, 2 = _minPerTx ]
#         uint256 _homeGasPrice,
#         uint256 _requiredBlockConfirmations,
#         address _blockReward,
#         uint256[2] _foreignDailyLimitForeignMaxPerTxArray, // [ 0 = _foreignDailyLimit, 1 = _foreignMaxPerTx ]
#         address _owner,
#         int256 _decimalShift
#     )