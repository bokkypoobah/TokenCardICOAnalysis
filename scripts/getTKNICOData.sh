#!/bin/sh

geth attach << EOF | grep "RESULT: " | sed "s/RESULT: //"
// geth attach << EOF

var icoAddress = "0x49edf201c1e139282643d5e7c6fb0c7219ad1db7";
var tknTokenAddress = "0x65b9d9b96bcce0b89d807413e4703d2c7451593a";
var tokenABI = [{"constant":false,"inputs":[{"name":"_spender","type":"address"},{"name":"_value","type":"uint256"}],"name":"approve","outputs":[{"name":"success","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"name":"totalSupply","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_from","type":"address"},{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transferFrom","outputs":[{"name":"success","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"}],"name":"balanceOf","outputs":[{"name":"balance","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transfer","outputs":[{"name":"success","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"},{"name":"_spender","type":"address"}],"name":"allowance","outputs":[{"name":"remaining","type":"uint256"}],"payable":false,"type":"function"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_from","type":"address"},{"indexed":true,"name":"_to","type":"address"},{"indexed":false,"name":"_value","type":"uint256"}],"name":"Transfer","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_owner","type":"address"},{"indexed":true,"name":"_spender","type":"address"},{"indexed":false,"name":"_value","type":"uint256"}],"name":"Approval","type":"event"}];
var tknToken = web3.eth.contract(tokenABI).at(tknTokenAddress);

var icoFirstTxBlock = 3638466;
var icoLastTxBlock = 3638577;
var tknTokenBalanceBlock = parseInt(icoLastTxBlock) + 100;
// icoLastTxBlock = parseInt(icoFirstTxBlock) + 4;

console.log("RESULT: Account\tBlock\tCcy\t#\tAmount\tEthers\tTokens");

function getEtherData() {
  var contributionsByAccounts = {};

  var count = 0;
  for (var i = icoFirstTxBlock; i <= icoLastTxBlock; i++) {
    var block = eth.getBlock(i, true);
    if (block != null && block.transactions != null) {
      block.transactions.forEach( function(e) {
        var txR = eth.getTransactionReceipt(e.hash);
        if (e.to == icoAddress && e.gas != txR.gasUsed) {
          count++;
          var ethers = web3.fromWei(e.value, "ether");
          var tokenBalance = tknToken.balanceOf(e.from, tknTokenBalanceBlock).div(1e8);
          console.log("RESULT: " + e.from + "\t" + e.blockNumber + "\tETH\t" + count + "\t" + ethers + "\t" + ethers + "\t" + tokenBalance);
          // if (e.from in contributionsByAccounts) {
            //  var amt = contributionsByAccounts[e.from];
            // amt = amt.plus(e.value);
            // contributionsByAccounts[e.from] = amt;
          // } else {
            // contributionsByAccounts[e.from] = new BigNumber(e.value);
          // }
        }
      });
    }
  }
  // console.log("RESULT: Type\tAccount\tEthers\tTokens\tTokensPerEther");
  // for (var account in contributionsByAccounts) {
    //   var tokenBalance = tknToken.balanceOf(account, tknTokenBalanceBlock);
    // var ethers = contributionsByAccounts[account];
    // var tokensPerEther = tokenBalance.mul(1e10).div(ethers);
    // console.log("RESULT: Balance\t" + account + "\t" + web3.fromWei(ethers, "ether") + "\t" + tokenBalance.div(1e8) + "\t" + tokensPerEther);
  // }
}

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

function getTokenData() {
  addToken("REP", "0x48c80f1f4d53d5951e5d5438b54cba84f29f32a5", 18, 26, 18, 16.12);
  addToken("DGD", "0xe0b7927c4af23765cb51314a0e0521a9645f0e2a", 9, 17, 9, 30.408);
  addToken("GNT", "0xa74476443119a942de498590fe1f2454d7d4ac0d", 18, 26, 18, 0.203);
  addToken("MLN", "0xbeb9ef514a379b997e0798fdcc901ee474b6d9a1", 18, 26, 18, 36.70);
  addToken("SWT", "0xb9e7f8568e08d5659f5d29c4997173d84cdf2607", 18, 26, 18, 1.38);
  addToken("MKR", "0xc66ea802717bfb9833400264dd12c2bceaa34a6d", 18, 26, 18, 75.40);
  addToken("SNGLS", "0xaec2e87e0a235266d9c5adc9deb4b2e29b54d009", 0, 8, 0, 0.1029);

  var ethPrice = 75.00;

  var count = 0;
  var filter = web3.eth.filter({fromBlock: icoFirstTxBlock, toBlock: icoLastTxBlock, topics: [["0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef"]]});
  filter.watch(function(e, r) {
    // console.log(JSON.stringify(r));
    var fromAddress = "0x" + r.topics[1].substring(26, 66);
    var toAddress = "0x" + r.topics[2].substring(26, 66);
    if (toAddress == icoAddress) {
      count++;
      var token = tokenByAddress[r.address];
      var decimals = token.decimals;
      var amount = new BigNumber(r.data.substring(2, 66), 16);
      amount = amount.shift(-decimals);
      var ethEquivalent = amount.mul(token.price).div(ethPrice);
      var tokenBalance = tknToken.balanceOf(fromAddress, tknTokenBalanceBlock).div(1e8);
      // console.log("  " + fromAddress + " => " + toAddress + " " + token.token + " decimals=" + decimals + " amount=" + amount + " ethEquivalent=" + ethEquivalent + " tokenBalance=" + tokenBalance);
      console.log("RESULT: " + fromAddress + "\t" + r.blockNumber + "\t" + token.token + "\t" + count + "\t" + amount + "\t" + ethEquivalent + "\t" + tokenBalance);
    }
  });
}

getEtherData();
getTokenData();

EOF
