
var Web3 = require('../index.js');
var web3 = new Web3();
web3.setProvider(new web3.providers.HttpProvider('http://localhost:8545'));

web3.eth.defaultAccount = web3.eth.coinbase;


var test1ABI=[{"constant":true,"inputs":[],"name":"creator","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"get1","outputs":[{"name":"","type":"int256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"arr1","outputs":[{"name":"","type":"int256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"num","type":"int256"}],"name":"set2","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"get2","outputs":[{"name":"","type":"int256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"num","type":"int256"}],"name":"set1","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"arr2","outputs":[{"name":"","type":"int256"}],"payable":false,"type":"function"},{"inputs":[],"payable":false,"type":"constructor"}];
var test1Data = "0x6060604052341561000f57600080fd5b5b33600260006101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff1602179055505b5b61024e806100626000396000f30060606040523615610081576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff16806302d05d3f14610086578063054c1a75146100db578063bc3dee8d14610104578063c7b0890f1461012d578063d2178b0814610150578063e48f28d214610179578063f2bf1b971461019c575b600080fd5b341561009157600080fd5b6100996101c5565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b34156100e657600080fd5b6100ee6101eb565b6040518082815260200191505060405180910390f35b341561010f57600080fd5b6101176101f5565b6040518082815260200191505060405180910390f35b341561013857600080fd5b61014e60048080359060200190919050506101fb565b005b341561015b57600080fd5b610163610206565b6040518082815260200191505060405180910390f35b341561018457600080fd5b61019a6004808035906020019091905050610211565b005b34156101a757600080fd5b6101af61021c565b6040518082815260200191505060405180910390f35b600260009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b6000805490505b90565b60005481565b806001819055505b50565b600060015490505b90565b806000819055505b50565b600154815600a165627a7a7230582062900e994df0cf4a90d2398ab9c75ea0f13b88074b649fe9ca1e410a197a83250029";
var test2ABI =[{"constant":true,"inputs":[],"name":"creator","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"getFromTest1","outputs":[{"name":"","type":"int256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"getFromTest2","outputs":[{"name":"","type":"int256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"t1","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"inputs":[{"name":"_test1Addr","type":"address"}],"payable":false,"type":"constructor"}];
var test2Data= "0x6060604052341561000f57600080fd5b6040516020806103b0833981016040528080519060200190919050505b806000806101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff1602179055505b505b6103328061007e6000396000f30060606040526000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff16806302d05d3f1461005f5780634ac009af146100b45780634cca4f83146100dd578063fb5343f314610106575b600080fd5b341561006a57600080fd5b61007261015b565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b34156100bf57600080fd5b6100c7610181565b6040518082815260200191505060405180910390f35b34156100e857600080fd5b6100f0610231565b6040518082815260200191505060405180910390f35b341561011157600080fd5b6101196102e1565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b600160009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b60008060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1663054c1a756000604051602001526040518163ffffffff167c0100000000000000000000000000000000000000000000000000000000028152600401602060405180830381600087803b151561021057600080fd5b6102c65a03f1151561022157600080fd5b5050506040518051905090505b90565b60008060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1663d2178b086000604051602001526040518163ffffffff167c0100000000000000000000000000000000000000000000000000000000028152600401602060405180830381600087803b15156102c057600080fd5b6102c65a03f115156102d157600080fd5b5050506040518051905090505b90565b6000809054906101000a900473ffffffffffffffffffffffffffffffffffffffff16815600a165627a7a72305820a78f246f620fd7d84b22d8a253ccf6c50c40f9f0b9e41b492a4b5bbcb091c3140029";
var test1;
var test2;


/*var ugToken;
var das;
var recharge;
var trade;
*/var status = 0;
function deploy(){
  var Test1_sol_Test1Contract = web3.eth.contract(test1ABI);
  test1 = Test1_sol_Test1Contract.new(
   {
     from: web3.eth.accounts[0],
     data: test1Data,
     gas: '4700000'
   }, Test1DeployedCallback);

}

function Test1DeployedCallback(e,contract){
  console.log(e,contract);
  _test1Addr = test1.address;
  if (typeof contract !== 'undefined' && typeof contract.address !== 'undefined') {
       console.log('Deploy test1 contract successfully! address: ' + contract.address + ' transactionHash: ' + contract.transactionHash);
       var test2_sol_dasContract=  web3.eth.contract(test2ABI);
       test2 = test2_sol_dasContract.new(_test1Addr,
         {
           from: web3.eth.accounts[0],
           data: test2Data,
           gas: '4700000'
         },test2DeployedCallback)
  }
}


function test2DeployedCallback(e,contract){

  if (typeof contract !== 'undefined' && typeof contract.address !== 'undefined') {
       status = 1;
       console.log('Deploy recharge contract successfully! address: ' + contract.address + ' transactionHash: ' + contract.transactionHash);
  }
}

deploy()
