# Yearn Integration Boilerplate

## What you'll find here

- Yearn Vault interface in Solidity ([`contracts/VaultAPI.sol`](contracts/VaultAPI.sol))
- Examples

This boilerplate has some configuration already done in [`hardhat.config.ts`](hardhat.config.ts).

### Example: Yield Challenge

([`contracts/YieldChallenge.sol`](contracts/YieldChallenge.sol))

This contract is a basic example of how to integrate with a Yearn Vault. The user deposits funds using any ERC20 token and sets a deadline for the challenge to be completed. They do this calling the deposit function.

```solidity
deposit(_amount, _deadline)
```

After depositing the tokens, these are instantly deposited into Yearn to earn yield.

```solidity
VaultAPI(vault).deposit(_amount)
```

When the deadline is met, the judge can submit the result of the challenge to the contract.

```solidity
submitResult(_user,_status)
```

If the `_status == true`, then it means the user completed the challenge successfully.

The user can only get their money when the deadline is met, by calling the withdraw function.

```solidity
withdraw()
```

The contract is going to check if the challenge has been completed. If so, it will withdraw and send them their principal + the yield accrued during that time. If they didn't complete the challenge, they will get their money back but the yield goes to the treasury.

This is not audited and there are many ways to improve it. It's a proof of concept meant to serve as an integration example.