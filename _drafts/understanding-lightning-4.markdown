---
layout: post
title:  "Understanding Lightning Part IV – Payment Forwarding"
date:   2020-09-19 00:00:00 -0400
categories: [bitcoin]
tags: [bitcoin, lightning]
---

In the [last post]({{ site.baseurl }}/bitcoin/2020/09/18/understanding-lightning-3.html) of this series, we showed how Alice and Bob can pay each other using a *two-way*, or *bi-directional* payment channel. We showed that payment channels can be kept open indefinitely, using a revokable transaction scheme.

While two-way payment channels work well, there's one major improvement that can be made to them. In the payment channel design that we describe previously, Alice and Bob must create a funding transaction on the Bitcoin blockchain in order to open a payment channel. This means that Alice would have to make a payment channel with every merchant she wants to pay in order to take advantage of payment channels. As we discussed in the [first post]({{ site.baseurl }}/bitcoin/2020/09/06/understanding-lightning-1.html) of this series, Bitcoin's transaction limits won't allow every person in the world to do a a bunch of transactions regularly, so opening a new funding channel for every merchant isn't really feasible for Alice.

What we really need is a way for parties to pay one another **without having to open a new payment channel**, which is what we'll explore today.

# Payment Forwarding

Imagine that we have three parties: Alice, Bob, and Carol. Alice wants to pay Carol 1 coin. But she doesn't have a payment channel open with Carol. Alice *does* have a payment channel with Bob, and Bob has a payment channel with Carol.

![three parties in a payment channel]({{ site.baseurl }}/assets/images/understanding-lightning/three-parties.png){: class='lazyload'}

So Alice and Carol can both pay Bob, and Bob can pay either, but Alice and Carol cannot pay one another.

For Alice to pay Carol, she'll have to either 1. Open a payment channel with Carol (requires an on-chain transaction), or 2. Find a way to get Bob to pay Carol. Alice could simply pay Bob 1 coin and include a message asking him to please pay Carol 1 coin as well. This is called **payment forwarding**. But this version of payment forwarding requires that Alice trust Bob to send Carol the money. If Alice sends Bob the coin, and Bob doesn't send Carol a coin in return, Alice loses 1 coin and has no recourse. So we have to find a better way.

# Conditional Payment Forwarding

What we really need is a way for Alice to pay Bob 1 coin *only* if Bob pays Carol, which we'll call **Conditional Payment Forwarding**. This is a key innovation in the Lightning Network that we'll be discussing today.

--- 

![carol creates a secret, R, and sends Alice the hash of R]({{ site.baseurl }}/assets/images/understanding-lightning/carol-creates-r.png){: class='lazyload', style="max-height: 121px;"}
{: style="text-align: center;"}
Carol creates a secret and sends Alice the hash of the secret
{: class="img-footnote"}

To begin with, Carol will generate a secret, `R`. For now, let's pretend that `R` is `mysecret` (Carol would never really use this value, as it's insecure, this is just for illustration purposes). Carol then hashes `R` using `SHA256`. As you can test [here](https://xorbin.com/tools/sha256-hash-calculator), `sha256('mysecret')` becomes `652c7dc687d98c9889304ed2e408c74b611e86a40caa51c4b43f1dd5913c5cd0`. We'll call this value `H`. Carol sends the value of `H` to Alice, but retains the value of `R` so that only she knows it.

![alice sends bob a conditional transaction]({{ site.baseurl }}/assets/images/understanding-lightning/alice-bob-r-transaction.png){: class='lazyload', style="max-height: 300px;"}
{: style="text-align: center;"}
Alice sends Bob a transaction conditional on Bob knowing R
{: class="img-footnote"}

Once Alice has `H`, She'll send Bob a transaction giving Bob 1 coin, but only if Bob can prove that he knows the value that hashes to `H` within the next 5 hours. In other words, he must provide `R`. If Bob cannot prove that he knows `R` within the next 5 hours, Alice would be able to take the coins back using her key.

At this point, Alice has sent Bob a transaction that he cannot redeem, because Bob does not know `R`. But if Alice tells Bob that Carol knows `R`, Bob can attempt to learn `R` from Carol.

![bob sends carol a conditional transaction]({{ site.baseurl }}/assets/images/understanding-lightning/bob-carol-r-transaction.png){: class='lazyload', style="max-height: 300px;"}
{: style="text-align: center;"}
Bob sends Carol a transaction conditional on Carol knowing R
{: class="img-footnote"}

Bob sends Carol a conditional payment, where Carol must reveal `R` within the next hour to claim 0.99 coins. Notice a few things about this transaction:

- Carol already has `R`, so she can claim the 0.99-coin output immediately
- Bob is only sending carol 0.99 coins, despite receiving 1 coin from Alice. The 0.01-coin difference is his chosen transaction fee
- Bob can claim this output back after just 1 hour if Carol has not broadcasted the transaction with the `R` value

Let's explore each of these points in greater depth.

**Carol knows `R`**

This is pretty straightforward, but Carol knows `R` because she created `R` at the beginning of this transaction process. She can immediately claim the 0.99 coins by including the`R` value of `mysecret` with the transaction when she broadcasts it to the blockchain. Bob still does not know `R`, but when Carol broadcasts this transaction, Bob will be able to see `R` because Carol has to reveal it to the world to claim her 0.99 coins. So Bob guarantees that Carol will have to reveal `R` to him in order to claim her money.

**Bob sends Carol 0.99 coins, but receives 1 coin from Alice**

Bob has decided that he wants a transaction fee of 0.01 coin to forward this payment to Carol. You might be wondering if Bob could choose a ridiculously high transaction fee, like 0.5 coins for example. Well, he can! But if he does that, Carol is under no obligation to reveal `R` to him. She can decide whether or not she's okay with this transaction fee. If she isn't, she can simply send Alice a message and let her know that the transaction fee is too high, and create a new secret that Alice can use to forward the payment through some other party. So Bob has an incentive to pick a transaction fee that is acceptable to Alice and Carol, because he may lose out on getting a fee altogether if he picks an amount that's too high. Additionally, they could close their channels with him if they feel that he won't forward payments for a reasonable fee in the future. So yes, Bob can choose his transaction fee, but he has an incentive to choose a reasonable one.

**Bob sets the locktime to just 1 hour**

Alice's payment to Bob has a locktime of 5 hours (IE she can claim the coin back after 5 hours), but Bob's payment to Carol has a locktime of just 1 hour (IE Bob can claim the 0.99 back after just 1 hour). Why are these locktimes needed, and why is the Bob→Carol timelock so much shorter than the Alice→Bob timelock?

Well, Alice needs a timelock so that Bob can't just hang on to the transaction forever. If 5 hours pass and Bob hasn't broadcasted this transaction, Alice can go ahead and claim back her coin, because Bob obviously failed to forward the payment to Carol.

Because Alice gave Bob a timelock, he must get `R` from Carol within 5 hours. But ideally, Bob would have plenty of time to broadcast the transaction once he's learned `R`, because he may not get his transaction included in the blockchain right away. What if no blocks are mined for thirty minutes, or blocks are full and he has a hard time getting his transaction included? Bob needs some leeway between the time that he receives `R` and the time that his payment from Alice expires, so that he isn't racing against the clock to claim his 1 coin. So he sets a timelock of 1 hour, requiring Carol to basically broadcast the transaction immediately and reveal `R` to the world. If instead he were to use a timelock of 5 hours, Carol could wait until 4 hours and 30 minutes to broadcast the transaction that reveals `R`, at which point Bob would only have 30 minutes to get his transaction included in the blockchain.

<hr class="ellipses grey" />

Using the system described above, Alice can pay Carol without opening a payment channel on the blockchain. This is the system that the Lightning Network uses, and it has tremendous potential to make off-chain payments cheap and easy in Bitcoin. In the example above, we only have one "hop" between Alice and Carol (Bob is that hop), but we could easily have 3, 4, or 5 hops between Alice and Carol using the same logic. These types of transactions are called **Hashed Time Locked Contracts (HTLCs)**, because they use hashed secrets and timelocks to create a payment contract between parties.

But there's one catch: Recall that in this scheme, Carol has to broadcast the transaction that uses `R` to claim her 0.99 coins, and Bob has to broadcast the transaction that uses `R` to claim his 1 coin. If either of them fails to broadcast, they could lose their payment because of the timelock that allows the other party to reclaim the money. But broadcasting these transactions will cause Bob's channel with Alice and Carol's channel with Bob to close! A payment channel isn't all that useful if it has to be closed every time a party receives an HTLC. So let's briefly explore how Alice, Bob, and Carol can avoid needing to close the channels above.

# Revoking and Replacing HTLCs

Suppose that when Carol receives the HTLC giving her 0.99 coins from Bob, she sends Bob the value of `R`:

![carol gives bob r after getting the htlc]({{ site.baseurl }}/assets/images/understanding-lightning/carol-returns-r.png){: class='lazyload', style="max-height: 100px;"}
{: style="text-align: center;"}

At this point, Bob knows that Carol knows `R`, because she's revealed it to him. So two important things are true for Bob:
1. He can now claim his 1 coin from Alice
2. He knows that there's no way he's getting the 0.99 coins back that he sent to Carol, because she knows `R`, so she can go ahead and claim the money any time.

At this point, if Bob would like to keep his payment channel open with Carol, the two parties can simply revoke the HTLC transaction using the same revocation scheme we described in [part III]({{ site.baseurl }}/bitcoin/2020/09/18/understanding-lightning-3.html) of this series, and Bob can send Alice 0.99 coins in a new simple transaction where there's no timelock and no need for `R`. For simplicity, I didn't include the revocation logic, but it's exactly the same as in the previous post.

# Conclusion

At this point, you have a good start toward understanding how the Lightning Network can allow Bitcoin users to send each other money without using the Blockchain. As of the time of this post, Lightning is still in the experimental phase. There are issues, both known and unknown, that need to be resolved before the network is safe for regular use. A lot of innovation is coming on the horizon for Lightning (and Bitcoin in general) and now is an incredibly fun time to learn about the technology.

If you're interested in learning more about the technical side of Bitcoin and Lightning, MIT's [Cryptocurrency Engineering and Design course](https://ocw.mit.edu/courses/media-arts-and-sciences/mas-s62-cryptocurrency-engineering-and-design-spring-2018/) is a good starting point. The last draft of the [Lightning Whitepaper](https://lightning.network/lightning-network-paper.pdf) is a bit dated but well worth a read to understand the origins of the network. For a bit more of a technical deep-dive, check out the Lightning Network's [specification](https://github.com/lightningnetwork/lightning-rfc/blob/master/00-introduction.md).