/* Tests for the ClearingHouse contract */

var ClearingHouse = artifacts.require("./ClearingHouse.sol");
var Token         = artifacts.require("zeppelin-solidity/contracts/token/ERC20/StandardToken.sol");
var BigNumber     = require("bignumber.js");


contract("ClearingHouse", function(accounts) {

  let CH, TA, TB;

  const writer   = accounts[0];
  const buyer    = accounts[1];
  const stranger = accounts[2];

  const setupEnv = async function() {
      CH = ClearingHouse.new();
      TA = Token.new();
      TB = Token.new();
      
      // Give everyone token balances
  }

  const deposit = async function() {
  }

  const buyOption = async function() {
  }

  describe("Deposit", function() {
    before(async function() {
      CH = await ClearingHouse.new();
    });
    it("should deposit tokens");
  });

  describe("Withdrawal", function() {
    before(async function() {
      CH = await ClearingHouse.new();
      await deposit();
    });
    it("should withdraw tokens");
  });

  describe("Buy option", function() {
    before(async function() {
      CH = await ClearingHouse.new();
      await deposit();
    });
    it("should buy an option");
    it("should fail to buy an invalid option");
  });

  describe("Exercise option", function() {
    before(async function() {
      await deposit();
      await buyOption();
    });
    it("should exercise an option");
    it("should fail to exercise an expired option");
  });

  describe("Refund option", function() {
    before(async function() {
      await deposit();
      await buyOption();
    });
    it("should fail to refund the option early");
    it("should refund the option");
  });

});
