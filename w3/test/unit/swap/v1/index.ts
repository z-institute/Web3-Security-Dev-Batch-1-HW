import shouldBehaveAddLiquidity from "./action/swap.liquidity";
import { swapFixture } from "./fixture/swap.fixture";
import shouldReadParameters from "./view/swap.constructor";


export function shouldBehaveSwapContract(): void {
  describe("View Functions", function () {
    describe("# read initial parameters", function () {
      shouldReadParameters();
    });
  });
  describe("Action Functions", function () {
    describe("#constructor", function () {});
    describe("#liqudiity", function () {
      shouldBehaveAddLiquidity();
    });
  });
}

export function SwapV1(): void {
  describe("Swap-V1", function () {
    beforeEach(async function () {
      const { swap, token, signer } = await this.loadFixture(swapFixture);
      this.contracts.swap = swap;
      this.contracts.token = token;
      this.signer = signer;
    });
    shouldBehaveSwapContract();
  });
}