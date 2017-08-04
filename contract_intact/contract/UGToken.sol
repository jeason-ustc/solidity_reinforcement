pragma solidity ^0.4.8;

import "./StandardToken.sol";

/**
 * UGT contract 
 */

contract UGToken is StandardToken {

    address public creator;

    function UGCToken() {
        creator = msg.sender;
    }

    function transferEther() payable returns (bool) {
        uint256 value = msg.value;
        balances[msg.sender] += 100 * value / (1 ether);
        TransferEther(msg.sender,value);
        return true;
    }

    function withdraw() noEther {
        uint256 value = balances[msg.sender];
        balances[msg.sender] = 0;
        if(value > 0){
            if(!(msg.sender.call.value(value)())){
                balances[msg.sender] = value;
                throw;
            }
        }
    }

    modifier noEther() {
        if(msg.value > 0) throw;
        _;
    }
    event TransferEther(address indexed addr, uint256 amount);
 }
