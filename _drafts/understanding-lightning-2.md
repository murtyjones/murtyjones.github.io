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

![basic multisig]({{ site.baseurl }}/assets/images/understanding-lightning-2/multisig-basic.png){: height="450px"}
{: style="text-align: center"}

Alice contributes 3 coins and Bob contributes 1 to the pool of multsig money, so that the address has a balance of 4 BTC. You'll notice that the box representing the multisig address says "2-of-2 multisig." What this means is that there are two different keys that can be used to sign new transactions that spend from this address, and both of those signatures are required to spend any money. In other words, you must have 2 of the 2 possible signatures to spend the money. We could instead specify that only one signature is needed (1-of-2), in which case either Alice and Bob could spend the money unilaterally. But with 2-of-2, we require that both parties provide their signatures before the money can be spent.

Another nuance with multisig transactions: in this example, we have both Alice and Bob contributing money (Alice 3 coins, Bob 1 coin). This isn't required for a multisig transaction. We could construct a multisig where only Alice contributes money, for example, but both signatures are still required to spend the coins. Why would we do something like that? You'll get the answer later on in this post!

**Timelock**

