pragma solidity ^0.4.4;
import "./Test1.sol";
contract Test2{
    Test1 public t1;

    address public creator;

    
    function Test2(address _test1Addr){
        t1 = Test1(_test1Addr);
    }

    function getFromTest1() returns (int){
        return t1.get1();
    }
    
    function getFromTest2() returns (int){
        return t1.get2();
    }
}