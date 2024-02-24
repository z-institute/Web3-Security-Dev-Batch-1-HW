import type { SignerWithAddress } from "@nomicfoundation/hardhat-ethers/signers";
import { ethers } from "hardhat";

import type { Token, Token__factory } from "../../../../../types";
import { toWei } from "../../../../../utils/format";

export async function tokenFixture(): Promise<{
  token: Token;
}> {
  const signers = await ethers.getSigners();
  const deployer: SignerWithAddress = signers[0];

  const ERC20Factory = (await ethers.getContractFactory("Token")) as Token__factory;
  const token = (await ERC20Factory.deploy("TokenA", "TokenA", toWei("1000000"))) as Token;
  await token.connect(deployer).waitForDeployment();
  return { token };
}
