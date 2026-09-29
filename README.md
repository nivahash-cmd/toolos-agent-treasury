# ToolOS Agent Treasury

ToolOS is the AI organization operating system for one-person companies. Agent Treasury adds a USDC-native control layer for funding AI projects, allocating departmental budgets, recording delivery proofs, approving work, and settling costs on Arc.

## Why Arc

Arc is an EVM-compatible network designed for stablecoin finance. USDC is the native gas asset. Agent Treasury uses the six-decimal USDC ERC-20 interface for deposits and payouts.

## Arc mainnet

- Chain ID: 5042
- RPC: https://rpc.mainnet.arc.io
- Explorer: https://explorer.arc.io
- USDC interface: 0x3600000000000000000000000000000000000000
- Intended deployer: 0xA5bE186B86fBc4F844a6f01739F4CC96aEaF03fc
- Product: https://toolos-ai-workbench.nivahash.chatgpt.site/#treasury

## Workflow

1. A founder creates and funds a project in USDC.
2. ToolOS assigns capped budgets to AI departments.
3. Workers submit content-addressed delivery hashes and claimed costs.
4. The founder approves payment or requests revision.
5. Closing the project refunds all unspent USDC.

## Safety

Only the project creator can allocate budgets, approve payouts, request revisions, cancel work, or close a project. Costs cannot exceed department budgets or funded balances. Token transfers use safe return-value handling and a reentrancy lock.

## Development

Install Foundry and forge-std, then run forge test -vvv. Deploy only after testing and independent review. Use a hardware wallet or Foundry keystore. Never paste or commit a private key. Arc deployment requires USDC for gas.

## Status

Prototype contract compiled with Solidity 0.8.24. It has not been audited or deployed to Arc mainnet.

## License

MIT
