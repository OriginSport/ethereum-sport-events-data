pragma solidity 0.4.19;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

contract DataCenter is Ownable {
  using SafeMath for uint;

  struct DataItem {
    bytes32 gameId;
    bytes32 result;
    bytes32 detailDataHash;
  }

  mapping (bytes32 => DataItem) dataCenter;

  modifier onlyOnce (bytes32 gameId) {_;}

  function () public payable {}
  function DataCenter() public {

  }

  function saveResult(bytes32 gameId, bytes32 result, bytes32 hash) onlyOwner onlyOnce(gameId) public {
    dataCenter[gameId].gameId = gameId;
    dataCenter[gameId].result = result;
    dataCenter[gameId].detailDataHash = hash;
  }

  function getResult(bytes32 gameId) view public returns (bytes32) {
    return dataCenter[gameId].result;
  }

  function getDetailDataHash(bytes32 gameId) view public returns (bytes32) {
    return dataCenter[gameId].detailDataHash;
  }
}

 
