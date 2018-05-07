pragma solidity 0.4.19;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

contract DataCenter is Ownable {

  uint public constant CONFIRM_RESULT_BONUS = 10;
  uint public constant NEED_CONFIRMATIONS = 12;

  // NBA all star game pts may greater than 255
  struct DataItem {
    bytes32 gameId;
    string detailDataHash;
    uint16 leftPts;
    uint16 rightPts;
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

  function saveResult(bytes32 gameId, uint16 leftPts, uint16 rightPts, string hash) onlyOwner onlyOnce(gameId) public {
    dataCenter[gameId].gameId = gameId;
    dataCenter[gameId].detailDataHash = hash;
    dataCenter[gameId].leftPts = leftPts;
    dataCenter[gameId].rightPts = rightPts;
    dataCenter[gameId].confirmations = 1;
  }

  function getResult(bytes32 gameId) view public returns (uint16, uint16, uint8) {
    return (dataCenter[gameId].leftPts, dataCenter[gameId].rightPts, dataCenter[gameId].confirmations);
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
