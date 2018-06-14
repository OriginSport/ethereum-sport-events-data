const DataCenter = artifacts.require('DataCenter.sol')
const AddressResolver = artifacts.require('AddressResolver.sol')

const testTokenAddr = '0xeb9a4b185816c354db92db09cc3b50be60b901b6'
const mainTokenAddr = '0x0a22dccf5bd0faa7e748581693e715afefb2f679'

const ropstenAddressResolerAddress = '0x282b192518fc09568de0E66Df8e2533f88C16672'
const mainnetAddressResolerAddress = '0x6690e2698bfa407db697e69a11ea56810454549b'

module.exports = function(deployer) {
  deployer.deploy(DataCenter, mainTokenAddr)
  //deployer.deploy(AddressResolver)
}
