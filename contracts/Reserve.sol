// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

import "../node_modules/@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Reserve is ReentrancyGuard {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Only owner is allowed");
        _;
    }

    fallback() external payable {}

    receive() external payable {}

    function returnInvestment(
        address _account,
        uint _amount
    ) external nonReentrant onlyOwner {
        payable(_account).transfer(_amount);
    }

    function transferToLiquidity(
        address _liquidityContract,
        uint _amount
    ) external nonReentrant onlyOwner {
        payable(_liquidityContract).transfer(_amount);
    }

    function getContractBalance() public view returns(uint256) {
        return address(this).balance;
    }
}