pragma solidity ^0.4.8;

import "DAS.sol";
import "UGToken.sol";

// Trade contract 
contract Trade {
    
    // creator
    address public creator;
    
    struct SellInfo{
        uint price;
        bytes32 proveHash;
    }
    // asset on selling
    mapping(uint64 => SellInfo) onSelling;
    // the count of the asset on selling
    uint64 public onSellingCount;
    uint64[] onSellingList;
    
    DAS das;
    UGToken ugToken;
    
    function Trade(address _dasAddr, address _ugToken){
        das = DAS(_dasAddr);
        ugToken = UGToken(_ugToken);
    }
    
    // sell asset
    function sell(uint64 _gameId,uint64 _assetId, uint price,bytes32 proveHash) returns (bool){
        address addr = das.getAddressByGameId(_gameId);
        if(addr != msg.sender){
            throw;
        }
        address _sellerPlayer = das.getPlyerByAssetId(_assetId);
        uint64 playerIndex = das.getAddressIndex(msg.sender);
        // if the player does not own the asset , return false
        if(!das.isPlayerContainAsset(_sellerPlayer,_gameId,_assetId)){
            return false;
        }
        // if the asset is on sell, retrun false
        if(das.getSellingStatusByAssetId(_assetId)){
            return false;
        }
        
        onSelling[_assetId] = SellInfo(price,proveHash);
        onSellingList.push(_assetId);
        das.setSellingStatus(_assetId,true);
        onSellingCount++;
        Sell(_sellerPlayer,playerIndex,_gameId,das.getTokenByAssetId(_assetId),_assetId);
        return true;
    }
    
    function buy(uint64 _gameId, uint64 _assetId) returns (bool){
        
        address _sellerPlayer = das.getPlyerByAssetId(_assetId);
        
        if(!das.isPlayerContainAsset(_sellerPlayer,_gameId,_assetId)){
            return false;
        }
        if(!das.getSellingStatusByAssetId(_assetId)){
            return false;
        }
        if(!ugToken.transferFrom(msg.sender,_sellerPlayer,onSelling[_assetId].price)){
            return false;
        }
        das.setSellingStatus(_assetId,false);
        delete onSelling[_assetId];
        for(uint i = 0 ; i < onSellingList.length; i++){
            if(_assetId == onSellingList[i]){
                delete onSellingList[i];
                break;
            }
        }
        uint64 sellerIndex = das.getAddressIndexOrCreate(_sellerPlayer);
        uint64 buyerIndex = das.getAddressIndexOrCreate(msg.sender);
        das.transferAsset(sellerIndex,buyerIndex,_gameId,_assetId);
        onSellingCount--;
        Buy(_sellerPlayer,sellerIndex,msg.sender,buyerIndex,_gameId,das.getTokenByAssetId(_assetId),_assetId);
    }
    
    function getAllOnSelling() constant returns (bytes){
        bytes memory ret = new bytes(onSellingCount * (32 + 32 + 32));
        uint j = 0;
        for(uint i = 0 ; i < onSellingList.length ; i++){
            uint64 index = onSellingList[i];
            if(index > 0){
                var sellInfo = onSelling[index];
                uint price = sellInfo.price;
                bytes32 proveHash = sellInfo.proveHash;
                uint offset = 32 + j * (32 + 32 + 32);
                j++;
                assembly {
                    mstore(add(ret,offset),price)
                    mstore(add(ret,add(offset,0x20)),proveHash)
                    mstore(add(ret,add(offset,0x40)),index)
                }
            }
        }
        return ret;
    }
    
    event Sell(address _seller, uint64 _sellerIndex, uint64 _gameId, bytes32 _asset, uint64 _assetIndex);
    event Buy(address _owner, uint64 _ownerIndex,address __buyer,uint64 _buyerIndex, uint64 _gameId, bytes32 _asset, uint64 _assetIndex);
}

