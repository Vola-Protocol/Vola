const { ethers } = require("hardhat");
const ERC20ABI = require("./ERC20ABI.json");

const ERC20_TOKEN_ADDRESS = "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2";

// Deploy function
async function deploy() {
  [account, account2, account3] = await ethers.getSigners();
  console.log(`Deploying contracts using ${account.address}`);
  const VolaVault = await ethers.deployContract("VolaVault", [ERC20_TOKEN_ADDRESS,
    "Vola",
    "VOLA"]);
  await VolaVault.waitForDeployment();

  console.log("VolaVault contract deployed at", VolaVault.target);
  console.log(
    "1000 share token is equal to ",
    1000 / Number(await VolaVault.convertToShares(1)),
    "Asset"
  );

  // Use account2 as the signer for the first weth contract
  const weth1 = new ethers.Contract(ERC20_TOKEN_ADDRESS, ERC20ABI, account2);

  // Use account3 as the signer for the second weth contract
  const weth2 = new ethers.Contract(ERC20_TOKEN_ADDRESS, ERC20ABI, account3);

  console.log("Minting 1000 weth tokens from account2");
  const test1 = await weth1.deposit({ value: ethers.parseEther("1000") });

  console.log("Minting 1000 weth tokens from account3");
  const test2 = await weth2.deposit({ value: ethers.parseEther("1000") });

  console.log("Approving 1000 weth tokens to VolaVault from account2");
  const approve1 = await weth1.approve(VolaVault.target, 1000);

  console.log("Approving 1000 weth tokens to VolaVault from account3");
  const approve2 = await weth2.approve(VolaVault.target, 1000);

  console.log("Depositing 1000 weth tokens to VolaVault from account2");
  const deposit1 = await VolaVault.connect(account2)._deposit(1000);

  console.log("Depositing 1000 weth tokens to VolaVault from account3");
  const deposit2 = await VolaVault.connect(account3)._deposit(1000);


  const totalAssetsfor2 = await VolaVault.totalAssetsOfUser(account2.address);
  console.log("Total number of shares for account2: ", totalAssetsfor2);
  // console.log("Withdrawing the weth token from VolaVault using account");
  const withdraw = await VolaVault
    .connect(account3)
    ._withdraw(1000, account2.address);

  const totalAssetsfor2After = await VolaVault.totalAssetsOfUser(
    account2.address
  );
  console.log("Total number of shares for account2: ", totalAssetsfor2After);

  console.log(
    "1000 share token is equal to ",
    1000 / Number(await VolaVault.convertToShares(1)),
    "Asset"
  );
}

deploy()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
