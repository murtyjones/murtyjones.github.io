---
layout: post
title:  "Understanding Bitcoin's Lightning Network - Part II"
date:   2020-09-07 10:11:00 -0400
categories: [bitcoin]
tags: [bitcoin]
---

In the [last post]({{ site.baseurl }}/bitcoin/2020/09/06/understanding-lightning-1.html) of this series about understanding the Lightning Network, I explained the need for payment channels in Bitcoin and gave an example of what a payment channel could look like. That example was (intentionally) simple, but doesn't work well for sending payments outside of the Bitcoin blockchain. In this post, I'll walk through a simple example of a working payment channel in Bitcoin, which was an early predecessor for the Lightning Network.

# Prequisites

In order to work through this example of a simple payment channel, you'll need a basic understanding of two concepts in Bitcoin: Multisignature transactions, and Timelocked transactions.

**Multsig Transactions**

Mutlsignature, or multisig, is a Bitcoin feature that allows coins to be placed into an address (or "account" if it's easier to think of it that way) that requires multiple signatures to spend from. For example, imagine that Alice and Bob want to pool some money together, and want that money to be spent only if both of them "sign off" on it. That would look something like this:

![basic multisig]({{ site.baseurl }}/assets/images/understanding-lightning-2/multisig-basic.png){: style="max-height: 450px"}
{: style="text-align: center"}

Alice contributes 3 coins and Bob contributes 1 to the pool of multsig money, so that the address has a balance of 4 BTC. You'll notice that the box representing the multisig address says "2-of-2 multisig." What this means is that there are two different keys that can be used to sign new transactions that spend from this address, and both of those signatures are required to spend any money. In other words, you must have 2 of the 2 possible signatures to spend the money. We could instead specify that only one signature is needed (1-of-2), in which case either Alice and Bob could spend the money unilaterally. But with 2-of-2, we require that both parties provide their signatures before the money can be spent.

Another nuance with multisig transactions: in this example, we have both Alice and Bob contributing money (Alice 3 coins, Bob 1 coin). This isn't required for a multisig transaction. We could construct a multisig where only Alice contributes money, for example, but both signatures are still required to spend the coins. Why would we do something like that? You'll get the answer later on in this post!

**Timelock**

This is a feature of Bitcoin that allows coins to be "locked," meaning that they cannot be spend until a certain date and time.

![timelocked transaction example]({{ site.baseurl }}/assets/images/understanding-lightning-2/timelock.png){: style="max-height: 300px"}
{: style="text-align: center"}

While this concept is simple, there are nuances to it, just like with multisig transactions. There are different ways that a timelock can be expressed. An absolute date/time can be given, e.g. `Saturday, 12 Sep 2020 11:19:25 GMT`. But a more common way to express a timelock in Bitcoin is to use "block height" where a number is given, e.g. `50`, and that number represents the number of blocks that must be mined after the transaction is included in the Bitcoin blockchain before the timelocked transaction can be spent.

Because the Bitcoin database is just a series of blocks that includes transactions, and since each block is built on top of the last one, they form a nice linear series like this:

![blockchain over time]({{ site.baseurl }}/assets/images/understanding-lightning-2/block-time-series.png)
{: style="text-align: center"}
Note: Each block is mined roughly 10 minutes after the previous one. Sometimes two blocks are mined just seconds apart and sometimes hours apart, but the average time between blocks is ~10 minutes.
{: class="img-footnote"}

What we can do, then, is included a timelocked transaction that requires, say, 2 blocks to be mined before it can be spent:

![relative timelocked transaction example]({{ site.baseurl }}/assets/images/understanding-lightning-2/relative-timelock.png){: style="max-height: 450px"}
{: style="text-align: center"}
Note: What happens if these coins are spent before 48,904 is mined? Every Bitcoin node will reject the transaction, because they can all determine that there have not been enough blocks mined for the transaction to be spent.
{: class="img-footnote"}

Now that we have a basic understanding of how multsig and timelocking work in Bitcon, let's see how we can use these features to create a payment channel between Alice and Bob.

# Funding a Payment Channel

Imagine that Alice is a customer at Bob's coffee shop, and she wants to open a payment channel that she can use to buy coffee from Bob every morning.

In order to 