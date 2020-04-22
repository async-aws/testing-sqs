# Testing SQS

Fake SQS is a lightweight server that mocks the Amazon SQS API in a Docker container.

This project is merge of:
- [fake_sqs](https://github.com/iain/fake_sqs) (forked)
- [docker-fake-sqs](https://github.com/feathj/docker-fake-sqs)
- unmerged PR:
-  - https://github.com/iain/fake_sqs/pull/59

## Usage

```cli
docker run -rm -p 9494:9494 asyncaws/testing-sqs
```
