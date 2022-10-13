********************************************************************************
Design 
********************************************************************************

.. notes
  needs a conclusion to the section

Overview
================================================================================
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
================================================================================
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
================================================================================
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
================================================================================
Having decided to tackle embedding a textual language in Max, we can now ask why choose Scheme, a Lisp family language.
For the purposes of this dicussion I will use "Lisp" when referring to traits shared across the Lisp family of languages (including Scheme, Common Lisp, and Clojure, Racket), and Scheme when referring to the particular choice used in Scheme for Max.

In the initial research stage of this project (dating back to 2019) I examined options from numerous high-level languages, and reviewed the use of many possible languages in music.
Non-Lisp candidates included Python, Lua, Ruby, Erlang, Haskell, OCaml, and JavaScript (i.e. in a new implementation), all of which have been used for music projects of different types.

We will examine various advantage for the user of working in Lisp, relating to representing music, to the workflow tradeoffs for the programming composer, and to implementation in Max specifically.

Lisps are unusual  in several ways (compared to the candidate languages mentioned) that make them almost uniquely suited to representing music.
(To be clear, some of these traits are shared by some of the other candidates, but none of the candidates share all of these traits with Lisps!)

Symbolic computation and list processing 
----------------------------------------
One could make a strong case that the defining characteristic of Lisp is that it is a language for symbolic computation in which the list structure and list processing are not just central to the language, but are the syntax *of the language itself*. 
Indeed the very name, Lisp, originally came from "list processor".
In Lisp, the symbol is a data type, represented commonly with a leading single quote to indicate we are referring to the symbol itself rather than a variable name.
In a Lisp program, we may have a variable named foo, but we also work with the *symbol* 'foo. 
We have the option of *quoting*, (the single quote) meaning we are asking the interpreter (or technically the compiler, but for the sake of discussion we will assume interpreter) to skip evaluating the symbol into the contents stored at the memory location.
In addition to this, Lisp syntax is entirely composed of s-expressions: parenthetical expressions containing lists of symbols and primitives.
All of these are lists of symbols: 

.. code: lisp
  ; 3 ways of creating a list containing the symbols foo and bar and the primitive 1
  (quote (foo bar 1))
  (list 'foo 'bar 1)
  '(foo bar 1)

However, if we remove the quoting, the syntax ``(foo bar 1)`` becomes a line of code that executes the function bound to the symbol foo, passing it the value stored at bar and the value 1 as arguments.
The impact of this is difficult to overstate.
Lisp allows us to clearly and succinctly make programs that build lists of symbols and primitives, *and these lists themselves can be executed as programs*.

This process is often referred to as dynamic evaluation, and, to be clear, it is not only supported by Lisp.
We can also build a program in a program in other high level languages, including Python, Ruby, Lua, and JavaScript.
However, in all of these, the principal way this is done is to build up a string of code (a messy process at the best of times), and pass this to an evaluator.
In none of these lanugages is programming *on* the symbolic tokens of the language directly supported the way it is in Lisp.
The result is that in these other language it is cumbersome, and regarded as something to be used sparingly.

In Lisp, on the other hand, manipulating lists of symbols, and later evaluating them as functions, is the very stuff of which the langauge is made.
Now, why does this matter for a prgramming language for music?
Like Lisp, music is heavily concerned with the notions of symbols, and even lists of symbols, which can representing functions, relationships, and events.

For example, one could argue that the notion of a "chord progression" other than an abstration of a series of symbols representing functional relationships between lower levels of abstracted data (the notes).
If I present you a progression of "I-vi-ii-V7", what does this mean?
We have a *list* of four items, each denoted by a symbol: "I", "vi", "ii", "V7".
Each of these symbols represents musical data for a given chord, but by themselves, they don't represent *music* - they need a key *to which the function represented by the chord symbol can be applied*.
Indeed, "I" must be a *function* - it is a description of something we get when we apply an algorithm to a parameter - namely the tonic key.

In a Lisp language, this can be represented in code that is visually compatible (almost identical even!) to what we would use in musical analysis. 
``(chords->notes 'C '(I vi ii V7))`` is a perfectly legitimate line of Lisp syntax that could be a function to render from a chord progression into a list of notes given a tonic of C.
It could be implemented to return something that looks very familiar to a musician and on which more of the program can work. 
A potential return value could be represented by the interactive Lisp interpreter as a nested list containing sublists of symbols:
``'( (C E G) (A C E) (D F A) (G B D F))``

Further, because this form of symbolic computation is so central to the language (one of the classic texts is even subtitled "A Gentle Introduction to Symbolic Computation"), Lisps include a large corpus of functions for manipulating and transforming lists. 
For example, we might transpose a list by applying a transposing function, which itself might be built by a function-building function called "make-transposer", and we might apply this function to a list of symbols. 
This sounds complicated, and indeed, expressing this in most languages is non-trivial, but in a Lisp this is both readable and succint:

.. code: scheme
  ; apply a transposition function that transposes up 2 to all elements in our chord progression
  ; the map function maps a function over a list, returning a new list
  (map (make-transposer 2) 
    '( (C E G) (A C E) (D F A) (G B D F)))

  ; expressed without first expanding our chord progression
  (map (make-transposer 2)
    (chords->notes 'C '(I vi ii V7)))

This compatibility between the expression of musical data and relationships and the syntax of the Lisp langauges has led to a rich history of Lisp use in musical programming - where musical programming refers to manipulations of abstractions of musical events and data rather than rendering streams of audio samples.
Examples of Lisp based musical programming environments, both historical and current, include Common Music, Nyquist, Common Lisp Music, MIDI-Lisp, PatchWork, OpenMusic, Extempore, Slippery Chicken, the Bach Prroject, MozLib, and cl-collider.

The results of this compatibility between Lisp and music are several and of major import:

* We have access to a rich historical body of prior work, with code that can be ported to Scheme for Max relatively easily 
* Code representing musical data can be more succint, lower the sheer amount of code the composer must contend with while working
* Code that represents functions applied to musical data is not so visually different from code representing note data, and thus
  the act of moving from working on code to working on musical data is simpler

The last point applies beyond music, and has even given rise to a common saying within the Lisp programming community, that 
"code is data, data is code". This trait is referred to in the programming lanugage theory (PLT) community as "homoiconicity", a term to which we will be returning quite a bit.

Dynamic code loading and the REPL 
----------------------------------------------
A result of the Lisp is designed, with evaluation of new code a key part of the lanuage, is that the common programming workflow in Lisp incorporates an ongoing process of evaluating new code into the interpreter and examining the interpreter's output, while the program runs. 
This style of interactive development is sometimes called REPL-oriented or REPL-driven programming, where REPL refers to the intepreters Read Evaluat Print Loop.
At any point, the programmer can send new expressions to the Lisp interpreter (the "read"), which *evaluates* the expressions, updating the state of the Lisp environment, and then *prints* the return value of evaluating the expressions. 
The programmer can use Lisp code itself to inspect the current environment, or even to build new functions and expressions to evaluate.

This is closely related to Lisps *macro* facility - a Lisp macro is a block of code that is evaluated (the macro call) and returns new code (the macro expansion) that is then in turn evaluated.  

These facilities - dynamic code evaluation, the REPL, and Lisp macros - are what make Lisp a "highly dynamic" lanuage.
Taken together they create possibilities for the composer-programmer that are highly productive and are appropriate to the context of a composer programmer and the needs of the algorthmic music maker.

For example, the programmer can separate code into files that contain score data and files that contain functions for altering or creating music, where the functions might be musical transformations of algorithms for generating new content given base score data.
The files of functions can be incrementally adjusted and reloaded with new definitions without restarting the piece or resetting the score data.
In Scheme for Max, this is supported with the "read" message, which reads a new file into the interpreter without erasing anything currently running.

This can also be done from text user interface objects in the patch, including the s4m.repl object, which contains a small text window for typing expressions directly in the patch and sending them to the interpreter. 
And it can even be done from an external text editor, with the editor and a helper program sending selected blocks of code over the local network as OSC (Open Sound Control) messages into Max, where they are then sent on to the interpreter.
Max itself has a console window to show messages from the Max system, and this is used for the Print stage of the REPL loop so that the results of dynamic evaluation can be easily read by the programmer.

.. todo
  do I need the next paragraph??

In the larger community of software development, it is somewhat of a truism that highly-dynamic languages are ideal for small teams and smaller programs, but that as code bases and teams become larger, the possibility of someone redefining a function on the fly becomes a double edged sword. (CITE, EXAMPLE).
However, the typical composer-programmer is, I would argue, in the sweet spot for this kind of development. 


Macros and Domain Specific Languages
-------------------------------------
One of the hallmarks of Lisp is the Lisp Macro.
We have previous discussed the ease with which the Lisp programmer can programmatically create lists of symbols that are then evaluated as syntactic Lisp expressions - code that makes code - a Lisp macro is a formalization of this process. 
Macros look to the programmer much like a regular function call, but by virtue of being defined as a macro, they are first called in a special evaluation pass known as the macro-expansion pass.
This runs the code in the body of the macro over the *symbolic arguments* passed in to it, returning a programmatically created list structure (the macro-expansion) that is then immediately evaluated. 
Essentially, macros are code blocks that execute twice - first to build the code, then to evaluate it. (Technically they can be nested to repeat the first step.)

Macros enable programmers to create Domain Specific Languages - languages within a language that are closer in syntax and sematics to the problem domain than to the host langauge. 
This makes it possible for code that uses the macros (the "domain code") to be visually aligned with the problem domain, making them easier to read and faster to type. 
For example, a macro for scheduling events in a score can look like the below:

.. code: lisp
  (score 
    1:1       (fun-1 fun-2 fun-3)
    +8        (fun-4 :dur 1b :repeat 4)
    9:1:120   action-4
   )

The time argument, ``1:1:120``, ``+8``, and ``9:1:120`` are written as if they will passed in as symbol arguments, but the macro layer converts them into musically meaningful time representations, allowing the visual representation in code of the score to be more easily read by the composer.
But to clarify, this is *not* a separate score language with limited functionality, as is found in, for example, Csound.
This *is Scheme code* - it can include any Scheme functions and even be built by Scheme functions. 
Thus the use of a language with Macro facilities enables the composer to work with different kinds of code - function defining code and score code - in one language without giving up the expressive power of high level language facilities.

Max and Lisp syntax compability
-------------------------------
Finally, there is the fortunate coincidence of the Max message syntax being almost perfectly compatible with Lisp syntax.
This happy accident (we can assume!) means that a user can create and run Scheme code in Max messages themselves, using Max message building functions to do so.
While not something I was expecting when originally embarking on the design, this has a profound effect on the ease with which one can build Max patches that interact with Scheme for Max programs.

A Max message consists of Max *atoms*, which may be integers, floating point numbers, and are separated by spaces. 
It may also consist of several special characters: the dollar sign, the comma, and the semi-colon.
When a message box sends a message to another message, a numeric dollar sign argument such as "$1" is used to interpolate the numbered argument from the received message, acting as a template.
The semi-colon indicates the message is a special message sent to the Max engine itself.
And the comma is used to indicate that the message is actually two message, with the two comma-separated halves being sent sequentially.

Notably, the parenthesis, used in Lisp to delimit Lisp expressions, and the colon, used to indicate that a symbol should be a keyword (a special kind of symbol), have no special significance to Max.
Conversely, the dollar sign has no significance in Lisp, and the semi-colon (used for comment characters) and the comma (used for back-quote escaping) are easily
avoided.

The result of this is that rather than require the programmer to create special handlers in their code to respond to Max messages, as one does in the JS object, we are able to simply evaluate in coming messages *as if they were Lisp code*.
To simplify this, Scheme has one special trick - it will pretend an incoming expression is surrounded by parentheses if they are not there.
It will also accept message with parentheses, including nested parentheses, processing these as Scheme code.
In (FIGURE) we see several Max messages acting as Lisp code.

This makes connecting Max input elements to a Scheme for Max program simple, and means that the containing patch can, if desired, provide a visual reminder of exactly what is going on in the Scheme program.

Having built some complex programs myself in JavaScript in Max prior to building Scheme for Max, I am of the opinion that this is a significant advantage of the language choice.


Why use s7 Scheme?
==================
When beginning the project, after determining that a Lisp-family language was appopriate, I evaluated a number of Scheme and Lisp implementations as candidates.
Let us know look at why the s7 implementation in particular was chosen.

Computer Music use
------------------
s7 was created and is maintained by Bill S., a professor emeritus from the Stanford music centre (CCRMA), and  the author of Common Lisp Music and the Snd editor. 
It's principle uses are in Bill S's Snd editor, essentially an Emacs-like audio editing tool, and in Common Music 3, the algorithmic composition platform created by Henrik Taube.
Because of this pedigree, the design drivers for s7 are compatible with Scheme for Max, with the author choosing that which makes sense for composer-programmers working on solo projects (discussed further below). 

And perhaps even more importantly, there is a significant body of work from Common Music that can be used with very minimal adjustment in Scheme for Max. 
Indeed, if I were to describe S4M in one sentence, it would be that it is a cross between Common Music and the Max JS object.

Linguistic Features
--------------------
Not suprising, given Bill S's long involvement with Common Lisp music systems, s7 is, by Scheme standards, highly influenced by Common Lisp. 
It includes Common Lisp style *keywords*, symbols beginning with a colon and that act as symbols that always evaluate to themselves.
It supports Common Lisp style macros, rather than the syntax-case or syntax-rules macros in most modern Schemes, and to support using these safely (without inadvertent variable capture), it includes support for first-class environments (lexical environments can be used as values for variables), and includes the gensym function to create unique handles in the context of a macro definition.

Interestingly, and fortunately for the purpose of adoption, these are features also shared with Clojure, a modern Lisp variant with wide use in business and web application circles. 

We can assume these features were chosen by Bill as appropriate for his use case - the solo composer-programmer - and indeed in my personal experience have been highly productive for working on projects in S4M.

Ease of embedding
-----------------
Of the Lisp languages, Scheme in particular has a further pragmattic advantage.
Due to its minimal nature, Scheme is unusually simple to embed in another language, as a functional Scheme interpreter can be created in remarkably small amount of code. 
This has led to numerous implementations of Scheme as minimal extension languages, such as Guile, Elk, Chibi, TinyScheme, and s7 (the implementation used for S4M). 

(s7 is spelled lowercase and is named after a Yamaha motorcycle, for the curious! CITE BILL)
s7 was orginally forked from TinyScheme, which in turn was based on SIOD - Scheme in one Day - a project by computer science professor George Carrette intended to make the smallest possible Scheme interpreter that could be embedded in a C or C++ program.

s7 is available as two files, s7.h and s7.c that can simply be included in a source tree.
The foreign function interface (FFI) is very straightforward and will be discussed further in the implementation chapter.

And, importantly, s7 is fully thread-safe and re-entrant - meaning that there is no issue having multiple, isolated s7 interpreters running in the same application. 
This cannot be said of all embeddable languages, or even of all Scheme implementations, and makes it appropriate for Max, where a patch may, between itself and its subpatches, have an unlimited number of s4m objects.

License
--------
s7 uses the BSD license, a permissive free software licsense. 
The BSD license imposes no redistribution restrictions they way the GPL family of licenses do, thus user-developers wishing to use it in a commercial project are free to do so with no obligations.
This is a point in s7's favour as many Ableton Live device developers sell devices, and many Max developers sell standalone Max applications.


