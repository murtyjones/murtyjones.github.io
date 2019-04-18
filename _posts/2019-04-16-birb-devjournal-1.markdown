---
layout: post
title:  "birb.io – devjournal #1"
date:   2019-04-16 6:56:24 -0400
categories: [birb]
tags: [rust]
---

# building an API to scrape public financial data

## why:
I've had a side project in mind for a while:
A web API that organizes financial data from publicly available SEC filings.

This is a great side project for me because:
1. I would use it. Always nice to work on something that would benefit yourself.
2. Others would use it (as long as it's correct). Extracting data from SEC filings is notoriously manual, and the numbers need to be correct 100% of the time. Building an API that produces correct numbers 100% of the time is a challenging technical problem but one where the solution is bound to be useful to people who rely on it.
3. The technical challenges that I've chosen for this project are novel for me:
    - Exposing an API in a new language (in this case, [Rust](https://rust-lang.org))
    - Automating the deployment of [AWS](https://aws.amazon.com) infrastructure using [Terraform](https://terraform.io)
    - Asynchronous jobs to retrieve and normalize the financial data
    - Since this is an API-first product, a focus on organizing the data to be client-agnostic, which is a completely novel technical challenge for me.

## what:
### what I've done so far:
So far, here's what I've accomplished:
1. Organized a basic Rust project using a variation of the [multi-crate structure](https://users.rust-lang.org/t/what-is-the-idiomatic-way-to-manage-a-project-with-multiple-crates/6683) that folks tend to use for large Rust projects.
2. Built a basic working REST API using Rust + [Rocket](https://rocket.rs) 🚀
3. Deployed *most* of the infrastructure to AWS using Terraform. There are some nuances around [Fargate](https://aws.amazon.com/fargate/) that I'm still working through (setting up environment variables, using [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/)), but overall Terraform has made it an absolute breeze to set up and tear down dozens of resources in AWS within a couple of seconds. Game changer!

### what's next:
- Right now I'm working on a sub-crate that I'm calling [`filer-status`](https://github.com/murtyjones/birb/tree/master/crates/filer-status). The goal of it is to scrape [sec.gov](sec.gov) for a given entity and store a `boolean` in the birb datastore when it discovers whether or not the entity is an active filer or not. Dig into the [`README`](https://github.com/murtyjones/birb/blob/master/crates/filer-status/README.md) for more details!
- Once that's done, I will probably revisit getting my infrastructure set up so that I can run `filter-status` in production and work out the process of setting up job/queues/workers in AWS. So pumped to learn about setting up this process as I've never done it and I'm curious to optimize for 1. fault tolerance, and 2. monitoring/debugging.

## how:
You can see how I'm progressing by visiting the repository [on GitHub](https://github.com/murtyjones/birb).