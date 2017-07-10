pragma solidity ^0.4.13;

contract YourLuckyNumber {
    
    bool public ACCEPT_BET = true;
    uint public BALANCE;
    address public OWNER;
    mapping (address => uint) public INVESTING_LIST;
    address[] INVESTOR;
    
    modifier onlyOwner() {
        if (msg.sender != OWNER) {
            revert();
        }
        _;
    }
    
    modifier onlyInvestor() {
        if (! isInvestor(msg.sender)) {
            revert();
        }
        _;
    }
    
    modifier onlyWithValue() {
        if (msg.value == 0) {
            revert();
        }
        _;
    }
    
    modifier onlyAcceptBet() {
        if (! ACCEPT_BET) {
            revert();
        }
        _;
    }
    
    modifier onlyUnderMaxBet() {
        if (msg.value * 1980 >= BALANCE * 25) {
            revert();
        }
        _;
    }
    
    function changeAcceptBet(bool new_status) onlyOwner {
        ACCEPT_BET = new_status;
    }
    
    function changeOwner(address new_owner) onlyOwner {
        OWNER = new_owner;
    }
    
    function isInvestor(address addr) constant returns (bool) {
        for (uint i=0;i<INVESTOR.length;i++) {
            if (INVESTOR[i] == addr) {
                return true;
            }
        }
        return false;
    }
    
    function investorCount() constant returns (uint) {
        return INVESTOR.length;
    }

    function maxBetAmount() constant returns (uint) {
        return BALANCE * 495 / 1000000;
    }
    
    function locateInvestor(address addr) returns (uint) {
        for (uint i=0;i<INVESTOR.length;i++) {
            if (INVESTOR[i] == addr) {
                return i;
            }
        }
    }
    
    function isWin(uint bet) returns (bool) {
        if (block.difficulty % 2 == bet) {
            return true;
        } else {
            return false;
        }
    }
    
    function YourLuckyNumber() {
        OWNER = msg.sender;
    }
    
    function () payable onlyWithValue {
        if (isInvestor(msg.sender)) {
            INVESTING_LIST[msg.sender] += msg.value;
        } else {
            INVESTING_LIST[msg.sender] = msg.value;
            INVESTOR.push(msg.sender);
        }
        BALANCE += msg.value;
    }

    function withdraw() onlyInvestor {
        msg.sender.transfer(INVESTING_LIST[msg.sender]);
        BALANCE -= INVESTING_LIST[msg.sender];
        delete INVESTOR[locateInvestor(msg.sender)];
        delete INVESTING_LIST[msg.sender];
    }
    
    function goodLuck(uint luckyNumber) payable onlyWithValue onlyAcceptBet onlyUnderMaxBet {
        uint i = 0;
        uint bet = msg.value;
        if (isWin(luckyNumber)) {
            uint profit = bet * 198 / 100;
            for (i;i<INVESTOR.length;i++) {
                INVESTING_LIST[INVESTOR[i]] += bet * INVESTING_LIST[INVESTOR[i]] / BALANCE;
            }
            BALANCE += bet;
            for (i=0;i<INVESTOR.length;i++) {
                INVESTING_LIST[INVESTOR[i]] -= profit * INVESTING_LIST[INVESTOR[i]] / BALANCE;
            }
            BALANCE -= profit;
            msg.sender.transfer(profit);
        } else {
            for (i;i<INVESTOR.length;i++) {
                INVESTING_LIST[INVESTOR[i]] += bet * INVESTING_LIST[INVESTOR[i]] / BALANCE;
            }
            BALANCE += bet;
        }
    }
    
    function shutdown() onlyOwner {
        for (uint i=0;i<INVESTOR.length;i++) {
            INVESTOR[i].transfer(INVESTING_LIST[INVESTOR[i]]);
        }
        suicide(msg.sender);
    }
}
