// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

import "../node_modules/@openzeppelin/contracts/utils/Address.sol";
import "../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../node_modules/@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./Mindpay.sol";
import "./Liquidity.sol";
import "./Reserve.sol";
import "./Staking.sol";

contract Investment is ReentrancyGuard {
    using SafeMath for uint;

    address public mindpayContractAddress;
    address public liquidityContractAddress;
    address payable public reserveContractAddress;
    address public stakingContractAddress;

    uint public totalMindapayTokenAmount;

    struct UserData {
        address payable userAddress;
        uint investedAmount;
        uint reserveAmount;
        uint liquidityAmount;
        uint totalTokenAmount;
        uint currentTokenAmount;
        uint investmenstStartingTime;
        uint investmenstEndingTime;
        bool usersDataExists;
    }

    mapping(address => UserData) private usersData;

    modifier onlyNonContract() {
        require(
            (
                !Address.isContract(msg.sender)
            ) && (
                tx.origin == msg.sender
            ),
            "Attack from an unknown external contract"
        );
        _;
    }

    constructor() {
        Mindpay mindpayContract = new Mindpay();
        mindpayContractAddress = address(mindpayContract);

        Liquidity liquidityContract = new Liquidity();
        liquidityContractAddress = address(liquidityContract);

        Reserve reserveContract = new Reserve();
        reserveContractAddress = payable(address(reserveContract));

        Staking stakingContract = new Staking();
        stakingContractAddress = address(stakingContract);

        totalMindapayTokenAmount = 0;
    }

    function investAmount() public payable nonReentrant onlyNonContract {
        require(msg.value > 0, "Amount must be above 0");

        uint investedAmount = msg.value;
        uint tokenAmount = investedAmount.mul(1000);
        uint bonusTokenAmount = 0;

        if (investedAmount > 1 ether && investedAmount < 5 ether) {
            bonusTokenAmount = bonusTokenAmount.add(tokenAmount.mul(10).div(100));
        } else if (investedAmount > 5 ether) {
            bonusTokenAmount = bonusTokenAmount.add(tokenAmount.mul(20).div(100));
        }

        uint totalTokenAmount = tokenAmount.add(bonusTokenAmount);
        uint reserveContractAmount = investedAmount.mul(90).div(100);
        uint liquidityContractAmount = investedAmount.mul(10).div(100);

        if (usersData[msg.sender].usersDataExists) {
            require(
                (
                    (
                        usersData[msg.sender].investmenstStartingTime == 0
                    ) && (
                        usersData[msg.sender].investmenstEndingTime == 0
                    )
                ) || (
                    (
                        usersData[msg.sender].investmenstStartingTime < block.timestamp
                    ) && (
                        usersData[msg.sender].investmenstEndingTime < block.timestamp
                    )
                ),
                "Your investment amount and the tokens are still locked in the contract. Please try after sometime"
            );

            uint userInvestedAmount = usersData[msg.sender].investedAmount;
            uint userReservedAmount = usersData[msg.sender].reserveAmount;
            uint userLiquidityAmount = usersData[msg.sender].liquidityAmount;
            uint userTokenAmount = usersData[msg.sender].totalTokenAmount;
            uint userCurrentTokenAmount = usersData[msg.sender].currentTokenAmount;

            usersData[msg.sender].investedAmount = userInvestedAmount.add(
                investedAmount
            );
            usersData[msg.sender].reserveAmount = userReservedAmount.add(
                reserveContractAmount
            );
            usersData[msg.sender].liquidityAmount = userLiquidityAmount.add(
                liquidityContractAmount
            );
            usersData[msg.sender].totalTokenAmount = userTokenAmount.add(
                totalTokenAmount
            );
            usersData[msg.sender].currentTokenAmount = userCurrentTokenAmount.add(
                totalTokenAmount
            );
            usersData[msg.sender].investmenstStartingTime = block.timestamp;
            usersData[msg.sender].investmenstEndingTime = block.timestamp + 15 minutes;
        } else {
            usersData[msg.sender] = UserData({
                userAddress: payable(msg.sender),
                investedAmount: investedAmount,
                reserveAmount: reserveContractAmount,
                liquidityAmount: liquidityContractAmount,
                totalTokenAmount: totalTokenAmount,
                currentTokenAmount: totalTokenAmount,
                investmenstStartingTime: block.timestamp,
                investmenstEndingTime: block.timestamp + 15 minutes,
                usersDataExists: true
            });
        }

        totalMindapayTokenAmount = totalMindapayTokenAmount.add(totalTokenAmount);

        payable(reserveContractAddress).transfer(reserveContractAmount);

        payable(liquidityContractAddress).transfer(liquidityContractAmount);

        Mindpay(mindpayContractAddress).mintToken(
            msg.sender,
            totalTokenAmount
        );

        Mindpay(mindpayContractAddress).approveOwner(
            msg.sender,
            totalTokenAmount
        );

        IERC20(mindpayContractAddress).transferFrom(
            msg.sender,
            reserveContractAddress,
            totalTokenAmount
        );
    }

    function cancelInvestment() public nonReentrant onlyNonContract {
        require(
            usersData[msg.sender].usersDataExists == true,
            "This user haven't invested."
        );

        require(
            usersData[msg.sender].investedAmount > 0,
            "This user already cancelled/staked the investment."
        );

        require(
            (
                usersData[msg.sender].investmenstStartingTime != 0
            ) && (
                usersData[msg.sender].investmenstEndingTime >= 0
            ),
            "Your investment amount and the tokens are currently locked in the contract. Please try after sometime"
        );
        
        uint reserveAmount = usersData[msg.sender].reserveAmount;
        uint totalTokenAmount = usersData[msg.sender].totalTokenAmount;
        uint currentTokenAmount = usersData[msg.sender].currentTokenAmount;

        usersData[msg.sender].investedAmount = 0;
        usersData[msg.sender].reserveAmount = 0;
        usersData[msg.sender].totalTokenAmount = totalTokenAmount.sub(
            currentTokenAmount
        );
        usersData[msg.sender].currentTokenAmount = 0;
        usersData[msg.sender].investmenstStartingTime = 0;
        usersData[msg.sender].investmenstEndingTime = 0;

        totalMindapayTokenAmount = totalMindapayTokenAmount.sub(currentTokenAmount);

        Reserve(reserveContractAddress).returnInvestment(
            msg.sender,
            reserveAmount
        );

        Mindpay(mindpayContractAddress).burnToken(
            reserveContractAddress,
            currentTokenAmount
        );
    }

    function stakeInvestment() public nonReentrant onlyNonContract {
        require(
            usersData[msg.sender].usersDataExists == true,
            "This user haven't invested."
        );

        require(
            usersData[msg.sender].investedAmount > 0,
            "This user already cancelled/staked the investment."
        );

        require(
            (
                usersData[msg.sender].investmenstStartingTime != 0
            ) && (
                usersData[msg.sender].investmenstEndingTime >= 0
            ),
            "Your investment amount and the tokens are currently locked in the contract. Please try after sometime"
        );
        
        uint reserveAmount = usersData[msg.sender].reserveAmount;
        uint liquidityAmount = usersData[msg.sender].liquidityAmount;
        uint currentTokenAmount = usersData[msg.sender].currentTokenAmount;

        usersData[msg.sender].investedAmount = 0;
        usersData[msg.sender].reserveAmount = 0;
        usersData[msg.sender].liquidityAmount = liquidityAmount.add(reserveAmount);
        usersData[msg.sender].currentTokenAmount = 0;
        usersData[msg.sender].investmenstStartingTime = 0;
        usersData[msg.sender].investmenstEndingTime = 0;

        Reserve(reserveContractAddress).transferToLiquidity(
            liquidityContractAddress,
            reserveAmount
        );

        Mindpay(mindpayContractAddress).approveReserveContract(
            reserveContractAddress,
            currentTokenAmount
        );

        Mindpay(mindpayContractAddress).transferToStakingContract(
            reserveContractAddress,
            stakingContractAddress,
            currentTokenAmount
        );
    }

    function getReserveContractBalance() public view returns(uint) {
        return address(reserveContractAddress).balance;
    }

    function getLiquidityContractBalance() public view returns(uint) {
        return address(liquidityContractAddress).balance;
    }

    function getUserData() public view returns(UserData memory) {
        require(
            usersData[msg.sender].usersDataExists == true,
            "User data does not exists."
        );
        return usersData[msg.sender];
    }

    function getInvestmentEndingTime() public view returns(uint) {
        return usersData[msg.sender].usersDataExists == true ?
            usersData[msg.sender].investmenstEndingTime:
            0;
    }

    function getUserMindpayTokenBalance() public view returns(uint) {
        return usersData[msg.sender].usersDataExists == true ?
            usersData[msg.sender].totalTokenAmount:
            0;
    }

    function getTotalMindpayTokenSupply() public view returns(uint) {
        return totalMindapayTokenAmount;
    }

    function getCurrentTime() public view returns(uint) {
        return block.timestamp;
    }
}