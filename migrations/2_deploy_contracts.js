const DataCenter = artifacts.require('DataCenter.sol')

const testTokenAddr = '0xeb9a4b185816c354db92db09cc3b50be60b901b6'
const mainTokenAddr = '0x0a22dccf5bd0faa7e748581693e715afefb2f679'

module.exports = function(deployer) {
  deployer.deploy(DataCenter, testTokenAddr)
}
