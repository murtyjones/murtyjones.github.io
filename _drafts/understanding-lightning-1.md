## Funding TX
- Both parties create a tx with inputs from each party and an output that is a 2-of-2 multisig. They do not sign the tx yet so it is not broadcastable.

- Next, the parties create a refund transaction, with the multisig tx as input. They sign it. This tx is not yet broadcastable because the funding tx is not signed. but it guarantees that when they sign the funding tx, they both have recourse to get a refund if the other parties doesnt cooperate. If the parties were to sign the funding tx before creating the refund tx, then the funds in the multisig could be locked up forever if the parties don't cooperate, or a hostage situation could be created where one party has to pay another to cooperate. So the refund transaction gives both parties an out if cooperate isn't possible.

## Revocable tx

- I sign tx1 giving me $8 and you $2 from a multsig where I own $9 and you own $1. tx1 just needs your signature to be broadcasted.
- When/if you sign and broadcast tx1, I get $8 immediately and you get $2, but you have
  to wait one day to claim it, OR you have to have my signature + your signature
- If we then sign a tx giving me $9 and you $1, you would give me the revocation signature

## One-hop payment channel

- Want to send money to Bob, and I don't have a payment channel with Bob
- Alice has a payment channel with Bob and I have a payment channel with Alice
- How do I trustlessly 