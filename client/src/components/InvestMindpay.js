import React from "react";

const InvestMindpay = (props) => {
  const { web3, accounts, contract } = props;

  const investHandler = async (event) => {
    event.preventDefault();
    // console.log(typeof props.amount);
    try {
      const txn = await contract.methods.investAmount().send({
        from: accounts[0],
        value: web3.utils.toWei(props.amount, "ether"),
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
      <button onClick={investHandler}>Invest in MINDPAY</button>
      <p>Total Supply of MINDPAY {props.totalTokenMinted}</p>
    </div>
  );
};

export default InvestMindpay;
