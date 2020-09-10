---
layout: post
title:  "Understanding Bitcoin's Lightning Network - Part II"
date:   2020-09-07 10:11:00 -0400
categories: [bitcoin]
tags: [bitcoin]
---

In the [last post]({{ site.baseurl }}/bitcoin/2020/09/06/understanding-lightning-1.html) of this series about understanding the Lightning Network, I explained the need for payment channels in Bitcoin and gave an example of what a payment channel could look like. That example was (intentionally) simple, but doesn't work well for sending payments outside of the Bitcoin blockchain. In this post, I'll walk through a simple example of a working payment channel in Bitcoin, which was an early predecessor for the Lightning Network.

# Prequisites

In order to work through this example of a simple payment channel, you'll need a basic understanding of two concepts in Bitcoin: Multisignature wallets, and locktime.

**Multsig**

Mutlsignature, or multisig, is a Bitcoin feature that allows coins to be placed into an "account" that requires more than one signature to spend from. For example, imagine that Alice and Bob want to pool some money together into a multisig address. That would look something like this:

![basic multisig]({{ site.baseurl }}/assets/images/understanding-lightning-2/multisig-basic.png){: height="450px"}
{: style="text-align: center"}