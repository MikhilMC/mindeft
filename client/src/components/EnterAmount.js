import React from "react";
import { FaEquals } from "react-icons/fa";

const EnterAmount = (props) => {
  const changeAmountHandler = (event) => {
    props.onAmountChange(event.target.value);
  };
  return (
    <div>
      <input
        type="number"
        onChange={changeAmountHandler}
        placeholder="Enter amount"
        value={props.amount}
      />
      <span>
        {" "}
        <FaEquals /> {props.tokenAmount} MINDPAY tokens
      </span>
    </div>
  );
};

export default EnterAmount;
