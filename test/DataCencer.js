const { assertRevert } = require('truffle-js-test-helper')
const w3 = require('web3')
const DataCenter = artifacts.require('./DataCenter.sol')

function getStr(hexStr) {
  return w3.utils.hexToAscii(hexStr).replace(/\u0000/g, '')
}
function getBytes(str) {
  return w3.utils.fromAscii(str)
}

contract('DataCenter', accounts => {
  // account[0] points to the owner on the testRPC setup
  var owner = accounts[0]
  var user1 = accounts[1]
  var user2 = accounts[2]
  var user3 = accounts[3]
  var user4 = accounts[4]
  var user5 = accounts[5]
  var user6 = accounts[6]
  var user7 = accounts[7]
  var user8 = accounts[8]
  var user9 = accounts[9]

  let dataCenter
  const gameId = '0012345678'
  const leftPts = 115
  const rightPts = 109
  const hash = 'QmY7kQ3GjZzAW6v622qUe9QoMpJECQa63UkV958kHbuViR'
  const params = [getBytes(gameId), leftPts, rightPts, hash]

  const testTokenAddr = '0xeb9a4b185816c354db92db09cc3b50be60b901b6'

  before(() => {
    return DataCenter.deployed(testTokenAddr, {from: owner})
    .then(instance => {
      dataCenter = instance
    })
  })

  it('should return a data item', async () => {
    const addr = dataCenter.address
    web3.eth.sendTransaction({from: owner, to: addr, value: web3.toWei(90, "ether")}, function(err, data) {
      console.log(err, data)
    })
     
    await dataCenter.saveResult(...params)
    const item = await dataCenter.dataCenter(getBytes(gameId))
    assert.equal(getStr(item[0]), gameId)
    assert.equal(item[1], hash)
    assert.equal(item[2], leftPts)
    assert.equal(item[3], rightPts)
    assert.equal(item[4].toNumber(), 1)
  })

  it('should return a game result using gameId', async () => {
    const item = await dataCenter.getResult(getBytes(gameId))
    assert.equal(item[0], leftPts)
    assert.equal(item[1], rightPts)
    assert.equal(item[2], 1)
  })

  it('can not save result again', async () => {
    await assertRevert(dataCenter.saveResult(...params))
  })

  it('test query a not exist game', async () => {
    const notExistId = getBytes('not exist game id')
    const item = await dataCenter.dataCenter(getBytes(notExistId))
    assert.equal(getStr(item[0]), '')
    assert.equal(item[1], '')
    assert.equal(item[2], 0)
    assert.equal(item[3], 0)
    assert.equal(item[4].toNumber(), 0)
  })

  it('test contains function', async () => {
    const isContained = await dataCenter.contains(getBytes(gameId), owner)
    assert.equal(isContained, true, 'owner save result, should be contained')
    const isContained2 = await dataCenter.contains(getBytes(gameId), user4)
    assert.equal(isContained2, false, 'new addr should not be containeed')
  })

  it('test confirm a not exist game', async () => {
    const notExistId = getBytes('not exist game id')
    await assertRevert(dataCenter.confirmResult(getBytes(notExistId), leftPts, rightPts))
  })

  it('test user1 to confirm a game result', async () => {
    const options = { from: user1 }
    await dataCenter.confirmResult(getBytes(gameId), leftPts, rightPts, options)
    const item = await dataCenter.dataCenter(getBytes(gameId))
    assert.equal(item[4].toNumber(), 2)
  })

  it('test user2 to confirm a game result', async () => {
    const options = { from: user2 }
    await dataCenter.confirmResult(getBytes(gameId), leftPts, rightPts, options)
 
    const item = await dataCenter.dataCenter(getBytes(gameId))
    assert.equal(item[4].toNumber(), 3)
  })

  it('test user2 to confirm a game result again', async () => {
    const options = { from: user2 }
    await assertRevert(dataCenter.confirmResult(getBytes(gameId), leftPts, rightPts, options))
  })

  it('test modify data should not be succeed', async () => {
    await assertRevert(dataCenter.modifyResult(...params))
  })
   
  it('test user deny the result', async () => {
    await dataCenter.confirmResult(getBytes(gameId), leftPts + 1, rightPts, { from: user3 })
    await dataCenter.confirmResult(getBytes(gameId), leftPts + 1, rightPts, { from: user4 })
    await dataCenter.confirmResult(getBytes(gameId), leftPts + 1, rightPts, { from: user5 })
    await dataCenter.confirmResult(getBytes(gameId), leftPts + 1, rightPts, { from: user6 })
    await dataCenter.confirmResult(getBytes(gameId), leftPts + 1, rightPts, { from: user7 })
    await dataCenter.confirmResult(getBytes(gameId), leftPts + 1, rightPts, { from: user8 })

    const item = await dataCenter.dataCenter(getBytes(gameId))
    assert.equal(item[5].toNumber(), 6)
  })

  it('test user9 to deny result when [notMatch] is greater than MAX', async () => {
    const options = { from: user9 }
    await assertRevert(dataCenter.confirmResult(getBytes(gameId), leftPts + 1, rightPts, options))
  })

  it('test modify data', async () => {
    params[1] = params[1] + 1
    await dataCenter.modifyResult(...params)
    const item = await dataCenter.dataCenter(getBytes(gameId))
    assert.equal(getStr(item[0]), gameId)
    assert.equal(item[1], hash)
    assert.equal(item[2], leftPts + 1)
    assert.equal(item[3], rightPts)
    assert.equal(item[4].toNumber(), 1)
    assert.equal(item[5].toNumber(), 0)
  })
})
