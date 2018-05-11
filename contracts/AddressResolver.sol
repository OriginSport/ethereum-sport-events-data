pragma solidity ^0.4.19;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

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
