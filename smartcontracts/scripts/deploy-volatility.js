const { ethers } = require("hardhat");

const priceFeed = "0xA39434A63A52E749F02807ae27335515BA4b07F7";

// Deploy function
async function deploy() {
  [account, account2, account3] = await ethers.getSigners();


  const Lib = await ethers.getContractFactory("MathVol");
  const lib = await Lib.deploy();
  console.log(lib);
  await lib.deploymentTransaction().wait(1);

  console.log(`Deploying contracts using ${account.address}`);
  console.log(`Deployment address ${lib.address}`);

  const volatility = await ethers.getContractFactory("Volatility", {
    signer: account,
    libraries: {
        MathVol: lib.address,
      }
  });
  const contract = await volatility.deploy(2500000000000, 2000000000, priceFeed); 
  await contract.deployed();


}

deploy()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
