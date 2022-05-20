var Investment = artifacts.require("./Investment.sol");

module.exports = function (deployer) {
  deployer.deploy(Investment);
};
