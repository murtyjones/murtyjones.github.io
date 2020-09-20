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

# Payment Forwarding

Imagine that we have three parties: Alice, Bob, and Carol. Alice wants to pay Carol 1 coin. But she doesn't have a payment channel open with Carol. Alice *does* have a payment channel with Bob, and Bob has a payment channel with Alice.

![three parties in a payment channel]({{ site.baseurl }}/assets/images/understanding-lightning/three-parties.png){: class='lazyload'}

So Alice and Carol can both pay Bob, and Bob can pay either, but Alice and Carol cannot pay each other.

For Alice to pay Carol, she'll have to either 1. Open a payment channel with Carol (requires an on-chain transaction), or 2. Find a way to get Bob to pay Carol 1 coin. Alice could simply pay Bob 1 coin and include a message asking him to please pay Carol 1 coin as well. This is called **payment forwarding**. But this version of payment forwarding requires that Alice trust Bob to send Carol the money. If Alice sends Bob the coin, and Bob doesn't send Carol a coin in return, Alice has no recourse. So we have to find a better way.

# Conditional Payment Forwarding

What we really need is a way for Alice to pay Bob 1 coin *only* if Bob pays Carol 1 coin, which we'll call **Conditional Payment Forwarding**, and it's a key innovation from the Lightning Network that we'll be discussing today.

--- 

To begin with, Carol will generate a secret, `R`. For now, let's pretend that `R` is `mysecret` (Carol would never actually use this value as it's not secure, this is just for illustration purposes). Carol then hashes `R` using `SHA256`. As you can test [here](https://xorbin.com/tools/sha256-hash-calculator), `sha256('mysecret')` becomes `652c7dc687d98c9889304ed2e408c74b611e86a40caa51c4b43f1dd5913c5cd0`. We'll call this value `H`.

![carol creates a secret, R, and sends Alice the hash of R]({{ site.baseurl }}/assets/images/understanding-lightning/carol-creates-r.png){: class='lazyload', style="max-height: 121px;"}
{: style="text-align: center;"}

Carol sends the value of `H` to Alice, but retains the value of `R` so that only she knows it.