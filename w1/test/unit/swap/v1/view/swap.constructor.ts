import { expect } from "chai";

import { toWei } from "../../../../../utils/format";

export default function shouldReadParameters(): void {
  it("should retrieve initial exchange parameters", async function () {
    expect(await this.contracts.swap.waitForDeployment()).to.equal(this.contracts.swap);
    expect(await this.contracts.swap.name()).to.equal("Zuniswap-V1");
    expect(await this.contracts.swap.symbol()).to.equal("ZUNI-V1");
    expect(await this.contracts.swap.totalSupply()).to.equal(toWei("0"));
  });
}
