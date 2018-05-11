pragma solidity 0.4.19;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

contract DataCenter is Ownable {

  uint public constant CONFIRM_RESULT_BONUS = 10;
  uint public constant NEED_CONFIRMATIONS = 6;

  // NBA all star game pts may greater than 255
  struct DataItem {
    bytes32 gameId;
    string detailDataHash;
    uint16 leftPts;
    uint16 rightPts;
    uint8 confirmations;
  }

  mapping (bytes32 => DataItem) public dataCenter;

  /**
   * @dev save game result only be invoked once
   * @param gameId indicate the unique id of game
   */
  modifier onlyOnce (bytes32 gameId) {
    require(dataCenter[gameId].gameId != gameId);
    _;
  }

  /**
   * @dev make sure game result have saved
   * @param gameId indicate the unique id of game
   */
  modifier gameExist (bytes32 gameId) {
    require(dataCenter[gameId].gameId == gameId);
    _;
  }

  /**
   * @dev prevent user invoke when confirmations is enough
   * @param gameId indicate the unique id of game
   */
  modifier confirmationNotEnough (bytes32 gameId) {
    require(dataCenter[gameId].confirmations < NEED_CONFIRMATIONS);
    _;
  }

  function () public payable {}
  function DataCenter() public {

  }

  /**
   * @dev save game result
   * @param gameId indicate the unique id of game
   * @param leftPts the score or points of left team gained(In football left team means home team, in NBA left team means away team)
   * @param rightPts the score or points of right team gained(In football right team means away team, in NBA left team means home team)
   * @param hash indicate the IPFS hash of this game s detail data
   */
  function saveResult(bytes32 gameId, uint16 leftPts, uint16 rightPts, string hash) onlyOwner onlyOnce(gameId) public {
    dataCenter[gameId].gameId = gameId;
    dataCenter[gameId].detailDataHash = hash;
    dataCenter[gameId].leftPts = leftPts;
    dataCenter[gameId].rightPts = rightPts;
    dataCenter[gameId].confirmations = 1;
  }

  /**
   * @dev get result of a game and confirmations (simple result)
   * @param gameId indicate the unique id of game
   */
  function getResult(bytes32 gameId) view public returns (uint16, uint16, uint8) {
    return (dataCenter[gameId].leftPts, dataCenter[gameId].rightPts, dataCenter[gameId].confirmations);
  }

  /**
   * @dev encourage user to participant with result audition
   * @param gameId indicate the unique id of game
   * @param leftPts the score or points of left team gained(In football left team means home team, in NBA left team means away team)
   * @param rightPts the score or points of right team gained(In football right team means away team, in NBA left team means home team)
   */
  function confirmResult(bytes32 gameId, uint leftPts, uint rightPts) gameExist(gameId) confirmationNotEnough(gameId) public {
    if (dataCenter[gameId].leftPts == leftPts && dataCenter[gameId].rightPts == rightPts) {
      dataCenter[gameId].confirmations += 1;
      //rewardERC20(msg.sender);
    }
  }

  /**
   * @dev distribute reward to participants of auditing game result
   * @param addr the address to receive rewards
   */
  function rewardERC20(address addr) internal {
    addr.transfer(CONFIRM_RESULT_BONUS);
  }
}
