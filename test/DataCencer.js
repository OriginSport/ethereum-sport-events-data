const { assertRevert } = require('truffle-js-test-helper')

const DataCenter = artifacts.require('./DataCenter.sol')
const web3 = require('web3')
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

  let dataCenter
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
    const item = await dataCenter.dataCenter(getBytes(gameId))
    assert.equal(getStr(item[0]), gameId)
    assert.equal(getStr(item[1]), result)
    assert.equal(item[2], hash)
    assert.equal(item[3].toNumber(), 0)
  })

  it('can not save result again', async () => {
    await assertRevert(dataCenter.saveResult(...params))
  })

  it('test query a not exist game', async () => {
    const notExistId = getBytes('not exist game id')
    const item = await dataCenter.dataCenter(getBytes(notExistId))
    assert.equal(getStr(item[0]), '')
    assert.equal(getStr(item[1]), '')
    assert.equal(item[2], '')
    assert.equal(item[3].toNumber(), 0)
  })

  it('test user1 to confirm a game result', async () => {
    await dataCenter.confirmResult(getBytes(gameId), getBytes(result))
    const item = await dataCenter.dataCenter(getBytes(gameId))
    assert.equal(item[3].toNumber(), 1)
  })

  it('test user2 to confirm a game result', async () => {
    await dataCenter.confirmResult(getBytes(gameId), getBytes('Wrong Result'))
    const item = await dataCenter.dataCenter(getBytes(gameId))
    assert.equal(item[3].toNumber(), 1)
  })

  it('test user3 to confirm a game result', async () => {
    await dataCenter.confirmResult(getBytes(gameId), getBytes(result))
    const item = await dataCenter.dataCenter(getBytes(gameId))
    assert.equal(item[3].toNumber(), 2)
  })
})
