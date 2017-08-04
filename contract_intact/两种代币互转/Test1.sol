pragma solidity ^0.4.4;
contract Test1{
    int public arr1;
    int public arr2;
    address public creator;
    
    function Test1(){
        creator = msg.sender;
    }
    
    function set1(int num){
        arr1 = num;
    }
    
    function set2(int num){
        arr2 = num;
    }
    
    function get1() returns (int){
        return arr1;
    }
    
    function get2() returns (int){
        return arr2;
    }
}