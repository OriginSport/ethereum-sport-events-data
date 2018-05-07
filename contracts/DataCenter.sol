pragma solidity 0.4.19;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

contract DataCenter is Ownable {

  uint public constant CONFIRM_RESULT_BONUS = 10;
  uint public constant NEED_CONFIRMATIONS = 12;

  struct DataItem {
    bytes32 gameId;
    string detailDataHash;
    uint8 leftPts;
    uint8 rightPts;
    uint8 confirmations;
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
    require(dataCenter[gameId].confirmations < NEED_CONFIRMATIONS);
    _;
  }

  function () public payable {}
  function DataCenter() public {

  }

  function saveResult(bytes32 gameId, uint8 leftPts, uint8 rightPts, string hash) onlyOwner onlyOnce(gameId) public {
    dataCenter[gameId].gameId = gameId;
    dataCenter[gameId].detailDataHash = hash;
    dataCenter[gameId].leftPts = leftPts;
    dataCenter[gameId].rightPts = rightPts;
    dataCenter[gameId].confirmations = 0;
  }

  function confirmResult(bytes32 gameId, uint leftPts, uint rightPts) gameExist(gameId) confirmationNotEnough(gameId) public {
    if (dataCenter[gameId].leftPts == leftPts && dataCenter[gameId].rightPts == rightPts) {
      dataCenter[gameId].confirmations += 1;
      //rewardERC20(msg.sender);
    }
  }

  function rewardERC20(address addr) internal {
    addr.transfer(CONFIRM_RESULT_BONUS);
  }
}

