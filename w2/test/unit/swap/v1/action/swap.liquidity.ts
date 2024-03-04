import { expect } from "chai";
import { ethers } from "hardhat";



import { MAX_UINT256 } from "../../../../../utils/constants";
import { fromWei, toWei } from "../../../../../utils/format";
import { Errors } from "../../../../shared/errors";


export default function shouldBehaveAddLiquidity(): void {
  context("addLiquidity", function () {
    it("adds liquidity", async function () {
      await this.contracts.token.approve(this.contracts.swap.getAddress(), MAX_UINT256.toString());
      await this.contracts.swap.addLiquidity(toWei("200"), { value: toWei("100") });

      const swapAddress = await this.contracts.swap.getAddress();
      const exchangeBalance = await ethers.provider.getBalance(swapAddress);

      expect(exchangeBalance).to.equal(toWei("100"));
      expect(await this.contracts.swap.getReserve()).to.equal(toWei("200"));
    });
    it("adds liquidity and compare prices", async function () {
      await this.contracts.token.approve(this.contracts.swap.getAddress(), MAX_UINT256.toString());
      await this.contracts.swap.addLiquidity(toWei("200"), { value: toWei("100") });

      const swapAddress = await this.contracts.swap.getAddress();
      const exchangeBalance = await ethers.provider.getBalance(swapAddress);

      expect(exchangeBalance).to.equal(toWei("100"));
      expect(await this.contracts.swap.getReserve()).to.equal(toWei("200"));

      const tokenReserve = await this.contracts.swap.getReserve();

      // ETH per token (1 token equal to how much eth ?)
      expect(
        (await this.contracts.swap.getPrice(exchangeBalance, tokenReserve)).toString()
      ).to.equal("500");

      // token per ETH (1 ETH equal to how much token ?)
      expect(
        (await this.contracts.swap.getPrice(tokenReserve, exchangeBalance)).toString()
      ).to.equal("2000");
    });

    it("adds liquidity and return token amounts", async function () {
      await this.contracts.token.approve(this.contracts.swap.getAddress(), MAX_UINT256.toString());
      await this.contracts.swap.addLiquidity(toWei("200"), { value: toWei("100") });

      const tokensOut = await this.contracts.swap.getTokenAmount(toWei("1"));
      const etherOut = await this.contracts.swap.getEthAmount(toWei("1"));

      expect(Number(fromWei(etherOut))).to.lessThanOrEqual(0.5);
      expect(Number(fromWei(tokensOut))).to.lessThanOrEqual(2);
    });
  });
  context("removeLiquidity", function () {
    it("remove liquidity", async function () {
      await this.contracts.token.approve(this.contracts.swap.getAddress(), MAX_UINT256.toString());
      await this.contracts.swap.addLiquidity(toWei("200"), { value: toWei("300") });
      await this.contracts.swap.removeLiquidity(toWei("20"));
    });
  });
  context("LP tokens", function () {
    it("add first liquidity and receive lp tokens", async function () {
      await this.contracts.token.approve(this.contracts.swap.getAddress(), MAX_UINT256.toString());
      await this.contracts.swap.addLiquidity(toWei("200"), { value: toWei("300") });
      const lpTokenBalance = await this.contracts.swap.balanceOf(this.signer);
      expect(lpTokenBalance).to.equal(toWei("300"));
    });
    it("continue to add liquidity and receive lp tokens", async function () {
      await this.contracts.token.approve(this.contracts.swap.getAddress(), MAX_UINT256.toString());
      await this.contracts.swap.addLiquidity(toWei("200"), { value: toWei("300") });

      const lpTokenBalanceBefore = await this.contracts.swap.balanceOf(this.signer);
      expect(lpTokenBalanceBefore).to.equal(toWei("300"));

      await this.contracts.swap.addLiquidity(toWei("400"), { value: toWei("600") });
      const lpTokenBalance = await this.contracts.swap.balanceOf(this.signer);

      //since previous liquidity still exists, we should receive 600 lp tokens and plus the previous 300
      expect(lpTokenBalance).to.equal(toWei("900"));
    });
  });
  context("Reverted with errors", function () {
    it("reverted with invalid eth input amount when getting token amounts", async function () {
      await expect(this.contracts.swap.getTokenAmount(toWei("0"))).to.be.revertedWithCustomError(
        this.contracts.swap,
        Errors.Exchange_Insufficient_Eth_Amount
      );
    });
    it("reverted with invalid input amounts when continue adding liquidity", async function () {
      await this.contracts.token.approve(this.contracts.swap.getAddress(), MAX_UINT256.toString());
      await this.contracts.swap.addLiquidity(toWei("200"), { value: toWei("100") });
      await expect(
        this.contracts.swap.addLiquidity(toWei("110"), { value: toWei("600") })
      ).to.be.revertedWithCustomError(
        this.contracts.swap,
        Errors.Exchange_Insufficient_Token_Amount
      );
    });
  });
}
