pragma solidity ^0.4.10;


import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/tokens/ERC20.sol';


/** @title Simple options clearing house for ERC20 tokens (including W-eth) */
contract ClearingHouse {
  using SafeMath for uint256;

  // Possible option contract statuses
  struct Status {
    None,
    Active,
    Closed
  }


  /* STATE */

  /** Unrestricted token balances, which can be used to cover options or 
   *  withdrawn 
   */ 
  mapping(address => mapping(address => uint256)) public tokenBalances;

  /** Options contract state */
  mapping(bytes32 => Status) public contracts;

  /** Table of contract buyers */
  mapping(bytes32 => address) public buyers;



  /* EVENTS */

  /** Emitted when a new contract is bought.  */
  event LogNewContract(bytes32 contractHash);

  /** Emitted when an option is exercised */
  event LogOptionExercised(bytes32 contractHash);

  /** An option contract expires and the parties are refunded */
  event LogRefunded(bytes32 contractHash);



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

  /** Buy an option 
   *  Anyone can buy an available option.
   *  @param writer address of the option writer
   *  @param writerAsset address of the ERC20 token that the option buyer is buying
   *  @param writerAssetQuantity amount of writer's asset to transfer to the buyer
   *  @param buyerAsset address of th ERC20 token that the option buyer is selling
   *  @param buyerAssetQuantity amount of asset to sell
   *  @param expiration the expiration date of the option
   *  @param nonce used to distinguish contracts with the same description
   *  @param v signature part 
   *  @param r signature part
   *  @param s signature part
   */
  function buyOption(
    address writer,
    address writerAsset,
    uint256 writerAssetQuantity,
    address buyerAsset,
    uint256 buyerAssetQuantity,
    uint256 expiration,

    uint256 nonce, 

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
               , buyerAsset
               , buyerAssetQuantity
               , expiration
               , msg.value // option price
               , nonce )

    // Verify that the named writer did sign this contract 
    require(writer == ecrecover(contractHash, v, r, s));

    // Verify that the option is available
    require(contracts[contractHash] == Status.None);

    // Cover the writer side of the contract 
    // Note: SafeMath throws if the result would be negative
    tokenBalances[writer][writerAsset] =
      tokenBalances[writer][writerAsset].sub(writerAssetQuantity);

    // Cover the buyer side of the contract
    tokenBalances[msg.sender][buyerAsset] =
      tokenBalances[msg.sender][buyerAsset].sub(buyerAssetQuantity);
   
    // Update contract state 
    contracts[contractHash] = Status.Active;
    buyers[contractHash] = msg.sender;

    // Pay the writer
    writer.transfer(msg.value);

    // Inform everyone
    LogNewContract(contractHash);

  }


  /** Exercise an option
   *  @param writer address of the option writer
   *  @param writerAsset address of the ERC20 token that the option buyer is buying
   *  @param writerAssetQuantity amount of writer's asset to transfer to the buyer
   *  @param buyerAsset address of th ERC20 token that the option buyer is selling
   *  @param buyerAssetQuantity amount of asset to sell
   *  @param expiration the expiration date of the option
   *  @param price the ether price of the option
   *  @param nonce used to distinguish contracts with the same description
   */
  function exercise(
    writer,
    writerAsset,
    writerAssetQuantity,
    buyerAsset,
    buyerAssetQuantity,
    expiration,
    price,
    nonce
  )
    public
  {

    // Compute the digest of the contract data
    bytes32 contractHash = 
      keccak256( writer
               , writerAsset
               , writerAssetQuantity
               , buyerAsset
               , buyerAssetQuantity
               , expiration
               , price
               , nonce )
   
    require(contracts[contractHash] == Status.Active];
    require(msg.sender == buyers[contractHash]);
    require(now <= expiration);

    // Pay the writer
    tokenBalances[writer][buyerAsset] =
      tokenBalances[writer][buyerAsset].add(buyerAssetQuantity);

    // Pay the buyer
    tokenBalances[msg.sender][writerAsset] =
      tokenBalances[msg.sender][writerAsset].add(writerAssetQuantity);

    // Update contract status
    contracts[contractHash] = Status.Closed;

    LogOptionExercised(contractHash);

  }


  /** Refund contract deposits */
  function refund(
    writer,
    writerAsset,
    writerAssetQuantity,
    buyerAsset,
    buyerAssetQuantity,
    expiration,
    price,
    nonce
  )
    public
  {
 
    // Compute the digest of the contract data
    bytes32 contractHash = 
      keccak256( writer
               , writerAsset
               , writerAssetQuantity
               , buyerAsset
               , buyerAssetQuantity
               , expiration
               , price
               , nonce )
    
    // The option needs to be expired
    require(expiration < now);

    // The contract has to be active 
    require(contracts[contractHash] == Status.Active);

    // Refund the writer
    tokenBalances[writer][writerAsset] =
      tokenBalances[writer][writerAsset].add(writerAssetQuantity);

    // Refund the buyer
    address buyer = buyers[contractHash];
    tokenBalances[buyer][buyerAsset] = 
      tokenBalances[buyer][buyerAsset].add(buyerAssetQuantity);

    // Update the status
    contracts[contractHash] = Status.Closed;

    LogRefunded(contractHash);

  }

}
