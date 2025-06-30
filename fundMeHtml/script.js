// ✅ use this in a module-based project
import { ethers } from "https://cdn.jsdelivr.net/npm/ethers@5.7.2/dist/ethers.esm.min.js";

const abi = [{
    "type": "constructor",
    "inputs": [
        {
            "name": "initialOwner",
            "type": "address",
            "internalType": "address"
        },
        {
            "name": "priceFeed",
            "type": "address",
            "internalType": "address"
        }
    ],
    "stateMutability": "nonpayable"
},
{
    "type": "fallback",
    "stateMutability": "payable"
},
{
    "type": "receive",
    "stateMutability": "payable"
},
{
    "type": "function",
    "name": "MINUSD",
    "inputs": [],
    "outputs": [
        {
            "name": "",
            "type": "uint256",
            "internalType": "uint256"
        }
    ],
    "stateMutability": "view"
},
{
    "type": "function",
    "name": "balanceOfContract",
    "inputs": [],
    "outputs": [
        {
            "name": "",
            "type": "uint256",
            "internalType": "uint256"
        }
    ],
    "stateMutability": "view"
},
{
    "type": "function",
    "name": "fund",
    "inputs": [],
    "outputs": [],
    "stateMutability": "payable"
},
{
    "type": "function",
    "name": "funders",
    "inputs": [
        {
            "name": "",
            "type": "uint256",
            "internalType": "uint256"
        }
    ],
    "outputs": [
        {
            "name": "",
            "type": "address",
            "internalType": "address"
        }
    ],
    "stateMutability": "view"
},
{
    "type": "function",
    "name": "fundersAndMoney",
    "inputs": [
        {
            "name": "",
            "type": "address",
            "internalType": "address"
        }
    ],
    "outputs": [
        {
            "name": "",
            "type": "uint256",
            "internalType": "uint256"
        }
    ],
    "stateMutability": "view"
},
{
    "type": "function",
    "name": "getFunder",
    "inputs": [
        {
            "name": "_index",
            "type": "uint256",
            "internalType": "uint256"
        }
    ],
    "outputs": [
        {
            "name": "",
            "type": "address",
            "internalType": "address"
        }
    ],
    "stateMutability": "view"
},
{
    "type": "function",
    "name": "getMinimumDeposit",
    "inputs": [],
    "outputs": [
        {
            "name": "",
            "type": "uint256",
            "internalType": "uint256"
        }
    ],
    "stateMutability": "view"
},
{
    "type": "function",
    "name": "getPriceFundMe",
    "inputs": [],
    "outputs": [
        {
            "name": "",
            "type": "uint256",
            "internalType": "uint256"
        }
    ],
    "stateMutability": "view"
},
{
    "type": "function",
    "name": "getVersion",
    "inputs": [],
    "outputs": [
        {
            "name": "",
            "type": "uint256",
            "internalType": "uint256"
        }
    ],
    "stateMutability": "view"
},
{
    "type": "function",
    "name": "owner",
    "inputs": [],
    "outputs": [
        {
            "name": "",
            "type": "address",
            "internalType": "address"
        }
    ],
    "stateMutability": "view"
},
{
    "type": "function",
    "name": "renounceOwnership",
    "inputs": [],
    "outputs": [],
    "stateMutability": "nonpayable"
},
{
    "type": "function",
    "name": "transferOwnership",
    "inputs": [
        {
            "name": "newOwner",
            "type": "address",
            "internalType": "address"
        }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
},
{
    "type": "function",
    "name": "withdraw",
    "inputs": [],
    "outputs": [],
    "stateMutability": "nonpayable"
},
{
    "type": "event",
    "name": "OwnershipTransferred",
    "inputs": [
        {
            "name": "previousOwner",
            "type": "address",
            "indexed": true,
            "internalType": "address"
        },
        {
            "name": "newOwner",
            "type": "address",
            "indexed": true,
            "internalType": "address"
        }
    ],
    "anonymous": false
},
{
    "type": "error",
    "name": "OwnableInvalidOwner",
    "inputs": [
        {
            "name": "owner",
            "type": "address",
            "internalType": "address"
        }
    ]
},
{
    "type": "error",
    "name": "OwnableUnauthorizedAccount",
    "inputs": [
        {
            "name": "account",
            "type": "address",
            "internalType": "address"
        }
    ]
}];

const contractAddress = "0x1BcdC73D751b1386d3E7bCf2959BB56Ac65F5CcF"; // Replace with your contract address

let provider;
let signer;
let contract;
if (window.ethereum) {
    window.ethereum.on("accountsChanged", () => {
        // Reconnect with the new account
        connect();
    });
}
window.addEventListener("DOMContentLoaded", () => {
    const connectButton = document.getElementById("connectBtn");
    connectButton.onclick = connect;

    const minDepButton = document.getElementById("minDep");
    minDepButton.onclick = getMinimumDeposit;

    document.getElementById("fundBtn").onclick = fund;
    document.getElementById("balanceBtn").onclick = getBalance;
    document.getElementById("withdrawBtn").onclick = withdraw;
    document.getElementById("priceBtn").onclick = getPrice;


    console.log(2);
});
async function connect() {
    console.log("Connect");
    if (typeof window.ethereum !== "undefined") {
        provider = new ethers.providers.Web3Provider(window.ethereum);
        await provider.send("eth_requestAccounts", []);
        signer = provider.getSigner();
        contract = new ethers.Contract(contractAddress, abi, signer);

        const userAddress = await signer.getAddress();
        document.getElementById("status").innerText = `Connected: ${userAddress}`;
    } else {
        alert("Please install MetaMask");
    }
}

async function fund() {
    const ethAmount = document.getElementById("ethAmount").value;
    try {
        const tx = await contract.fund({
            value: ethers.utils.parseEther(ethAmount)
        });
        await tx.wait();
        alert("Funded successfully!");
    } catch (err) {
        console.error(err);
        alert("Funding failed.");
    }
}

async function getPrice() {
    if (!contract) return alert("Connect wallet first");

    try {
        const rawPrice = await contract.getPriceFundMe(); // BigNumber
        const ethUsd = ethers.utils.formatUnits(rawPrice, 18); // Format with 18 decimals
        document.getElementById("priceInfo").innerText = `ETH/USD Price: $${ethUsd}`;
    } catch (err) {
        console.error("Failed to fetch price", err);
        document.getElementById("priceInfo").innerText = "Error fetching price.";
    }
}

async function getBalance() {
    try {
        const balance = await contract.balanceOfContract();
        document.getElementById("balance").innerText = `Contract Balance: ${ethers.utils.formatEther(balance)} ETH`;
    } catch (err) {
        console.error(err);
        alert("Could not fetch balance.");
    }
}

async function getMinimumDeposit() {
    try {
        const balance = await contract.getMinimumDeposit();
        document.getElementById("minDepInfo").innerText = `Contract Min Deposit: ${ethers.utils.formatEther(balance)} ETH`;
    } catch (err) {
        console.error(err);
        alert("Could not fetch min deposit.");
    }
}

async function withdraw() {
    try {
        const tx = await contract.withdraw();
        await tx.wait();
        document.getElementById("withdrawStatus").innerText = "Withdraw successful.";
    } catch (err) {
        console.error(err);
        document.getElementById("withdrawStatus").innerText = "Withdraw failed.";
    }
}


