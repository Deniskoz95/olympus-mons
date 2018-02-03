pragma solidity ^0.4.10;


import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/tokens/ERC20.sol';


/** @title Simple options clearing house for ERC20 tokens (including W-eth) */
contract ClearingHouse {
  using SafeMath for uint256;


  /* STATE */

  /** Unrestricted token balances, which can be used to cover options or 
   *  withdrawn 
   */ 
  mapping(address => mapping(address => uint256)) public tokenBalances;

  /** Known contracts */
  mapping(bytes32 => bool) public contracts;

  /** Used to generate a unique integer id for each contract */
  uint256 internal freshContractId = 0;



  /* EVENTS */

  /** Emitted when a new contract is bought.  */
  event LogNewContract(bytes32 contractHash, bytes32 key);



  /* DEPOSIT & WITHDRAWAL */

    /** Fund a token wallet */
  function deposit(ERC20 token, uint256 amount)
    public
  {
    
    require(token != address(0) && amount > 0);
    
    // Deposit tokens
    token.transferFrom(msg.sender, this, amount);
    tokenBalances[msg.sender][token] =
      tokenBalances[msg.sender][token].add(amount);

  }

  /** Withdraw tokens */
  function withdraw(ERC20 token, address recipient, uint256 amount)
    public
  {
    require(token != address(0));
    require(recipient != address(0));
    require(amount > 0);
    require(amount <= tokenBalances[msg.sender][token]);
    token.transfer(recipient, amount);
  }



  /** OPTIONS TRADING */

  /** Buy a put */
  function buyPut(
    address writer,
    address writerAsset,
    uint256 writerAssetQuantity,
    address buyerAsset,
    uint256 buyerAssetQuantity,
    uint256 expiration,
    
    // Writer's signature
    uint8 v,
    bytes32 r,
    bytes32 s
  )
    public
    payable
  {

    // Compute the digest of the contract data
    bytes32 contractHash = 
      keccak256( writer
               , writerAsset
               , writerAssetQuantity
               , msg.sender
               , buyerAsset
               , buyerAssetQuantity
               , expiration
               , msg.value ) // option price

    // Verify that the named writer did sign this contract 
    require(writer == ecrecover(contractHash, v, r, s));

    // Cover the writer side of the contract 
    // Note: SafeMath throws if the result would be negative
    tokenBalances[writer][writerAsset] =
      tokenBalances[writer][writerAsset].sub(writerAssetQuantity);

    // Cover the buyer side of the contract
    tokenBalances[msg.sender][buyerAsset] =
      tokenBalances[msg.sender][buyerAsset].sub(buyerAssetQuantity);
   
    // Designate the contract active
    bytes32 contractKey = keccak256(contractHash, freshContractId);
    freshContractId += 1;
    contracts[contractKey] = true;

    // Pay the writer
    writer.transfer(msg.value);

    // Inform everyone
    LogNewContract(contractHash, contractKey);

  }

  /** Exercise a put */

  /** Buy a call */

  /** Exercise a call */

  /** Refund contract deposits */


}
