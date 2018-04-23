var DataCenter = artifacts.require('./DataCenter.sol')
var web3 = require('web3')
// return web3.utils.fromAscii(str)
// return web3.utils.hexToAscii(bytes32)

function getStr(hexStr) {
  return web3.utils.hexToAscii(hexStr).replace(/\u0000/g, '')
}
function getBytes(str) {
  return web3.utils.fromAscii(str)
}

contract('DataCenter', accounts => {
  // account[0] points to the owner on the testRPC setup
  var owner = accounts[0]
  var user1 = accounts[1]
  var user2 = accounts[2]
  var user3 = accounts[3]
  var user4 = accounts[4]

  let bet
  let dataCenter
  let totalBetAmount = 0
  let players = []
  const gameId = '0012345678'
  const result = '115-109'
  const hash = 'QmY7kQ3GjZzAW6v622qUe9QoMpJECQa63UkV958kHbuViR'
  const params = [getBytes(gameId), getBytes(result), hash]

  before(() => {
    return DataCenter.deployed({from: owner})
    .then(instance => {
      dataCenter = instance
    })
  })

  it('should return a data item', async () => {
    await dataCenter.saveResult(...params)
    const _result = await dataCenter.getResult(getBytes(gameId))
    const _hash = await dataCenter.getDetailDataHash(getBytes(gameId))
    assert.equal(getStr(_result), result)
    assert.equal(_hash, hash)
  })

  it('test query a not exist game', async () => {
    const notExistId = getBytes('not exist game id')
    const _result = await dataCenter.getResult(notExistId)
    const _hash = await dataCenter.getDetailDataHash(notExistId)
    const nullStr = ''
    assert.equal(getStr(_result), nullStr)
    assert.equal(_hash, nullStr)
  })
})
