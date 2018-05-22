pragma solidity ^0.4.18;

// zeppelin-solidity: 1.8.0

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract AddressResolver is Ownable {

  address public addr;

  /**
   * @dev AddressResolver construct function to
   *      initial with owner
   */
  function AddressResolver() public {}

  /**
   * @dev get current available address
   */
  function getAddress() view public returns (address) {
    return addr;
  }

  /**
   * @dev set a new address(when datacenter contract update)
   * @param newaddr the new address of datacenter adress
   */
  function setAddr(address newaddr) onlyOwner public {
    addr = newaddr;
  }
}