var InsecureAndMessy = artifacts.require("./InsecureAndMessy.sol");

module.exports = function(deployer) {
  deployer.deploy(InsecureAndMessy);
};
