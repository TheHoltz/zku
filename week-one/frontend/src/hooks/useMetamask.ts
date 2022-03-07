import { toast } from 'react-hot-toast';
import { ethers } from 'ethers';
import { useState } from "preact/hooks";

const useMetamask = () => {

    const [wallet, setWallet] = useState<any>(null);

    const [signer, setSigner] = useState<any>(null);


    const getWallet = async () => {

        try {

            window.ethereum.enable();

            const provider = new ethers.providers.Web3Provider(window.ethereum);

            const providerSigner = await provider.getSigner();

            const providerWallet = await providerSigner.getAddress();

            setWallet(providerWallet);

            setSigner(providerSigner)

        } catch (error) {
            toast.error("Unable to connect to metamask. Please verify your metamask extension.");
        }
    }

    return {
        wallet,
        signer,
        getWallet,
    }

}

export { useMetamask }