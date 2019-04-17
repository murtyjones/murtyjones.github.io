# Working with reasonable limits
## EDGAR's 10 requests-per-second limit
I'm building a project based entirely around data that the SEC makes available on [EDGAR](https://www.sec.gov/edgar/searchedgar/companysearch.html). This is great, because access to the data is free!

However, as with many free things, that freedom is a privilege; in this case, it's a privilege that the SEC reserves the right to revoke.

Why might the SEC revoke your access to its system? Good question! In fact, the SEC has a [Fair Access](https://www.sec.gov/developer) policy detailing what reasonable use of the platform looks like:
> To ensure that everyone has equitable access to SEC EDGAR content, please use efficient scripting, downloading only what you need and please moderate requests to minimize server load. Current guidelines limit each user to a total of **no more than 10 requests per second**, regardless of the number of machines used to submit requests.

...and the the penalties for violating the request-per-second guidelines:

> To ensure that SEC.gov remains available to all users, we reserve the right to block IP addresses that submit excessive requests.

## What does this mean for birb?
For the project I'm building, [`birb`](https://github.com/murtyjones/birb), 10 requests per second ought to be sufficient. 10 requests per second translates to ~800,000 requests per day, which is pretty generous.

The main concern I have is how to ensure that I build a system that honors the 10 requests-per-second guideline. The collection of data will be done asynchronously, and I had initially imagined that it would look something like this:
```
      ————————————————       ————————————————
      | EDGAR Task A |       | EDGAR Task B |
      |    Queuer    |       |    Queuer    |
      ————————————————       ————————————————
             |                      |
             |                      |
             V                      V
      ————————————————       ————————————————
      | EDGAR Task A |       | EDGAR Task B |
      |    Queue     |       |    Queue     |
      ————————————————       ————————————————
             |                      |
             |                      |
             V                      V
      ————————————————       ————————————————
      | EDGAR Task A |       | EDGAR Task B |
      |    Worker    |       |    Worker    |
      ————————————————       ————————————————
                   Λ           Λ
                   |           |
                   V           V
                 —————————————————
                 |     EDGAR     |
                 —————————————————
```
The problem with the above system design is that workers A and B can't easily coordinate a 10-request-per-second throttle. I could limit each of them to 5 requests per second, but that doesn't scale when I add a new task.

Instead, here's the architecture I'm considering:
```
      ————————————————       ————————————————
      | EDGAR Task A |       | EDGAR Task B |
      |    Queuer    |       |    Queuer    |
      ————————————————       ————————————————
                   |           |
                   |           |
                   V           V
                 —————————————————
                 |  EDGAR Tasks  |
                 |     Queue     |
                 —————————————————
                         |
                         |
                         V
                 —————————————————
                 |  EDGAR Tasks  |
                 |     Worker    |
                 —————————————————
                         Λ
                         |
                         V
                 —————————————————
                 |     EDGAR     |
                 —————————————————
```

Limiting the `EDGAR Tasks Worker` to 10 requests per second should be trivial.

This does complicate queueing/dequeueing logic, because some tasks have more import than others, so I will probably need to explore attaching some a priority ranking to a given task so that the `EDGAR Tasks Worker` knows which tasks to tackle first.