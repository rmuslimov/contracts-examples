var SecureAndClean = artifacts.require("./SecureAndClean.sol");
var InsecureAndMessy = artifacts.require("./InsecureAndMessy.sol");
var Attacker = artifacts.require('./Attacker.sol');

module.exports = function(deployer) {
  deployer.deploy(SecureAndClean);
  deployer.deploy(InsecureAndMessy).then(
    () => deployer.deploy(Attacker, InsecureAndMessy.address)
  );
};
