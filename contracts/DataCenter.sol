pragma solidity 0.4.19;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

contract DataCenter is Ownable {

  uint public constant CONFIRM_RESULT_BONUS = 0;

  struct DataItem {
    bytes32 gameId;
    bytes32 result;
    string detailDataHash;
    uint confirmations;
  }

  mapping (bytes32 => DataItem) public dataCenter;

  modifier onlyOnce (bytes32 gameId) {
    require(dataCenter[gameId].gameId != gameId);
    _;
  }

  modifier gameExist (bytes32 gameId) {
    require(dataCenter[gameId].gameId == gameId);
    _;
  }

  modifier confirmationNotEnough (bytes32 gameId) {
    require(dataCenter[gameId].confirmations < 10);
    _;
  }

  function () public payable {}
  function DataCenter() public {

  }

  function saveResult(bytes32 gameId, bytes32 result, string hash) onlyOwner onlyOnce(gameId) public {
    dataCenter[gameId].gameId = gameId;
    dataCenter[gameId].result = result;
    dataCenter[gameId].detailDataHash = hash;
    dataCenter[gameId].confirmations = 0;
  }

  function confirmResult(bytes32 gameId, bytes32 result) gameExist(gameId) confirmationNotEnough(gameId) public {
    if (dataCenter[gameId].result == result) {
      dataCenter[gameId].confirmations += 1;
      // rewardERC20(msg.sender);
    }
  }

  function rewardERC20(address addr) internal {
    addr.transfer(CONFIRM_RESULT_BONUS);
  }
}

