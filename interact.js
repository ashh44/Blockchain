const { ethers } = require("hardhat");

async function main() {
  const MyDataContract = await ethers.getContractFactory("MyDataContract");
  const myDataContract = await MyDataContract.attach(/* MyDataContract address */);

  const ArbitrageOpportunityDetector = await ethers.getContractFactory("ArbitrageOpportunityDetector");
  const arbitrageOpportunityDetector = await ArbitrageOpportunityDetector.attach(/* ArbitrageOpportunityDetector address */);

  await myDataContract.switchDataSource(true); // Switch to on-chain data
  const onChainData = await myDataContract.getData();
  console.log("On-chain Data:", onChainData);

  await myDataContract.switchDataSource(false); // Switch to off-chain data
  const offChainData = await myDataContract.getData();
  console.log("Off-chain Data:", offChainData);

  await arbitrageOpportunityDetector.detectArbitrageOpportunity();
}

main();
