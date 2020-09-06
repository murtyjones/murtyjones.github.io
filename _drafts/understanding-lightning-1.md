---
layout: post
title:  "Understanding Bitcoin's Lightning Network - Part I"
date:   2020-09-6 8:13:00 -0400
categories: [bitcoin]
tags: [bitcoin]
---

# What are "payment channels" in Bitcoin?

The concept of a *payment channel* has been around since the early days of Bitcoin. The Bitcoin creator even attempted to implement payment channels in Bitcoin's first version. This implementation was hopelessly broken, and ever since then a great number of people have been trying to figure out how to create payment channels in Bitcoin. The *Lightning Network*, which has been up and running since early 2018, is the most famous iteration of payment channels in Bitcoin, and took several years of iteration before being ready for development.

But what is a payment channel, and why is it needed?

# Bitcoin's transaction model

All that Bitcoin is, ultimately, is a shared database of transactions that people use to give each other money. A bunch of computers around the world download the same shared database, and all of those computers are all able agree on who has what money using that database.

This means that if I want to send someone money, I need to:

1. Have gotten some Bitcoin to spend via one of these transactions in the global database
2. Create another transaction to send someone else some money, and get that transaction included in the global database

The Bitcoin database gets transactions added to it when a miner mines a new "block", which is really just a message that conforms to some rules that all Bitcoin nodes know to look for. That message tells the Bitcoin network "Hey, here are some transactions that I want to add to the database." So if I want my transaction to be executed, I have to convince miners to do that whenever they publish a new block.

Sounds like I just need to send miners my transaction, and include a small fee to incentivize them to include it. But there's a catch! Remember the "rules" I mentioned above, that miners' blocks must follow to be accepted by other Bitcoin nodes? Well, one of those rules is that each block cannot be larger than 1 megabyte in size. Since including my transaction takes up space in a block, it means that I may have to compete with other people who are transacting on Bitcoin to get their transactions included in the Bitcoin database. Additionally, new blocks are only published, on average, every 10 minutes (this by design, although how it works is a little bit complicated and beyond the scope of this post).

These two constraints of Bitcoin, 1. The limited block size and 2. The block-mining rate of every 10 minutes, are both critically-important pieces of the Bitcoin system. I'm not going to dig into why they're important in this series, but they are important for Bitcoin to keep its promise of being a decentralized currency that anyone can use.

But these rules create a constraint on the system - there is a cap on the number of transactions that can be included in a block. Since different transactions have different sizes, this cap isn't exact, but right now it's somewhere around 2,500 transactions per block.

# How Bitcoin stacks up to other payment system

If we take a couple of the numbers above, 2,500 transactions per block and 10 minutes per block, we can calculate the Bitcoin system's number of transactions per second at about *4 per second*. Again, this isn't exact, but it gives us a sense of Bitcoin's transaction capability.