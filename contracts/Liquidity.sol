// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

contract Liquidity {
    fallback() external payable {}

    receive() external payable {}

    function getContractBalance() public view returns(uint256) {
        return address(this).balance;
    }
}