import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";


const OrderBasedSwap = buildModule("OrderBasedSwap", (m) => {

  const orderBasedSwap = m.contract("OrderBasedSwap");

  return { orderBasedSwap };
});

export default OrderBasedSwap;
