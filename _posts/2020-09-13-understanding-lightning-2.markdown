---
layout: post
title:  "Understanding Lightning Part II – One-Way Channels"
date:   2020-09-13 19:40:00 -0400
categories: [bitcoin]
tags: [bitcoin]
---

In the **[last post]({{ site.baseurl }}/bitcoin/2020/09/06/understanding-lightning-1.html)** of this series about understanding the Lightning Network, I explained the need for payment channels in Bitcoin and gave an example of what a payment channel could look like. That example was (intentionally) simple, but doesn't work well for sending payments outside of the Bitcoin blockchain. In this post, I'll walk through a simple example of a working payment channel in Bitcoin, which was an early predecessor for the Lightning Network.

# Prequisites

In order to work through this example of a simple payment channel, you'll need a basic understanding of two concepts in Bitcoin: Multisignature transactions, and Timelocked transactions.

**Multsig Transactions**

Mutlsignature, or multisig, is a Bitcoin feature that allows coins to be placed into an address (or "account" if it's easier to think of it that way) that requires multiple signatures to spend from. For example, imagine that Alice and Bob want to pool some money together, and want that money to be spent only if both of them "sign off" on it. That would look something like this:

![basic multisig]({{ site.baseurl }}/assets/images/understanding-lightning/multisig-basic.png){: style="max-height: 450px" class="lazyload"}
{: style="text-align: center"}

Alice contributes 3 coins and Bob contributes 1 to the pool of multsig money, so that the address has a balance of 4 BTC. You'll notice that the box representing the multisig address says "2-of-2 multisig." What this means is that there are two different keys that can be used to sign new transactions that spend from this address, and both of those signatures are required to spend any money. In other words, you must have 2 of the 2 possible signatures to spend the money. We could instead specify that only one signature is needed (1-of-2), in which case either Alice and Bob could spend the money unilaterally. But with 2-of-2, we require that both parties provide their signatures before the money can be spent.

Another nuance with multisig transactions: in this example, we have both Alice and Bob contributing money (Alice 3 coins, Bob 1 coin). This isn't required for a multisig transaction. We could construct a multisig where only Alice contributes money, for example, but both signatures are still required to spend the coins. Why would we do something like that? You'll get the answer later on in this post!

**Timelock**

This is a feature of Bitcoin that allows coins to be "locked," meaning that they cannot be spend until a certain date and time.

![timelocked transaction example]({{ site.baseurl }}/assets/images/understanding-lightning/timelock.png){: style="max-height: 300px" class="lazyload"}
{: style="text-align: center"}

While this concept is simple, there are nuances to it, just like with multisig transactions. There are different ways that a timelock can be expressed. An absolute date/time can be given, e.g. `Saturday, 12 Sep 2020 11:19:25 GMT`. But a more common way to express a timelock in Bitcoin is to use "block height" where a number is given, e.g. `50`, and that number represents the number of blocks that must be mined after the transaction is included in the Bitcoin blockchain before the timelocked transaction can be spent.

Because the Bitcoin database is just a series of blocks that includes transactions, and since each block is built on top of the last one, they form a nice linear series like this:

![blockchain over time]({{ site.baseurl }}/assets/images/understanding-lightning/block-time-series.png){:class="lazyload"}
{: style="text-align: center"}
Note: Each block is mined roughly 10 minutes after the previous one. Sometimes two blocks are mined just seconds apart and sometimes hours apart, but the average time between blocks is ~10 minutes.
{: class="img-footnote"}

What we can do, then, is included a timelocked transaction that requires, say, 2 blocks to be mined before it can be spent:

![relative timelocked transaction example]({{ site.baseurl }}/assets/images/understanding-lightning/relative-timelock.png){: style="max-height: 450px" class="lazyload"}
{: style="text-align: center"}
Note: What happens if these coins are spent before 48,904 is mined? Every Bitcoin node will reject the transaction, because they can all determine that there have not been enough blocks mined for the transaction to be spent.
{: class="img-footnote"}

Now that we have a basic understanding of how multsig and timelocking work in Bitcon, let's see how we can use these features to create a payment channel between Alice and Bob.

# Funding a Payment Channel

Imagine that Alice is a customer at Bob's coffee shop, and she wants to open a payment channel that she can use to buy coffee from Bob every morning.

In order for Alice to open a payment channel to Bob, we'll use the two concepts outlined above to create a multsig transaction that Alice & Bob control together.

![opening a one-way payment channel]({{ site.baseurl }}/assets/images/understanding-lightning/open-one-way-channel.png){: style="max-height: 450px" class="lazyload"}
{: style="text-align: center"}

The above transaction is known as a **funding transaction**, meaning that it funds the payment channel that Alice and Bob will use. Here's how it works:

- Bob sends Alice his public key that he will use to sign future transactions from this channel
- Alice uses Bob's public key and her own public key to create a new transaction that spends 10 of her coins, sending them to an address that can only be spent from in two ways:
    1. If Alice & Bob both sign a transaction to spend the coins, OR
    2. If Alice signs a transaction to spend the coins *and* a week has passed since the funding transaction ws entered into the Bitcoin blockchain
- Alice broadcasts the transaction, and once a miner includes it in a block, the payment channel is considered "open."

You can see that both of the concepts described above (multsig and timelocking) are used in this transaction.

At this point you might be wondering a couple of things:

1. Why are both Alice and Bob's signatures needed to spend the coins in the first case?
2. Why is Alice able to spend the coins by herself after 1 week?

Requiring these conditions create a situation where, for 1 week, both Alice and Bob have to sign any transaction *before* it can be broadcasted to miners to include in a block. If it's broadcasted before then and one of Alice or Bob hasn't signed it, a miner won't be able to include it in a block because it'll be rejected, cause the whole block to be rejected. By creating this requirement, Alice and Bob are ensuring that *no one can cheat the other by spending the 10 coins in the payment channel without the other's permission*. Any transaction that is broadcasted must be signed by both parties, so Alice has no way to cheat Bob and vice versa.

After the week has elapsed, *if Alice and Bob have not closed the payment channel yet*, Alice will be able to reclaim her money. Why is this condition included? This is easiest to understanding by thinking about how the transaction would work if we didn't include this condition. Imagine that Alice contributed 10 coins to the payment channel, and Alice + Bob's signature is required to spend any of the coins in that channel for all eternity.

A scenario where there is no timelock/expiration on the payment channel would give Bob some sneaky leverage over Alice, because he can refuse to sign a transaction to close the payment channel, leaving Alice unable to get her coins back! In this example, Bob isn't even contributing any money, so he has no cost to bear for this attack. He can simply tell Alice that he wants, say, 5 coins to close the channel, and refuse to sign any transaction that doesn't send him 5 coins. Not great! So we add a timelock of 1 week, which ensures that Alice will be able to get all 10 of her coins back in one week if for some reason Bob isn't cooperating with her and they can't close the transaction together.

Next, let's take a look at how Alice can use the funds in the payment channel to send Bob money once the funding transaction above has been included in the blockchain.

# Spending money in a payment channel: day one

Imagine that Alice and Bob create this transaction on Monday, and Alice goes to Bob's coffee shop on Tuesday wanting to buy her first cup of coffee using this payment channel. Alice signs a transaction and gives it to Bob:

![first transaction spending from a one-way payment channel]({{ site.baseurl }}/assets/images/understanding-lightning/one-way-payment-channel-first-spend.png){: style="max-height: 450px" class="lazyload"}
{: style="text-align: center"}

This transaction is pretty straightforward. It:

- Spends from the funding transaction.
- Is signed by Alice
- Sends 9 coins back to Alice, and 1 coin to Bob (to pay for the coffee).

At this point, Alice gives Bob the transaction and Bob gives Alice a coffee. It's important to note that Alice and Bob are the *only* people who know about this transaction right now. It has *not* been broadcasted to the Bitcoin network.

Bob can broadcast this transaction if he wants to go ahead and claim the coin. But in doing so, he's going to close the payment channel that he and Alice established, and a fee may have to be paid to get the transaction included in a block (how that fee would be paid in this example is out of scope for this post but it's not too complicated).

But Bob knows that Alice will be back tomorrow for another cup of coffee, and Bob also knows that he has 6 days to broadcast a transaction closing the channel (before Alice's timelock is up and she can reclaim her money). So Bob does not broadcast this transaction to miners.

<details>
    <summary><b>Pop Quiz</b>: If Bob did decide to broadcast the transaction that Alice gives him, what does he need to do before broadcasting it? <i>(Click to see the answer)</i></summary>
    <i>Because the transaction requires both Alice and Bob's signature to be valid, Bob must <b>Sign the transaction before broadcasting it.</b> Alice has already signed it before giving it to Bob, so his signature is the only one needed to make the transaction valid and he can add it whenever he wants to.</i>
</details>

# Spending money in a payment channel: day two

When Alice comes back on Wednesday to buy her morning coffee from Bob, she once again makes a transaction, signs it, and gives it to Bob:

![second transaction spending from a one-way payment channel]({{ site.baseurl }}/assets/images/understanding-lightning/one-way-payment-channel-second-spend.png){: style="max-height: 450px" class="lazyload"}
{: style="text-align: center"}

The day two transaction is exactly the same as the day one transaction, except that it gives Bob two coins instead of one (one for the coffee on Tuesday, one for the coffee on Wednesday).

Notice that both of the transactions that Alice gives Bob spend from the funding transaction. This is important, because it means that **only one of these transactions can be included in the blockchain.** In Bitcoin, money cannot be spent multiple times, so only one of these transactions should be broadcasted by Bob. He can sign and broadcast whichever one he wants, but he'll obviously want to broadcast the day two transaction because that's the one that gives him more coins.

Alice and Bob can continue to transact in this way until the timelock approaches, at which point Bob will pick whichever transaction gives him the most coins, then sign and broadcast it so that the channel is closed.

# Spending money in a payment channel: What about Bob?

At this point, we have a working payment channel! But there's an unanswered question: what happens if Bob needs to send Alice money?

Imagine that Bob wants to send Alice a refund for some reason using this payment channel. He could do something like this:

![trying to spend from the recipient in a one-way payment channel]({{ site.baseurl }}/assets/images/understanding-lightning/one-way-payment-channel-going-backwards.png){: style="max-height: 450px" class="lazyload"}
{: style="text-align: center"}

The transaction in red above is a transaction that Bob signs and sends to Alice. It's similar to the ones Alice has given Bob already, except that it has Bob's signature and needs Alice's to be spent.

There's a problem with this transaction: how does Alice know that Bob isn't going to just spend the transaction from day two (the one that gives him two coins)? She doesn't. Bob's attempt to give Alice back one coin isn't credible, because Alice knows that Bob can just claim 2 coins anyways after giving her the refund transaction.

This means that our payment channel only functions as a "one way" channel. Alice can pay Bob, but Bob can't pay Alice.

In the **[next post]({{ site.baseurl }}/bitcoin/2020/09/18/understanding-lightning-3.html)** of this series, we'll examine a way for Alice and Bob to pay one another in what's called a "bi-directional" or "two way" payment channel.