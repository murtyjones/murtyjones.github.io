---
layout: post
title:  "Understanding Bitcoin's Lightning Network - Part III"
date:   2020-09-14 19:40:00 -0400
categories: [bitcoin]
tags: [bitcoin]
---

In the [last post]({{ site.baseurl }}/bitcoin/2020/09/13/understanding-lightning.html) of this series we discussed the concept of a **one-way payment channel**, where Alice can pay Bob, but Bob cannot pay Alice.

Looking at this image:

![trying to spend from the recipient in a one-way payment channel]({{ site.baseurl }}/assets/images/understanding-lightning/one-way-payment-channel-going-backwards.png){: style="max-height: 450px"}
{: style="text-align: center"}

We can see that the reason that the previous payment channel won't in two directions is that Bob cannot promise to Alice that he has no credible way to prove to Alice that he won't just broadcast an earlier transaction that is more favorable for him.

What we really need for the payment channel to be bi-directional is a way for Bob to *revoke* prior transactions so that Alice knows that he can't use them.

In this post, we're going to walk through a payment channel structure that lets Bob and Alice pay one another, and revoke any prior transactions in the payment channel as they go. This is called a **bi-directional** or **two-way** payment channel.

# Funding a Two-Way Payment Channel

Let's take a look at how Alice and Bob can fund this payment channel:

![trying to spend from the recipient in a two-way payment channel]({{ site.baseurl }}/assets/images/understanding-lightning/open-bi-directional-channel.png){: style="max-height: 250px"}
{: style="text-align: center"}

Here we have the initial funding transaction. This looks similar to the funding transaction from the previous post where we examined one-way payment channels. Two key differences are that 1. There is not timelock on this transaction (IE it will never expire), and 2. This transaction is not signed yet, meaning that it cannot be broadcasted yet.

The reason that we have no timelock on this transaction is that, as we'll see in just a moment, any party will be able to close the channel at any time. Recall that we used a timelock previously to prevent a situation where Bob refuses to cooperate and Alice's coins are stuck in the funding transaction. In this implementation of a payment channel, such a situation can be avoided completely.

Here's how we can avoid non-cooperation: Notice that, at the moment, the funding transaction cannot be broadcasted to the blockchain because of the missing signatures. Alice and Bob left their signatures off of the transaction purposefully, because they both want to ensure that they'll have a way to get their coins back in the event of non-cooperation. Since we have no timelock, neither party currently has a guarantee about being able to get their money back.

The way that Alice and Bob can give each other a guarantee, before opening the payment channel, is to *exchange refund transactions before signing + broadcasting the funding transaction*.

![trying to spend from the recipient in a two-way payment channel]({{ site.baseurl }}/assets/images/understanding-lightning/open-bi-directional-channel.png){: style="max-height: 250px"}
{: style="text-align: center"}
