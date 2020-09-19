---
layout: post
title:  "Understanding Lightning Part IV – Payment Forwarding"
date:   2020-09-19 00:00:00 -0400
categories: [bitcoin]
tags: [bitcoin]
---

In the [last post]({{ site.baseurl }}/bitcoin/2020/09/18/understanding-lightning-3.html) of this series, we showed how Alice and Bob can pay each other using a *two-way*, or *bi-directional* payment channel. We showed that payment channels can be kept open indefinitely, using a revokable transaction scheme.

While two-way payment channels work well, there's one major improvement that can be made to them. In payment channel design that we describe previously, Alice and Bob must create a funding transaction on the Bitcoin blockchain in order to open a payment channel. This means that Alice would have to make a payment channel with every merchant she wants to pay in order to take advantage of payment channels. As we discussed in the [first post]({{ site.baseurl }}/bitcoin/2020/09/06/understanding-lightning-1.html) of this series, Bitcoin's transaction limits won't allow every person in the world to do a a bunch of transactions regularly, so this isn't a scalable solution.

What we really need is a way for parties to pay one another **without having to open a new payment channel**, which is what we'll explore today.

---

Imagine that we have three parties: Alice, Bob, and Carol. Alice wants to pay Carol `1` coin. But she doesn't have a payment channel open with Carol. Alice *does* have a payment channel with Bob, and Bob has a payment channel with Alice.

![three parties in a payment channel]({{ site.baseurl }}/assets/images/understanding-lightning/three-parties.png){: class='lazyload'}
