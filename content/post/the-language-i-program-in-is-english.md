+++
title = "The Language I Program in is English"
date = 2025-08-08T22:01:25-04:00
+++
I've been spending a lot of time with Cursor lately, and it has been an
enlightening experience. The introduction of LLM-powered code assistants in the
most significant change to software engineering I have ever seen in my career
to date. I imagine this must be similar to what it was like when C was first
introduced; that new language allowed developers to express their software
is a much more natural format than other languages of the day.

Using Cursor's code assistant, I now can write software using English instead
of Python or Swift or Rust, etc. The language my software gets rendered in
still has the classic syntactic strictness necessary to be interpreted by a CPU
instruction set, but the language it gets written in is *far* more natural than
it ever was before.

Now I can write a data structure by describing it: "Create an OpenAI API
client that uses AsyncHTTPClient from the Swift NIO project. Include a suite
of unit tests using the Swift Testing framework. The client must be compatible
with other providers and not restricted to api.openai.com exclusively." This
description gets turned into a fully functional class, test suite, and sample
usage.

Of course, I still have to be able to *read* the output, understand it, and own
it as if it were my own product. Coding assistants cannot take responsibility
for the code they write; that responsibility remains with the human who
instructed the assistant. Now, the decision to write a project in Python, or
Rust, or Swift, or Go comes down to features and functionality offered by the
programming environment, and not just "what language am I most familiar with
right now".
