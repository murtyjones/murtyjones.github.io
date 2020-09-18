---
layout: post
title:  "Understanding Bitcoin's Lightning Network - Part I"
date:   2020-09-06 10:11:00 -0400
categories: [bitcoin]
tags: [bitcoin]
---

# What are "payment channels" in Bitcoin?

The concept of a *payment channel* has been around since the early days of Bitcoin. The Bitcoin creator even attempted to implement payment channels in Bitcoin's first version. This implementation was hopelessly broken, and ever since then people have been trying to figure out how to create payment channels in Bitcoin. The *Lightning Network*, which has been up and running since early 2018, is the most well-known payment channel network in Bitcoin, and took several years of iteration before being ready for development.

But what is a payment channel, and why is it needed? In this post you'll get an understanding of why a payment channel might be useful for Bitcoin users, and what a payment channel is.

# Bitcoin's transaction model

Bitcoin is, ultimately, a shared database of transactions that people use to give each other money. A bunch of computers around the world download the same shared database (known as the blockchain), and all of those computers are all able agree on who has what money using that database.

This means that if I want to send someone money, I need to:

1. Have gotten some Bitcoin to spend via one of these transactions in the global database
2. Create another transaction to send someone else some money, and get that transaction included in the global database

The Bitcoin database gets transactions added to it when a miner mines a new "block", which is really just a message that conforms to some rules that all Bitcoin nodes know to look for. That message tells the Bitcoin network "Hey, here are some transactions that I want to add to the global database." So if I want my transaction to be executed, I have to give it to miners, and convince them to include it whenever they publish a new block.

Sounds like I just need to send miners my transaction, and include a small fee to incentivize them to include it. But there's a catch! Remember the "rules" I mentioned above, that miners must follow to have their blocks accepted by other Bitcoin nodes? One of those rules is that each block cannot be larger than 1 megabyte in size. Since including my transaction takes up space in a block, it means that **I may have to compete with other people who are also trying to get their own transactions included in the Bitcoin database via a mined block**. Additionally, new blocks are only published, on average, every 10 minutes. So if my transaction is time-sensitive, I have to compete to get it included in a block sooner rather than later.

These two constraints of Bitcoin, 1. The limited block size and 2. The block-mining rate of every 10 minutes, are both critically-important pieces of the Bitcoin system. I'm not going to dig into why they're important in this series or how exactly those rules are enforced, but they are important for Bitcoin to keep its promise of being a decentralized currency that anyone can use. These rules create a constraint on the system - there is a cap on the number of transactions that can be included in a block. Since different transactions have different sizes, this cap isn't exact, but right now it's somewhere around 2,500 transactions per block.

Clearly this creates a system where a person wanting to transact may have to out-compete others by including a large enough fee for the miner to guarantee that their transaction is included in the blockchain. But how large of a fee? That depends on how many people want to use the Bitcoin payment system (demand), and how many transactions the Bitcoin payment system can handle (supply).

# How Bitcoin stacks up to other payment systems

If we take a couple of the numbers above, 2,500 transactions per block and 10 minutes per block, we can calculate the Bitcoin system's number of transactions per second at about *4 per second*. Again, this isn't exact, but it gives us a sense of Bitcoin's transaction capability. Visa, one of the world's largest payment companies, can process up to **65,000** payments per second!

Looking at these numbers, there's a clear problem: *What happens if everyone in the world wants to use Bitcoin?*

Clearly, it's not an option for everyone in the world to use the Bitcoin network for every single transaction. There simply isn't enough space. What will happen instead is that, as more people use Bitcoin, it will become extremely expensive to do so. Users will have to include exorbitant fees to get transactions included in the blockchain. In fact, we saw a preview of this kind of thing in late 2017, when there was a lot of transaction congestion on the Bitcoin network that pushed transaction fees in the range of $5 - $10.

Clearly, if we want Bitcoin to be used by everyone around the world for buying their morning coffee, we have to find a better way to allow everyone to transact.

There are a couple of ways we could do this:
1. Increase Bitcoin's capacity (IE increase the block size beyond 1MB, or increase the rate of block mining so that it happens more quickly than every 10 minutes)
2. Give people a way to transact *without* using the Bitcoin network directly

Option #1 is interesting and could be the subject of its own post. But option #2 will ultimately be needed for Bitcoin's success.

# Transacting without the Bitcoin network

Imagine that I want to buy something from you using Bitcoin, but the network is really congested by a lot of transactions, and neither of us wants to pay the transaction fee. How could I give you my Bitcoin without sending you a transaction on the Bitcoin network? Is it even possible?

Well, turns out that it's totally possible. Assume that I have 1 BTC at the address `15mVffbe2bGw9z1c15Wu5fKqc3X6kXshmD`. The way that I can spend that 1 BTC is by creating a new transaction that proves that I know a "secret." Specifically that I know the secret number, `X`, that was used to create the address above. Every Bitcoin node can easily see whether `X` was used to create the address `15mVffbe2bGw9z1c15Wu5fKqc3X6kXshmD`, and validate my transaction. In theory, then, I could just tell you `X` and you could use `X` to spend the Bitcoin at the address `15mVffbe2bGw9z1c15Wu5fKqc3X6kXshmD` whenever you want to. In this way, we wouldn't have to broadcast our transaction and pay a fee to the Bitcoin miners to include it in the blockchain.

There are two obvious problems with transacting this way:
1. What if I have 2 BTC at the address `15mVffbe2bGw9z1c15Wu5fKqc3X6kXshmD`, but I only want to send you 1 BTC? By revealing `X` to you, I give you the ability to spend my 2 BTC, which isn't what I want to do.
2. Assume that I have 1 BTC at address `15mVffbe2bGw9z1c15Wu5fKqc3X6kXshmD`, and I want to send you 1 BTC. If I give `X` to you, you can now spend the coin at that address whenever you want to. The problem for you is that I can too! I still have `X`, so there's nothing to stop me from stealing back that money later on by creating a new transaction using `X` and sending the coin to a different address I control.

If you and I trust each other, we can get around these problems. But what if we don't know one another, or we don't want to trust one another? What we really need is a way to **send each other any amount(s) of Bitcoin, over any time period, without using the blockchain, while guaranteeing to one another that neither of us will try to cheat the other**. This is the concept of a payment channel.

The payment channel I described above allows us to avoid using the blockchain, but is 1. not very useful (because I can't send you any amount of Bitcoin), and 2. not trustless because you have to trust that I won't cheat you out of the coins after we're done transacting.

In the **[next post]({{ site.baseurl }}/bitcoin/2020/09/13/understanding-lightning-2.html)** of this series, I'll dive further into a better construction of payment channels that allows us to solve some of the problems above.
