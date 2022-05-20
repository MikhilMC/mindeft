import React from "react";

const DecideInvestment = (props) => {
  const { accounts, contract } = props;

  const cancelInvestmentHandler = async (event) => {
    event.preventDefault();

    try {
      const txn = await contract.methods.cancelInvestment().send({
        from: accounts[0],
      });

      console.log(txn);

      props.onTokenPurchase();
      props.onTotalTokenAmountChange();
      props.onAmountSetDefault();
    } catch (error) {
      console.log(error);
    }
  };
  const stakeInvestmentHandler = async (event) => {
    event.preventDefault();

    try {
      const txn = await contract.methods.stakeInvestment().send({
        from: accounts[0],
      });

      console.log(txn);

      props.onTokenPurchase();
      props.onTotalTokenAmountChange();
      props.onAmountSetDefault();
    } catch (error) {
      console.log(error);
    }
  };
  return (
    <div>
      <p>Total MINDPAY balance of user {props.tokenBalance}</p>
      <button onClick={cancelInvestmentHandler}>Cancel Investment</button>
      <button onClick={stakeInvestmentHandler}>Stake Your Investment</button>
    </div>
  );
};

export default DecideInvestment;
