pragma solidity 0.4.19;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

contract ERC20 {
  function totalSupply() public constant returns (uint);
  function balanceOf(address tokenOwner) public constant returns (uint balance);
  function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
  function transfer(address to, uint tokens) public returns (bool success);
  function approve(address spender, uint tokens) public returns (bool success);
  function transferFrom(address from, address to, uint tokens) public returns (bool success);
  event Transfer(address indexed from, address indexed to, uint tokens);
  event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract DataCenter is Ownable {

  uint public constant CONFIRM_RESULT_BONUS = 10 * 10 ** 18;
  uint public constant MAX_CONFIRMATIONS = 6;

  // NBA all star game pts may greater than 255
  struct DataItem {
    bytes32 gameId;
    string detailDataHash;
    uint16 leftPts;
    uint16 rightPts;
    uint8 confirmations;
    uint8 notMatch;
    mapping (address => bool) confirmAddrs;
  }

  ERC20 token;
  mapping (bytes32 => DataItem) public dataCenter;

  event SaveResult(bytes32 indexed gameId, uint16 leftPts, uint16 rightPts, string hash);
  event ModifyResult(bytes32 indexed gameId, uint16 leftPts, uint16 rightPts, string hash);
  event ConfirmResult(address indexed addr, bytes32 indexed gameId);
  event DenyResult(address indexed addr, bytes32 indexed gameId);
  event LogReward(address indexed addr, bytes32 indexed gameId, uint value);

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
    require(dataCenter[gameId].confirmations < MAX_CONFIRMATIONS);
    _;
  }

  function () public payable {}
  function DataCenter(address tokenAddr) public {
    token = ERC20(tokenAddr);
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
    dataCenter[gameId].confirmAddrs[msg.sender] = true;
    SaveResult(gameId, leftPts, rightPts, hash);
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
  function confirmResult(bytes32 gameId, uint16 leftPts, uint16 rightPts) gameExist(gameId) confirmationNotEnough(gameId) public {
    require(!contains(gameId, msg.sender));
    require(dataCenter[gameId].notMatch < MAX_CONFIRMATIONS);
    dataCenter[gameId].confirmAddrs[msg.sender] = true;
    if (dataCenter[gameId].leftPts == leftPts && dataCenter[gameId].rightPts == rightPts) {
      dataCenter[gameId].confirmations += 1;
      ConfirmResult(msg.sender, gameId);
    } else {
      dataCenter[gameId].notMatch += 1;
      DenyResult(msg.sender, gameId);
    }
    require(rewardERC20());
    LogReward(msg.sender, gameId, CONFIRM_RESULT_BONUS);
  }

  /**
   * @dev allow owner to modify data
   * @param gameId indicate the unique id of game
   * @param leftPts the score or points of left team gained(In football left team means home team, in NBA left team means away team)
   * @param rightPts the score or points of right team gained(In football right team means away team, in NBA left team means home team)
   * @param hash indicate the IPFS hash of this game s detail data
   */
  function modifyResult(bytes32 gameId, uint16 leftPts, uint16 rightPts, string hash) onlyOwner gameExist(gameId) public {
    require(dataCenter[gameId].notMatch >= MAX_CONFIRMATIONS);
    dataCenter[gameId].detailDataHash = hash;
    dataCenter[gameId].leftPts = leftPts;
    dataCenter[gameId].rightPts = rightPts;
    dataCenter[gameId].confirmations = 1;
    dataCenter[gameId].confirmAddrs[msg.sender] = true;
    dataCenter[gameId].notMatch = 0;
    ModifyResult(gameId, leftPts, rightPts, hash);
  }
 
  /**
   * @dev to check the given address is in the GameItem confirmList
   * @param gameId indicate the unique id of game
   * @param addr indicate the address to check
   */
  function contains(bytes32 gameId, address addr) view public returns (bool) {
    return dataCenter[gameId].confirmAddrs[addr];
  }

  /**
   * @dev distribute reward to participants of auditing game result
   */
  function rewardERC20() internal returns (bool) {
    require(token.balanceOf(address(this)) >= CONFIRM_RESULT_BONUS);
    return token.transfer(msg.sender, CONFIRM_RESULT_BONUS);
  }
}
