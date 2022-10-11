********************************************************************************
Design 
********************************************************************************

Overview
---------
To achieve the goals of the project, I have created an extension to the Max audio-visual programming language called Scheme for Max (S4M). 
Scheme for Max embeds the s7 Scheme intepreter as a Max object, enabling users to run s7 Scheme programs within the Max environment.
User programs are able to interact with other Max objects and the larger Max environment in a variety of ways: 
they may receive Max messages which get interpreted as Scheme calls;
they can output Scheme data that become Max messages to other objects;
they can read from and write to globally accessible data such as Max dictionaries, tables, and buffers;
and they can interact with the Max scheduler, running Scheme functions at specific times and synchronizing with Max's own transport mechanism. 

Scheme for Max is released as open-source software under the BSD license, and the fourth release (v 0.4) is freely available as a download or source code from GitHub.
The project is extensively documented, with a comprehensive Max help patch, online documentation, a "Learn Scheme for Max" e-book, and a library of YouTube tutorial videos.

In the remainder of this section we will examine the various design decisions in detail, discussing why they were taken and how they have worked well to achieve the goals of the project.

Why a Max extension?
---------------------
Max is a visually programmed dataflow environment, in which the programmer places visual "objects" on a canvas, connecting them with "patching cables" along which messages and audio are passed between objects. 
Max is one of the most popular platforms world-wide for making computer music, with thousands of programming elements available from both Cycling 74 and the broader Max community.
These programming elements enable a wide variety of audio and visual manipulation, including the ability to interact with external hardware and to host commercial software synthesizers and effect plugins.

In existence in various forms since 1985, Max is currently developed by the software compay Cycling 74, owned since mid-2017 by another software company, Ableton, the makers of the commercial audio workstation and sequencing platform "Ableton Live".
In addition to being a popular and powerful platform on its own, Max is also available as "Max for Live", an embedded runtime within the Ableton Live commercial digital audio workstation and sequencing platform.
When run in this context, Max patches (as Max visual programs are known) are able to interact with Ableton Live, processing both audio and MIDI data, but also interacting with the host programming through an application programming interface (API), the Live API.

One of the notable features of Max is that, despite it not being an open-source product, the company provides a software development kit enabling users to develop extensions (called "externals") in C, C++, and Java, enabling users to add and share their own objects that work within the platform exactly as do the core objects.
This has led to the development of thousands of Max externals that extend Max in a tremendous variety of ways. 
These include audio DSP tools, sequencers, mathematical tools, machine learning extensions, graphic and video processors, tools for interacting with electronic hardware, control volt modular synthesizer extensions, and many more. 
Externals have access to Max through the Max SDK (software development kit) that enables them to interact with the rest of Max at a deep level, including reading and writing from shared data structures and interacting with the Max scheduler.
Ableton Live's API for Max is also extensive, providing Max patches the ability to control the Ableton program, read and write to Live's own sequences and audio clips, interact with the mixer and effects, and interact with the global transport.
Max for Live is included in the top-tier Ableton offering ("Live Suite") as well as an add-on to Live. 
Between the standalone Max version and Max for Live, Max has become the most widely deployed computer music programming platform worldwide (CITE).

Max supports two kinds of data passed between objects: audio and event, corresponding to different threads of execution.
In Max, there are actually two threads handling event messages, the "main thread" and the "scheduler thread".
The first is also referred to as the UI thread, or low-priority thread, and the second as the high-priority thread.
MIDI data, events from metronomes, and events from audio signals that have been turned into event messages (with various translation objects) all use the high-priority scheduler thread. 
Events from the user interacting with the GUI are run in the low priority thread, which is also used for redrawing any UI widgets.
A Max external can run in any or all of these contexts, and objects exists to pass events from one to the other.
Scheme for Max operates only in the two event oriented threads, receiving and producing only Max messages - it does not render blocks of samples as part of the DSP graph.
It can optionally run in either the low or high priority thread, but only one at a time.
The threading designs of Max and Scheme for Max make it possible for us to run Scheme for Max code only occasionally - on receipt of a message - but also to ensure that it runs at a high priorty and is not interrupted by low priority activity.

Thus, the choice of creating the project as an extension for Max supports several of the project's goals.

First, there is a clear distinction between event time and audio time, supporting the goal of focusing on the musical event (e.g. "note") time-scale, and there is a way for us to run in event time but with high temporal accuracy.
By running only at the event time scale, we are afforded the option to use a high-level, garbage collected language.
Were we forced to implement audio time processing as well as event time processing, we would likely be calculating floating point math at a rate reaching that where lower level languages (e.g. C, C++, Rust, etc.) become a major advantage, and where a garbage collected language becomes problematic when it pauses for gargbage collection.
(Issues around garbage collection will be examined in more detail in subsequent sections).

Second, using Max supports the goal of being able to use the tool in conjunction with modern commercial music tools.
Max runs inside Ableton Live, and Max can host commercial VST plugins. 
When run in Ableton Live, Max uses Live's own transport, and when run as a VST host, Max's transport is visible to the VST plugins.

Third, using Max supports the goal of being usable for real-time interaction and live performance. 
The Max clocking facilities are highly accurate, with jitter being typically in the 0.5-1ms range if using a typical signal vector size of 32 or 64 samples. 
(Signal vector size is user configurable in standalone Max, and is locked to 64 in Ableton Live.)
Timing jitter is self-correcting, with the clocks maintaining long-term accuracy (i.e. the inaccuracy does not accumulate).


Taken together, these three points makes Max an attractive host platform for the project. 
We are able to create music that is implemented in some mix of Scheme, standard Max programming, and in sequencing from Ableton Live.
We can use modern commercial audio sources, taking advantage of the dramatic advances in software synthesis in recent years.
And timing is reliable and accurate enough that we can use the tool on stage, or in the studio for commercial production of music where high timing accuracy is desired (e.g. electronic dance music).
We can even, through Ableton Live, use the tool during the mixing and mastering processes, as all of this can be done in Live, with Scheme for Max used to orchestrate and automate Live devices and VST plugins.


Given the decision to build a Max extension, the advantages just discussed could be applied to any programming language hosted in a Max external.
Which begs the question, why use a Lisp language rather than something more common such as Python, Ruby, JavaScript, or Lua? 
In fact, were we satified with using JavaScript, we could simply use the existing JavaScript object (a.k.a. "js") that comes with Max!

Why not just use JavaScript?
-------------------------------------------------------------------------------
We will discuss in some depth the linguistic reasons for choosing a a Lisp language, but first let's look at the reasons we can't simply use the JS object to satisfy our goals. 
At first glance, the JS objects seems to provide what we need.
It runs in Max, it can send and receive Max messages, t has access to Max externals, it has a scheduler facility (the Task objects), and it's a high-level language with some modern features such as dictionaries and lexical scoping!
Unfortunately, the js object has a serious implementation issue - it is only available in the lower priority thread.
It is not clear why this is so, and indeed in previous versions (TODO version?) of Max it was possible to run in both threads. 
However, this has been the case since at least Max 7 (TODO date).
Any messages sent to the js object from the scheduler thread are implicity queued to the UI thread and handled on the next pass of the UI thread.
The result of this is that timing in the JS thread is not reliable - depending on other activity, execution of messages can be delayed, with this delay large enough to be audibly noticeable as errors.
In addition, the JS object provides us with no way to interact directly with the garbage collector (GC). 
As a result, we have no control over when or for how long the GC may run, potentially also creating audibly late events when it does.

In fact, I did indeed begin my work combining textual programming with commercial environments by attempting to use JavaScript in Max, and overcoming the timing limitations of the JS object is one of the main motivations for the Scheme for Max project.

Why use a Lisp language?
--------------------------------------------------------------------------------
Having decided to tackle embedding a textual language in Max, we can now ask why choose a Lisp family language.
(For the purposes of this dicussion I will use "Lisp" to refer to the family of related languages that share the traits we will examine, including Scheme, Common Lisp, and Clojure.)

In the initial research stage of this project (dating back to 2019) I examined options from numerous high-level languages, and reviewed the use of many possible languages in music.
Non-Lisp candidates included Python, Lua, Ruby, Erlang, Haskell, OCaml, and JavaScript (i.e. in a new implementation), all of which have been used for music projects of different types.

We will examine three categories of advantages: those relating to representing music, those related to the workflow tradeoffs for the programming composer, and those relating to implementation in Max specifically.

Lisp as a programming language for music
----------------------------------------
Lisps are unusual  in several ways (compared to the candidate languages mentioned) that make them almost uniquely suited to representing music.
(To be clear, some of these traits are shared by some of the other candidates, but none of the candidates share all of these traits with Lisps!)

Symbolic computation and list processing 
----------------------------------------
One could make a strong case that the defining characteristic of Lisp is that it is a language for symbolic computation in which the list structure and list processing are not just central to the language, but are the syntax *of the language itself*. 
Indeed the very name, Lisp, originally came from "list processor".
In Lisp, the symbol is a data type, represented normally with a leading single quote to indicate we are referring to the symbol itself rather than a variable name.
In a Lisp program, we may have a variable named foo, but we also work with the *symbol* 'foo. 
We have the option of *quoting*, (the single quote) meaning we are asking the interpreter (or technically the compiler, but for the sake of discussion we will assume interpreter) to sskip evaluating the symbol into the contents stored at the memory location.
In addition to this, Lisp syntax is entirely composed of s-expressions: paranthetical expressions containing lists of symbols and primitives.
All of these are lists of symbols: 

.. code: lisp
  ; 3 ways of creating a list containing the symbols foo and bar and the primitive 1
  (quote (foo bar 1))
  (list 'foo 'bar 1)
  '(foo bar 1)

However, if we remove the quoting, the syntax ``(foo bar 1)`` becomes a line of code that executes the function bound to the symbol foo, passing it the value stored at bar and the value 1 as arguments.
The impact of this is difficult to overstate.
Lisp allows us to trivially make programs that build lists of symbols and primitives, *and these lists themselves can be executed as programs*.

This process is often referred to as dynamic evaluation, and it is not only supported by Lisp.
We can also build a program in our program in other high level languages, including Python, Ruby, Lua, and JavaScript.
However, in all of these, the way this is done is to build a string of code, and pass that to an evaluator, or to use variety of helper functions.
In none of these is programming *on* the symbolic tokens of the language directly supported the way it is in Lisp.
The result is that in these other language it is cumbersome, and regarded as something to be used sparingly.

In Lisp, on the other hand, manipulating lists of symbols, and later evaluating them as functions, is the very stuff of which the langauge is made.
Now, how does this matter?
Like Lisp, music is heavily concerned with the notions of symbols, and even lists of symbols, representing functions, relationships, and events.

What is the notion of a "chord progression" other than an abstration of a series of symbols representing functional relationships between lower levels of abstracted data?
If I present you a progression of "I-vi-ii-V7", what does this mean?
We have a *list* of four items, each denoted by a symbol: "I", "vi", "ii", "V7".
Each of these symbols represents musical data for a given chord, but by themselves, they don't represent *music* - they need a key *to which the function represented by the chord symbol can be applied*.
Indeed, "I" must be a *function* - it is a description of something we get when we apply an algorithm to a parameter - namely the tonic key.

In a Lisp language, this can be represented in code that is almost identical to what we would use in musical analysis. 
``(chords->notes 'C '(I vi ii V7))`` is a perfectly legitimate line of Lisp syntax that could be a function to render into the chord progression given with the tonic as C.
It could be implemented to return something that looks very familiar to a musicain and on which more of the program can work, such as nested list containing sublits, each containing symbols:
``'( (C E G) (A C E) (D F A) (G B D F))``

Further, because this form of symbolic computation is so central to the language (one of the classic texts is even subtitled "A Gentle Introduction to Symbolic Computation"), Lisps include a myriad of functions for easily manipulating the list. 
For example, we might transpose a list by applying a transposing function, which might be built by a function building function called "make-transpose", applying it to symbols. 
This sounds complicated, and indeed, expressing this in languages with Algo derrived syntax is non-trivial, but in a Lisp this is readable and succint:

.. code: scheme
  ; apply a transposition function that transposes up 2 to all elements in our chord progression
  (map (make-transposer 2) 
    '( (C E G) (A C E) (D F A) (G B D F)))
  ; expressed without first expanding our chord progression
  (map (make-transposer 2)
    (chords->notes 'C '(I vi ii V7)))


 
