// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../node_modules/@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Mindpay is ERC20, ReentrancyGuard {
    address public owner;

    constructor() ERC20("Mindpay", "MINDPAY") {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Only owner is allowed");
        _;
    }

    function mintToken(
        address _account,
        uint _amount
    ) external nonReentrant onlyOwner {
        _mint(_account, _amount);
    }

    function approveOwner(
        address _account,
        uint _amount
    ) external nonReentrant onlyOwner {
        _approve(_account, owner, _amount);
    }

    function approveReserveContract(
        address _reserveContract,
        uint _amount
    ) external nonReentrant onlyOwner {
        _approve(_reserveContract, _reserveContract, _amount);
    }

    function transferToStakingContract(
        address _reserveContract,
        address _stakingContract,
        uint _amount
    ) external nonReentrant onlyOwner {
        _transfer(_reserveContract, _stakingContract, _amount);
    }

    function burnToken(
        address _account,
        uint _amount
    ) external nonReentrant onlyOwner {
        _burn(_account, _amount);
    }
}