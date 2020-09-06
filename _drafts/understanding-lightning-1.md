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

This means that if I want to send someone money, I need to

1. Have gotten some Bitcoin to spend via one of these transactions in the global database
2. Create another transaction to send someone else that money, and get that transaction into the global database