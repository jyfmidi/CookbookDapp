const Cookbook = artifacts.require("Cookbook");

module.exports = function(deployer) {
  deployer.deploy(Cookbook);
};