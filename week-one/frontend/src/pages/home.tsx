import { ethers } from "ethers";
import toast, { Toaster } from "react-hot-toast";
import { simplifyAddress } from "../helpers/simplifyAddress";
import { useMetamask } from "../hooks/useMetamask";
import abi from "../abi/ZkuToken.abi.json";
import { useEffect, useState } from "preact/hooks";

export function App() {
  const RINKEBY_CHAIN = "0x4";

  const { wallet, getWallet, signer } = useMetamask();

  const [allowMint, setAllowMint] = useState(false);

  const handleClick = () => {
    if (wallet && allowMint) {
      return callContract();
    }

    getWallet();
  };

  useEffect(() => {

    if (window.ethereum.chainId !== RINKEBY_CHAIN) {
      toast("Please switch to Rinkeby network.");
      return;
    }

    setAllowMint(true);
  }, [wallet]);

  const callContract = async () => {
    if (window.ethereum.chainId !== RINKEBY_CHAIN) {
      return toast("Please switch to Rinkeby network.");
    }

    let provider = ethers.getDefaultProvider();

    // The address from the deployed contract
    const contractAddress = "0x6Ef5C0683b5cbf8976D52d1C9Df9684FB3832183";

    // We connect to the Contract using a Provider, so we will only
    // have read-only access to the Contract
    const contract = new ethers.Contract(contractAddress, abi, provider);

    const unsignedTx = await contract.populateTransaction.mint();

    try {

      await signer.sendTransaction(unsignedTx);

      return toast("Token Minted!");

    } catch (e: any) {
      toast(e.message);
    }

  };

  return (
    <div key={`home-${allowMint}`}>
      <Toaster
        position="bottom-center"
        toastOptions={{
          // Define default options
          duration: 5000,
          style: {
            background: "#363636",
            color: "#fff",
          },
          success: {
            duration: 8000,
            theme: {
              primary: "green",
              secondary: "black",
            },
          },
          error: {
            duration: 10000,
            theme: {
              primary: "red",
              secondary: "black",
            },
          },
          loading: {
            duration: 20000,
          },
        }}
      />

      <img src="/assets/ZToken.png" width="100" class="ztoken" />

      <h1>ZkuToken</h1>
      {wallet ? (
        <h2>Your wallet address: {simplifyAddress(wallet)}</h2>
      ) : (
        <h2>Connect your wallet to proceed</h2>
      )}

      <div class="cta">
        <button class="link" onClick={handleClick}>
          {wallet && allowMint ? "🚀 Grab my token" : "Connect wallet"}
        </button>
      </div>
    </div>
  );
}
