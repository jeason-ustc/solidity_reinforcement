pragma solidity ^0.4.8;

import "DAS.sol";
import "UGToken.sol";
// Recharge contact 

contract Recharge {
    
    address public creator;
    
    DAS das;
    UGToken ugToken;
    uint royaltyPercentage = 10;
    
    function Recharge(address _dasAddr,address _ugToken){
        das = DAS(_dasAddr);
        ugToken = UGToken(_ugToken);
        creator = msg.sender;
    }
    
    function pay(uint64 _gameId,uint64 _tradeId, address _seller, uint _amount) returns (bool){
        address channel = das.getChannelByPlayer(msg.sender,_gameId);
        if(channel != 0x00000000000000000000000000000000000000){
            uint toChannel = _amount * 10 / 100;
            _amount = _amount - toChannel;
            if(!ugToken.transferFrom(msg.sender,channel,toChannel)){
                throw;
            }
        }
        if(!ugToken.transferFrom(msg.sender,_seller,_amount)){
            throw;
        }
        Pay(_gameId, _tradeId, _seller, msg.sender,_amount);
        return true;
    }
    
    event Pay(uint64 _gameId,uint64 _tradeId, address _seller, address _payer,uint _amount);
}
