import React from "react";
import { useAccount, useContractWrite } from "wagmi";
import { ABI, ContractAddress } from "../config";
import { useState } from "react";
import { parseEther } from "viem";
var bigInt = require("big-integer");

const Hero = () => {
  const [tokenAmount, setTokenAmount] = useState("");
  const [walletAddress, setWalletAddress] = useState("");

  const { address, isConnected } = useAccount();
  const { write } = useContractWrite({
    address: ContractAddress,
    abi: ABI,
    functionName: "sell",
    chainId: 80001,
    onError(error) {
      if (error.toString().includes("Caller is not owner")) {
        alert("Caller is not owner");
      } else if (error.toString().includes("Sale not started yet")) {
        alert("Sale not started yet");
      } else if (error.toString().includes("Sale time ended")) {
        alert("Sale time ended");
      } else if (error.toString().includes("Insufficient token to buy")) {
        alert("Insufficient token to buy");
      } else if (error.toString().includes("Zero token amount not allowed")) {
        alert("Zero token amount not allowed");
      } else {
        console.log(error);
        alert(error);
      }
    },
  });

  const sellToken = () => {
    var tokens = parseEther(tokenAmount);
    console.log("token parse ETH : ", tokens);

    tokens = tokens.toString();
    console.log("token parse ETH to number  : ", tokens);
    if (isConnected) {
      write({
        args: ["100", "0xEc1fE2053F50C6a4fb9012fE9dCBFF10008Ca331"],
        from: address,
      });
    } else {
      alert("Please connect to Wallet");
    }
  };

  return (
    <>
      <div className="HeroBg bg-cover bg-vulcan bg-no-repeat bg-center mt-[-105px] md:mt-[-131px] px-3 pt-40  lg:block xl:px-0 bg-gradient-to-r from-gray-900 to-gray-800 h-screen">
        <div className="max-w-7xl mx-auto  gap-y-10  md:gap-y-0 xl:gap-x-20 flex justify-center items-center flex-col">
          <div className="grid items-center">
            <h1 className="font-bold text-white text-2xl md:text-3xl lg:text-4xl xl:text-6xl uppercase">
              Maa <span className=" text-fuchsia-600">Laxmi</span>
            </h1>
          </div>
          <br />
          <br />
          <br />

          <div className="border border-neutral-500 rounded-xl py-8 bg-black bg-opacity-30 h-max md:w-[600px] max-w-xl">
            <div className="bg-transparent text-center px-4 py-2 sm:pt-3 sm:px-18"></div>
            <div className="overflow-hidden rounded-b-xl text-white bg-transparent shadow">
              <div className="px-4 pb-4 bg-transparent bg-opacity-70  lg:px-6 3xl:px-10 ">
                <div className="flex flex-col md:flex-row justify-around px-8 text-fuchsia-600 font-bold text-sm mt-3 md:mt-0">
                  <div className="text-2xl">Buy Token without BNB</div>
                </div>
                <br />

                <div className="px-2 bg-transparent lg:px-2">
                  <div className="p-2 sm:p-0 flex flex-col items-center mb-2 lg:mb-5"></div>

                  <br />

                  <div className="flex justify-between flex-col md:flex-row">
                    <div className=" flex justify-between items-center  block w-full rounded-md border-0 py-2.5 sm:py-1.5 pl-4 pr-10 text-white  bg-gradient-to-r from-gray-900 to-gray-800  shadow-sm ring-1 ring-inset ring-blue-700 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-blue-800 sm:text-base font-medium sm:leading-10">
                      <input
                        onChange={(e) => {
                          setTokenAmount(e.target.value);
                        }}
                        type="number"
                        name="token"
                        id="token"
                        placeholder="Amount of tokens"
                        value={tokenAmount}
                        className="block w-full text-white placeholder:text-gray-400  sm:text-base font-medium sm:leading-10 bg-transparent outline-none"
                      />
                    </div>
                  </div>

                  <br />

                  <div className="flex justify-between flex-col md:flex-row">
                    <div className=" flex justify-between items-center  block w-full rounded-md border-0 py-2.5 sm:py-1.5 pl-4 pr-10 text-white  bg-gradient-to-r from-gray-900 to-gray-800  shadow-sm ring-1 ring-inset ring-blue-700 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-blue-800 sm:text-base font-medium sm:leading-10">
                      <input
                        onChange={(e) => {
                          setWalletAddress(e.target.value);
                        }}
                        type="text"
                        name="token"
                        id="token"
                        placeholder="Wallet address"
                        className="  block w-full text-white placeholder:text-gray-400  sm:text-base font-medium sm:leading-10 bg-transparent outline-none "
                      />
                    </div>
                  </div>

                  <br />

                  <button
                    onClick={sellToken}
                    className="sm:mt-2 mb-2 w-full inline-flex items-center justify-center whitespace-nowrap border-0 rounded-md px-5 py-2 sm:px-5 sm:py-5 3xl:py-4 4xl:py-5 text-sm sm:text-md  font-semibold text-white leading-5 shadow-sm  bg-gradient-to-r from-sky-600 to-fuchsia-600 hover:bg-blue-900"
                  >
                    Buy
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </>
  );
};
export default Hero;
