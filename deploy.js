const { ethers } = require("hardhat");

async function main() {
  // Deploy MyDataContract
  const MyDataContract = await ethers.getContractFactory("MyDataContract");
  const myDataContract = await MyDataContract.deploy(
    // Set your Oracle address, Job ID, and fee
    "0xYourOracleAddress",
    ethers.utils.formatBytes32String("YourJobId"),
    ethers.utils.parseEther("0.1") // Fee in LINK (adjust as needed)
  );
  await myDataContract.deployed();
  console.log("MyDataContract deployed to:", myDataContract.address);

  // Deploy ArbitrageOpportunityDetector
  const ArbitrageOpportunityDetector = await ethers.getContractFactory("ArbitrageOpportunityDetector");
  const arbitrageOpportunityDetector = await ArbitrageOpportunityDetector.deploy(
    myDataContract.address // Pass the MyDataContract address to the constructor
  );
  await arbitrageOpportunityDetector.deployed();
  console.log("ArbitrageOpportunityDetector deployed to:", arbitrageOpportunityDetector.address);
}

main();
