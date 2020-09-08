---
layout: post
title:  "Understanding Bitcoin's Lightning Network - Part II"
date:   2020-09-07 10:11:00 -0400
categories: [bitcoin]
tags: [bitcoin]
---

In the [last post]({{ site.baseurl }}/bitcoin/2020/09/06/understanding-lightning-1.html) of this series about understanding the Lightning Network, I explained the need for payment channels in Bitcoin and gave an example of what a payment channel could look like. That example was (intentionally) simple, but doesn't work well. In this post, I'll walk through a slightly better payment channel idea in Bitcoin, which was an early predecessor for the Lightning Network.

# Payment Channels - a simple implementation

