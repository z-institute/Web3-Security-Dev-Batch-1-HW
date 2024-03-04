import type { SignerWithAddress } from "@nomicfoundation/hardhat-ethers/signers";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { ethers } from "hardhat";
import { Address } from "hardhat-deploy/types";

import type { Exchange__factory, Token } from "../../../../../types";
import type { Exchange } from "../../../../../types/contracts/v1/Exchange.sol";
import { tokenFixture } from "./token.fixture";

export async function swapFixture(): Promise<{
  swap: Exchange;
  token: Token;
  signer: Address;
}> {
  const signers = await ethers.getSigners();
  const deployer: SignerWithAddress = signers[0];

  const { token } = await loadFixture(tokenFixture);

  const ExchangeFactory: Exchange__factory = (await ethers.getContractFactory(
    "Exchange"
  )) as Exchange__factory;

  type DeployArgs = Parameters<typeof ExchangeFactory.deploy>;
  const args: DeployArgs = [token.getAddress()];

  const swap: Exchange = (await ExchangeFactory.connect(deployer).deploy(...args)) as Exchange;
  await swap.waitForDeployment();

  return { swap, token, signer: deployer.address };
}
