#!/bin/sh

geth attach << EOF | grep "RESULT: " | sed "s/RESULT: //"
// geth attach << EOF

var icoAddress = "0x49edf201c1e139282643d5e7c6fb0c7219ad1db7";
var oldTokenAddress = "0x65b9d9b96bcce0b89d807413e4703d2c7451593a";
var newTokenAddress = "0xaaaf91d9b90df800df4f55c205fd6989c977e73a";
// var tokenABI = [{"constant":false,"inputs":[{"name":"_spender","type":"address"},{"name":"_value","type":"uint256"}],"name":"approve","outputs":[{"name":"success","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"name":"totalSupply","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_from","type":"address"},{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transferFrom","outputs":[{"name":"success","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"}],"name":"balanceOf","outputs":[{"name":"balance","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transfer","outputs":[{"name":"success","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"},{"name":"_spender","type":"address"}],"name":"allowance","outputs":[{"name":"remaining","type":"uint256"}],"payable":false,"type":"function"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_from","type":"address"},{"indexed":true,"name":"_to","type":"address"},{"indexed":false,"name":"_value","type":"uint256"}],"name":"Transfer","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_owner","type":"address"},{"indexed":true,"name":"_spender","type":"address"},{"indexed":false,"name":"_value","type":"uint256"}],"name":"Approval","type":"event"}];
var tokenABI = [{"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"type":"function"},{"constant":false,"inputs":[{"name":"_spender","type":"address"},{"name":"_value","type":"uint256"}],"name":"approve","outputs":[{"name":"success","type":"bool"}],"type":"function"},{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"name":"","type":"uint256"}],"type":"function"},{"constant":false,"inputs":[{"name":"from","type":"address"},{"name":"to","type":"address"},{"name":"value","type":"uint256"}],"name":"transferFrom","outputs":[{"name":"","type":"bool"}],"type":"function"},{"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"","type":"uint8"}],"type":"function"},{"constant":false,"inputs":[{"name":"_for","type":"address"},{"name":"tokenCount","type":"uint256"}],"name":"issueTokens","outputs":[{"name":"","type":"bool"}],"type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"}],"name":"balanceOf","outputs":[{"name":"balance","type":"uint256"}],"type":"function"},{"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"type":"function"},{"constant":false,"inputs":[{"name":"to","type":"address"},{"name":"value","type":"uint256"}],"name":"transfer","outputs":[{"name":"","type":"bool"}],"type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"},{"name":"_spender","type":"address"}],"name":"allowance","outputs":[{"name":"remaining","type":"uint256"}],"type":"function"},{"inputs":[],"type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"name":"from","type":"address"},{"indexed":true,"name":"to","type":"address"},{"indexed":false,"name":"value","type":"uint256"}],"name":"Transfer","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"owner","type":"address"},{"indexed":true,"name":"spender","type":"address"},{"indexed":false,"name":"value","type":"uint256"}],"name":"Approval","type":"event"}];
var oldToken = web3.eth.contract(tokenABI).at(oldTokenAddress);
var newToken = web3.eth.contract(tokenABI).at(newTokenAddress);

var icoContractCreationBlock = 3637733;
var tokenFillStartBlock = 3661031;
var newTokenFillEndBlock = 3661054;
var icoFirstTxBlock = 3638466;
var icoLastTxBlock = 3638577;
var tknTokenBalanceBlock = parseInt(icoLastTxBlock) + 200;
var newTokenFilledBlock = 3661054;
// Test
// icoLastTxBlock = parseInt(icoFirstTxBlock) + 4;
// newTokenFillEndBlock = parseInt(tokenFillStartBlock) + 1;

var maxPlaces = 4;

var tokens = [];
var tokenInfo = {};
var tokenByAddress = {};

function addToken(token, address, decimals, width, places, price) {
  var diff = 0;
  if (places > maxPlaces) {
    diff = places - maxPlaces;
  }
  var contract = web3.eth.contract(tokenABI).at(address);
  tokens.push(token);
  tokenInfo[token] = { "token": token, "address": address, "decimals": decimals, "width": (width - diff), "places": (places - diff), "total": new BigNumber(0), "price": price };
  tokenByAddress[address] = { "token": token, "contract": contract, "decimals": decimals, "price": price };
  // console.log("RESULT: " + token + " decimals=" + decimals + ", width=" + (width - diff) + ", places=" + (places - diff));
}


var icoLastTxBlock;
var icoLastTxTxId;

// From the analysis, we know the last valid transaction is https://etherscan.io/tx/0xce7c2a9ee12480ced78d4ec940fc8776a872d6455e6acf62de8cbd3b0dd175f6 from address https://etherscan.io/address/0xf4adb9ba51fde3eaee89ce9a60e99992611849fd
// https://etherscan.io/address/0xf4adb9ba51fde3eaee89ce9a60e99992611849fd
// There is a previous transaction from this address in https://etherscan.io/tx/0xe57c9314472eff0b77caffc6c9aecce607f3fa29311615c;84e82e53d82a1c8cb 
function getLastEtherTxRefund() {
  var lastContributionAddress = "0xf4adb9ba51fde3eaee89ce9a60e99992611849fd";
  var lastContributionAddressTxHash1 = "0xe57c9314472eff0b77caffc6c9aecce607f3fa29311615c84e82e53d82a1c8cb";
  var lastContributionAddressTxHash2 = "0xce7c2a9ee12480ced78d4ec940fc8776a872d6455e6acf62de8cbd3b0dd175f6";
  var lastContributionAddressTx1 = eth.getTransaction(lastContributionAddressTxHash1);
  var lastContributionAddressTx2 = eth.getTransaction(lastContributionAddressTxHash2);
  var lastContributionValue = lastContributionAddressTx1.value.plus(lastContributionAddressTx2.value);
  // console.log("Last contribution ETH balance: " + web3.fromWei(lastContributionValue, "ether"));
  var lastContributionTokenBalance = newToken.balanceOf(lastContributionAddress, newTokenFilledBlock);
  // console.log("Last contribution TKN balance: " + lastContributionTokenBalance.div(1e8));
  var lastContributionRefund = lastContributionValue.minus(lastContributionTokenBalance.mul(1e8));
  // console.log("Last contribution ETH refund: " + web3.fromWei(lastContributionRefund, "ether"));
  icoLastTxBlock = eth.getTransactionReceipt(lastContributionAddressTxHash2).blockNumber;
  icoLastTxTxId = eth.getTransactionReceipt(lastContributionAddressTxHash2).transactionIndex;
  // console.log("Last contribution BlockNumber.TxIndex: " + icoLastTxBlock + "." + icoLastTxTxId);
  console.log("RESULT: " + lastContributionAddress + "\t" + icoLastTxBlock + "\t" + icoLastTxTxId + "\tETH\t0\t" + web3.fromWei(lastContributionRefund, "ether") + "\t" + lastContributionAddressTxHash2);
}


function getTokenRefunds() {
    
  addToken("REP", "0x48c80f1f4d53d5951e5d5438b54cba84f29f32a5", 18, 26, 18, 16.12);
  addToken("DGD", "0xe0b7927c4af23765cb51314a0e0521a9645f0e2a", 9, 17, 9, 30.408);
  addToken("GNT", "0xa74476443119a942de498590fe1f2454d7d4ac0d", 18, 26, 18, 0.203);
  addToken("MLN", "0xbeb9ef514a379b997e0798fdcc901ee474b6d9a1", 18, 26, 18, 36.70);
  addToken("SWT", "0xb9e7f8568e08d5659f5d29c4997173d84cdf2607", 18, 26, 18, 1.38);
  addToken("MKR", "0xc66ea802717bfb9833400264dd12c2bceaa34a6d", 18, 26, 18, 75.40);
  addToken("SNGLS", "0xaec2e87e0a235266d9c5adc9deb4b2e29b54d009", 0, 8, 0, 0.1029);
  addToken("AMIS", "0x949bed886c739f1a3273629b3320db0c5024c719", 9, 16, 9, 0);
  addToken("EDG", "0x08711d3b02c8758f2fb3ab4e80228418a7f8e39c", 0, 8, 0, 0);
  addToken("GUP", "0xf7b098298f7c69fc14610bf71d5e02c60792894c", 3, 11, 3, 0);
        
  // console.log("RESULT: Last contribution BlockNumber.TxIndex: " + icoLastTxBlock + "." + icoLastTxTxId);
  var count = 0;
  // var filter = web3.eth.filter({fromBlock: parseInt(icoLastTxBlock) - 1, toBlock: parseInt(icoLastTxBlock) + 1, topics: [["0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef"]]});
  // var filter = web3.eth.filter({fromBlock: 3639135, toBlock: 3641574, topics: [["0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef"]]});
  // var filter = web3.eth.filter({fromBlock: 3639135, toBlock: "latest", topics: [["0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef"]]});
  // var filter = web3.eth.filter({fromBlock: 3649580, toBlock: 3649580 , topics: [["0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef"]]});
  var filter = web3.eth.filter({fromBlock: icoContractCreationBlock, toBlock: "latest", topics: [["0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef"]]});
  filter.watch(function(e, r) {
    try {
      // console.log("RESULT: " + JSON.stringify(r));
      // console.log("RESULT: Checking " + toAddress + " " + r.blockNumber + "." + r.transactionIndex + " " + r.transactionHash + " tokenAddress=" + r.address + " toAddress=" + r.topics[2]);
      var fromAddress = "0x" + r.topics[1].substring(26, 66);
      var toAddress = "0x" + r.topics[2].substring(26, 66);
      // console.log("Checking " + r.blockNumber + "." + r.transactionIndex + " r.address=" + r.address + " to=" + toAddress);
      var include = false;

      if (icoAddress == toAddress) {
        // console.log("RESULT: " + JSON.stringify(r));
        // console.log("RESULT: to " + toAddress + " " + r.blockNumber + "." + r.transactionIndex + " " + r.transactionHash + " " + JSON.stringify(r));
        if (r.blockNumber < icoFirstTxBlock) {
          include = true;
        } else if ((r.blockNumber - icoLastTxBlock) == 0 && (r.transactionIndex - icoLastTxTxId) > 0) {
          include = true;
        } else if (parseInt(r.blockNumber) > parseInt(icoLastTxBlock)) {
          include = true;
        }
      }
      if (include) {
        count++;
        // console.log("RESULT: " + count + " " + JSON.stringify(r));
        var token = tokenByAddress[r.address];
        if (token != null) {
          // console.log("RESULT: " + JSON.stringify(r));
          var decimals = token.decimals;
          var amount = new BigNumber(r.data.substring(2, 66), 16);
          amount = amount.shift(-decimals);
          console.log("RESULT: " + fromAddress + "\t" + r.blockNumber + "\t" + r.transactionIndex + "\t" + token.token + "\t" + count + "\t" + amount + "\t" + r.transactionHash);
        }
      }
    } catch (e) {
    }
  });
  filter.stopWatching();
}

console.log("RESULT: Account\tBlock\tTxIndex\tCcy\t#\tRefund\tTx");
getLastEtherTxRefund();
getTokenRefunds();

EOF
