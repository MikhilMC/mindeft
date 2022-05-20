import React, { useState, useEffect } from "react";
import DecideInvestment from "./DecideInvestment";
import EnterAmount from "./EnterAmount";
import InvestMindpay from "./InvestMindpay";

const StartingPage = (props) => {
  const [amount, setAmount] = useState("");
  const [tokenAmount, setTokenAmount] = useState("");
  const [tokenBalance, setTokenBalance] = useState(0);
  const [totalTokenMinted, setTotalTokenMinted] = useState(0);

  const { web3, accounts, contract } = props;

  const tokenAmountChangeHandler = async () => {
    let totalTokens;
    try {
      totalTokens = await contract.methods
        .getUserMindpayTokenBalance()
        .call({ from: accounts[0] });
    } catch (error) {
      // console.log(error.message);
      totalTokens = 0;
    }
    setTokenBalance(web3.utils.fromWei(totalTokens.toString()));
  };

  const totalTokenMintedChangHandler = async () => {
    try {
      const totalTokens = await contract.methods
        .getTotalMindpayTokenSupply()
        .call({ from: accounts[0] });

      setTotalTokenMinted(web3.utils.fromWei(totalTokens, "ether"));
    } catch (error) {
      console.log(error);
    }
  };

  const amountSetDefaultHandler = () => {
    setAmount("");
    setTokenAmount("");
  };

  useEffect(() => {
    tokenAmountChangeHandler();
    totalTokenMintedChangHandler();
  });

  const amountChangeHandler = (amountInputValue) => {
    setAmount(amountInputValue);
    setTokenAmount(Number(amountInputValue) * 1000);
  };
  // console.log(props);
  return (
    <div>
      <EnterAmount
        onAmountChange={amountChangeHandler}
        tokenAmount={tokenAmount}
        amount={amount}
      />
      <InvestMindpay
        web3={props.web3}
        accounts={props.accounts}
        contract={props.contract}
        amount={amount}
        totalTokenMinted={totalTokenMinted}
        onTokenPurchase={tokenAmountChangeHandler}
        onTotalTokenAmountChange={totalTokenMintedChangHandler}
        onAmountSetDefault={amountSetDefaultHandler}
      />
      <DecideInvestment
        web3={props.web3}
        accounts={props.accounts}
        contract={props.contract}
        tokenBalance={tokenBalance}
        onTokenPurchase={tokenAmountChangeHandler}
        onTotalTokenAmountChange={totalTokenMintedChangHandler}
        onAmountSetDefault={amountSetDefaultHandler}
      />
    </div>
  );
};

export default StartingPage;
