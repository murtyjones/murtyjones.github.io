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

In this post, we're going to walk through a payment channel structure that lets Bob and Alice pay one another, and revoke any prior transactions in the payment channel as they go. This is called a **bi-directional** payment channel.

# Funding a Bi-Directional Payment Channel

