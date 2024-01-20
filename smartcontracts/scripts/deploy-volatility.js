const { ethers } = require("hardhat");

const priceFeed = "0xA39434A63A52E749F02807ae27335515BA4b07F7";

// Deploy function
async function deploy() {
  [account, account2, account3] = await ethers.getSigners();


  const lib = await ethers.deployContract("MathVol");
  
  await lib.waitForDeployment();

  console.log(`Deploying contracts using ${account.address}`);
  console.log(`Deployment address ${lib.target}`);

  const volatility = await ethers.deployContract("Volatility",[2500000000000, 2000000000, priceFeed]
  ,{
    signer: account,
    libraries: {
        MathVol: lib.target,
      }
  });
  
  await volatility.waitForDeployment();;


}

deploy()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
