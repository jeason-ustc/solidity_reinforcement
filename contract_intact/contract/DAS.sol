
pragma solidity ^0.4.8;

// DAS contract
contract DAS {
    
    // asset
    struct Asset {
        bytes32 aliasName;
        bytes32 token;
        uint64 ownerIndex;
        uint64 gameId;
        bool isOnSell;
    }
    
    struct GameMappingPlayer {
        uint64[] gameIds;
        mapping(uint64 => uint64) map;
    }
    
    struct PlayerOfChannelStore{
        uint64 playerCount;
        mapping(uint64 => uint64[]) players;
    }
    
    address public creator;
    
    uint64 public nonce;
    
    // The total of the game asset;
    uint64 public totalOfAsset;
    
    // The map which store total of each game asset by gameid
    mapping(uint64 => uint64) public totalOfAssetMapping;
    
    // List of the asset
    Asset []assets;
    
    mapping(bytes32 => uint64) assetIndexMapping;
    
    // The index of the asset
    mapping(uint64 => uint64[]) assetIndexes;
    
    // the list address of the all user
    address[] public playerOfAddress;
    // The index mapping of the address
    mapping(address => uint64) public addressIndexes;
    
    // the mapping for storeing the channel's address of given address 
    mapping(uint64 => GameMappingPlayer) channelOfPlayer;
    
    // the all palyer of the channel
    mapping(uint64 => PlayerOfChannelStore) playerOfChannel;
    
    struct GameServerInfo{
        bytes32 gameName;
        address gameAddress;
    }
    mapping(address => uint64) gameIdsMapping;
    GameServerInfo [] gameIds;
    
    function DAS(){
        playerOfAddress.length = 1;
        assets.length = 1;
        gameIds.length = 1;
        creator = msg.sender;
    }
  
    function () {
        
    }
    
    function getGameId(address gameProvider) constant returns (uint64){
        return gameIdsMapping[gameProvider];
    }
    
    function getAddressByGameId(uint64 _gameId) constant returns (address){
        return gameIds[_gameId].gameAddress;
    }
    
    function getGameNameByGameId(uint64 _gameId) constant returns (bytes32){
        return gameIds[_gameId].gameName;
    }
    
    function initGameId(bytes32 name) noGameId {
        uint64 index = uint64(gameIds.length++);
        gameIds[index] = GameServerInfo(name,msg.sender);
        gameIdsMapping[msg.sender] = index;
    }
    
    modifier noGameId() {
        if(gameIdsMapping[msg.sender] > 0) throw;
        _;
    }
    
    // Get the index with given address, if do not exist, create it and return 
    function getAddressIndexOrCreate(address _addr)  returns (uint64) {
        uint64 index = addressIndexes[_addr];
        if(index < 1){
            index = uint64(playerOfAddress.length++);
            playerOfAddress[index] = _addr;
            addressIndexes[_addr] = uint64(index);
        }
        return index;
    }
    
    // Get the index with given address 
    function getAddressIndex(address _addr) constant returns (uint64) {
        return addressIndexes[_addr];
    } 
    
    // Wheather the player own channel
    function isOwnChannel(uint64 _player, uint64 _gameId) constant internal returns (bool){
        return channelOfPlayer[_player].map[_gameId] > 0;
    }
    
    // set the channel
    function setChannel(uint64 _player, uint64 _gameId, uint64 _channelId) internal{
        channelOfPlayer[_player].map[_gameId] = _channelId;
        channelOfPlayer[_player].gameIds.push(_gameId);
        
        playerOfChannel[_channelId].players[_gameId].push(_player);
        playerOfChannel[_channelId].playerCount++;
    }
    
    // Get the channel number by given player
    function channelNumber(uint64 _player) constant internal returns (uint64) {
        return uint64(channelOfPlayer[_player].gameIds.length);
    }
    
    function getChannelNumberByPlayer(address _player) constant returns (uint64){
        uint64 index = getAddressIndex(_player);
        if(index < 1) return 0;
        return channelNumber(index);
    }
    
    // Get the player number by given channel
    function playerNumber(uint64 _channel) constant internal returns (uint64){
        return uint64(playerOfChannel[_channel].playerCount);
    }
    
    function getPlayerNumberByChannel(address _channel) constant returns (uint64){
        uint64 index = getAddressIndex(_channel);
        if(index < 1) return 0;
        return playerNumber(index);
    }
    
    // set the channel
    function channel(address _channel,uint64 _gameId) checkChannelExist(msg.sender,_gameId) returns (bool) {
        
        uint64 channelIndex = getAddressIndexOrCreate(_channel);
        uint64 playerIndex = getAddressIndexOrCreate(msg.sender);
        setChannel(playerIndex,_gameId,channelIndex);
        Channel(msg.sender,_channel,_gameId);
        return true;
    }
    
    // Init the token 
    function initGameToken(uint64 _gameId,bytes32 alias) returns (bool) {
        bytes32 token = sha3(nonce++,msg.sender);
        uint64 index = uint64(assets.length++);
        Asset asset = assets[index];
        asset.aliasName = alias;
        asset.token = token;
        asset.isOnSell = false;
        
        uint64 playerIndex = getAddressIndexOrCreate(msg.sender);
        asset.ownerIndex = playerIndex;
        asset.gameId = _gameId;
        
        var assetIndexArray = assetIndexes[playerIndex];
        assetIndexArray[assetIndexArray.length++] = uint64(index);
        totalOfAsset++;
        totalOfAssetMapping[_gameId] += 1;
        assetIndexMapping[token] = index;
        InitGameToken(msg.sender,playerIndex,_gameId,token,index);
        return  true;
    }
    
    function getIndexByToken(bytes32 token) constant returns (uint64){
        return assetIndexMapping[token];
    }
    
    function getPlyerByAssetId(uint64 _assetId) constant returns (address){
        uint64 ownerIndex = assets[_assetId].ownerIndex;
        return playerOfAddress[ownerIndex];
    }
    
    function transferAsset(uint64 _from, uint64 _to, uint64 _gameId, uint64 _assetId) returns (bool){
        uint64 index = 0;
        var fromIndexArray = assetIndexes[_from];
        var toIndexArray = assetIndexes[_to];
        if(assets[_assetId].ownerIndex != _from){
            return false;
        }
        for(index = 0 ; index < fromIndexArray.length ; index++){
            if(fromIndexArray[index] == _assetId){
                delete fromIndexArray[index];
                break;
            }
        }
        toIndexArray[toIndexArray.length++] = _assetId;
        assets[_assetId].ownerIndex = _to; 
    }
    
    function getChannelByPlayer(address _player, uint64 _gameId) constant returns (address channel){
        uint64 index = getAddressIndex(_player);
        if(index > 0) {
            uint64 channelIndex =  channelOfPlayer[index].map[_gameId];
            channel = playerOfAddress[channelIndex];
        }
    }
    
    function getPlayerToken(address _player,uint64 _gameId) constant returns (bytes){
        uint64 playerIndex = getAddressIndex(_player);
        var indexArray = assetIndexes[playerIndex];
        uint index = 0;
        uint64[] memory finded = new uint64[](100);
        uint number = 0;
        for(index = 0 ; index < indexArray.length ; index++){
            uint64 assetIndex = indexArray[index];
            if(assetIndex > 0 && assets[assetIndex].gameId == _gameId && assets[assetIndex].isOnSell == false){
                //finded.push(assetIndex);
                finded[number++] = assetIndex;
            }
        }
        return serializePlayerToken(finded,number);
    }
    
    function serializePlayerToken(uint64[] indexes,uint number) constant internal returns (bytes){
        bytes memory ret = new bytes(number * (32 + 32 + 32 + 8));
        for(uint i = 0 ; i < number; i++){
            var asset = assets[indexes[i]];
            bytes32 token = asset.token;
            bytes32 aliasName = asset.aliasName;
            uint64 gameId = asset.gameId;
            uint8 isOnSell = 0;
            if(asset.isOnSell == true){
                isOnSell = 1;
            }
            uint offset = 32 + i * (32 + 32 + 32 + 8);
            assembly {
                mstore(add(ret,offset),token)
                mstore(add(ret,add(offset,0x20)),aliasName)
                mstore(add(ret,add(offset,0x40)),gameId)
                mstore8(add(ret,add(offset,0x60)),isOnSell)
            }
        }
        return ret;
    }
    
    function getAssets(address _player) constant returns (bytes){
        uint64 playerIndex = getAddressIndex(_player);
        var indexArray = assetIndexes[playerIndex];
        uint index = 0;
        uint64[] memory finded = new uint64[](100);
        uint number = 0;
        for(index = 0 ; index < indexArray.length ; index++){
            uint64 assetIndex = indexArray[index];
            if(assetIndex > 0){
                //finded.push(assetIndex);
                finded[number++] = assetIndex;
            }
        }
        return serializePlayerToken(finded,number);
    }
    
    // Get the token by given assetId
    function getTokenByAssetId(uint64 _assetId) constant returns (bytes32){
        return assets[_assetId].token;
    }
    
    // Get the selling status by given assetId
    function getSellingStatusByAssetId(uint64 _assetId) constant returns (bool){
        return assets[_assetId].isOnSell;
    }
    
    function getAliasNameByAssetId(uint64 _assetId) constant returns (bytes32){
        return assets[_assetId].aliasName;
    }
    
    function setSellingStatus(uint64 _assetId, bool status) {
        assets[_assetId].isOnSell = status;
    }
    
    function isPlayerContainAsset(address _player,uint64 _gameId, uint64 _assetId) constant returns (bool){
        uint64 playerIndex = getAddressIndex(_player);
        if(playerIndex < 1) return false;
        var assetArray = assetIndexes[playerIndex];
        for(uint i = 0; i < assetArray.length; i++){
            if(assetArray[i] == _assetId){
                return true;
            }
        }
        return false;
    }
    
    modifier checkChannelExist(address _addr,uint64 gameId) {
        uint64 index = getAddressIndexOrCreate(_addr);
        if(isOwnChannel(index,gameId)) throw;
        _;
    }
    
    
    event InitGameToken(address _seller, uint64 _sellerIndex, uint64 _gameId, bytes32 _asset, uint64 _assetIndex);
    event Channel(address _player,address _channel,uint64 _gameId);
}

