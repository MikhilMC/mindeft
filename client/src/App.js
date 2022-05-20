import React, { useState } from "react";
import StartingPage from "./components/StartingPage";
import InvestmentContract from "./contracts/Investment.json";
import getWeb3 from "./getWeb3";

const INITIAL_DETAILS = {
  web3: null,
  accounts: null,
  contract: null,
};

const App = () => {
  const [isConnected, setIsConnected] = useState(false);
  const [web3IntegrationDetails, setWeb3IntegrationDetails] =
    useState(INITIAL_DETAILS);

  // console.log(web3IntegrationDetails);

  const metamaskWalletConnectHandler = async () => {
    try {
      // Get network provider and web3 instance.
      const web3 = await getWeb3();

      // Use web3 to get the user's accounts.
      const accounts = await window.ethereum.request({
        method: "eth_requestAccounts",
      });

      // Get the contract instance.
      const networkId = await web3.eth.net.getId();
      const deployedNetwork = InvestmentContract.networks[networkId];
      const instance = new web3.eth.Contract(
        InvestmentContract.abi,
        deployedNetwork && deployedNetwork.address
      );

      // Set web3, accounts, and contract to the state, and then proceed with an
      // example of interactisetIsConnectedToMetamaskng with the contract's methods.
      setWeb3IntegrationDetails({
        ...web3IntegrationDetails,
        web3,
        accounts,
        contract: instance,
      });

      setIsConnected(true);
    } catch (error) {
      // Catch any errors for any of the above operations.
      alert(
        `Failed to load web3, accounts, or contract. Check console for details.`
      );
      console.error(error);
    }
  };

  return (
    <div>
      {!isConnected && (
        <button
          className="App-metamask-button"
          onClick={metamaskWalletConnectHandler}
        >
          Connect to Metamask
        </button>
      )}
      {isConnected && (
        <StartingPage
          web3={web3IntegrationDetails.web3}
          accounts={web3IntegrationDetails.accounts}
          contract={web3IntegrationDetails.contract}
        />
      )}
    </div>
  );
};

export default App;
