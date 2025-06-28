import abi from './abi.json' assert { type: 'json' };
const contractAddress = "0x1BcdC73D751b1386d3E7bCf2959BB56Ac65F5CcF";
let provider;
let signer;
let fundMe;

async function connect() {
    if (window.ethereum) {
        provider = new ethers.providers.Web3Provider(window.ethereum);
        await provider.send("eth_requestAccounts", []);
        signer = provider.getSigner();
        fundMe = new ethers.Contract(contractAddress, abi, signer);

        document.getElementById("status").innerText = "Connected!";
    } else {
        alert("Install MetaMask to use this site.");
    }
}

async function fund() {
    const ethAmount = document.getElementById("ethAmount").value;
    const tx = await fundMe.fund({
        value: ethers.utils.parseEther(ethAmount),
    });
    await tx.wait();
    document.getElementById("status").innerText = `Funded ${ethAmount} ETH`;
}

async function withdraw() {
    const tx = await fundMe.withdraw();
    await tx.wait();
    document.getElementById("status").innerText = "Withdrawn (if you’re the owner)";
}

async function getMinimum() {
    if (!fundMe) return alert("Connect wallet first");

    try {
        const rawValue = await fundMe.getMinimumDeposit(); // returns BigNumber in wei
        const ethValue = ethers.utils.formatEther(rawValue); // convert to ETH string

        document.getElementById("minimumResult").innerText =
            `Minimum deposit: ${ethValue} ETH`;
    } catch (err) {
        console.error(err);
        document.getElementById("minimumResult").innerText =
            "Failed to fetch minimum deposit.";
    }
}