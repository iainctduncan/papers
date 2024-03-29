High-Level Design 
================================================================================

In this chapter I will discuss the design of Scheme for Max on a high level
and the rationale for the various design decisions, in light of the previously discussed goals.

Why a Max extension?
----------------------------------------------------------------------------------------------------
As discussed, Scheme for Max is a tool for multi-language computer music programming. This begs 
the first design question: "Why choose Max specifically as the host platform?" 

One driver for choosing Max is the success of Max itself.
Having been first created in the 1980's, Max is now one of the most popular platforms world-wide 
for making computer music, with thousands of Max objects available between those provided by Cycling 74 and 
the broader Max community (CTN: maxobjects.com 2023).
This extensive community and breadth of available objects enables a wide variety of ways of working 
with both musical abstractions and digital audio, and even video.
This includes support for interacting with external hardware through various synchronization and
message protocols and hosting commercial software synthesizers and effect plugins in Max itself through
the vst~ object.

In addition to being a popular and powerful platform on its own, Max has been available since 2009 as "Max for Live",
an embedded runtime within the very widely-adopted commercial audio workstation and sequencing platform, "Ableton Live"
(CTN: Ableton 2009).
Max for Live has been so successful as an addition to Live that it led to Ableton acquiring Cycling 74 in 2017
(CTN: Ableton 2017).
When run in Max for Live, Max patches are able to process both audio 
and MIDI data, and can also interact with the host through an application programming interface, the Live API. 
The Live API provides Max patches the ability to control and query the Live engine, read and write to 
Live's own sequence and audio data, interact with the mixer and effects, and interact with the global transport.
Max for Live is included automatically in the top-tier Ableton offering ("Live Suite") as well as via an add-on to Live. 
While exact numbers are not published by Ableton, it seems highly likely that, between the standalone Max 
version and Max for Live, Max has become the most widely deployed advanced computer music programming platform worldwide.

In addition to the popularity of the platform and its integrations with a full-featured commercial sequencing tool, 
there are implementation-related attractions to Max as well.
Max supports two kinds of data passed between objects, audio samples and event messages, which in turn run in 
different threads of execution.
In Max, there are actually two threads handling event messages, the *main thread* and the *scheduler thread*.
The first is also referred to as the *UI thread* or *low-priority thread*, and the second as the *high-priority thread*.
MIDI data, events from timers and metronomes, and events from audio signals that have been turned into event messages 
(with various translation objects) all use the high-priority scheduler thread. 
Events from the user interacting with the GUI run in the low-priority thread, which is also used for redrawing any UI widgets.
A Max external can run in any or all of these contexts, and various objects and functions exist to queue messages from one to the other
(CTN: Cycling 74 2019).

Scheme for Max operates only in the two event oriented threads, receiving and producing only Max messages - 
that is, it does not render blocks of samples in the audio thread.
It can optionally be run in *either* the low or high priority thread, but each instantiation of the s4m object
is limited to one of these (chosen at instantiation time).
The threading designs of Max and Scheme for Max make it possible for us to run Scheme for Max code only occasionally 
(i.e., on receipt of a message rather than on every block of samples), and also to ensure that it runs at a high priority
and is not interrupted by low-priority activity.

As a result, the choice of creating the project as an extension for Max supports several of my goals.
There is a clear distinction between event-time and audio-time, supporting the goal of focusing on 
the musical event (e.g. "note") abstraction level.
By running only at the event time scale, we are afforded the option to use a high-level, garbage-collected language - 
whereas running a garbage-collected language in the audio rendering loop would seriously limit the amount of 
computation possible in real time and likely require us to run with a high degree of latency.

Additionally, using Max supports also the goal of being able to use the project in conjunction with modern commercial music tools.
Max runs seamlessly inside Ableton Live, and both Max and Live can host commercial VST plugins. 
When run in Ableton Live, Max uses Live's transport, and when run as a VST host, Max's transport is visible to the VST plugins.
It is thus possible to create music that mixes algorithmic content generated in Scheme with
content that is sequenced, rendered, or recorded with commercial tools.

Finally, using Max supports the goal of being usable for real-time interaction and live performance. 
The Max clocking facilities are highly accurate, with jitter being typically in the 0.5-1ms range when 
using a typical signal vector size of 32 or 64 samples (CTN: Lyon 2006, 67).
(Signal vector size is user configurable in standalone Max, and is locked to 64 samples in Ableton Live.)
Max timers are also implemented such that this degree of jitter does not accumulate over time, something
I have verified in extensive tests during development. 
This means we have a way to work with realtime events at levels of latency and temporal accuracy that
are appropriate for live performances with highly trained musicians. 

Taken together, these three points makes Max a very attractive host platform for the project. 
We can create music that is implemented in various mixes of Scheme, standard Max programming, and sequencing from Ableton Live.
We can use modern commercial effect and synthesis plugins, taking advantage of the dramatic advances in software synthesis in recent years.
And timing is reliable and accurate enough that we can use the tool on stage, or in the studio for commercial production of 
music where high timing accuracy is desired (e.g. electronic dance music).
We can even, through Ableton Live, use the tool during the mixing and mastering processes, as all of this can be done in Live, 
with Scheme for Max used to orchestrate and automate Live devices and VST plugins.

However, the advantages just discussed could be applied to any general-purpose programming 
language hosted in a Max external.
Which begs the second question: *"Why use a Lisp dialect rather than a more popular interpreted language as Python, Ruby, 
JavaScript, or Lua?"*
Or more pointedly, why bother at all, when Max provides already an object that embeds an interpreter for JavaScript in the form of
the **js** object?

Why not use JavaScript?
----------------------------------------------------------------------------------------------------
I will discuss in some depth the linguistic reasons for choosing a Lisp language, but first I will outline the 
reasons I could not simply use Max's built-in js object to satisfy the project goals. 

At first glance, the js objects seems like a comprehensive solution. 
It runs in Max, it can send and receive Max messages, it has access to Max global data structures such as tables and buffers, 
and it has a scheduler facility in the Task object (Taylor 2020).
Linguistically, it's a high-level language with various modern features such as automatic memory management, 
objects, lexical scoping, and functional programming techniques such as closures, and it is now one of the most popular
languages in the world (Sun 2017).

Unfortunately, the js object in Max has a serious implementation issue - in current versions of Max it *only* executes in the 
lower-priority main thread.  Any messages sent to the js object from the scheduler thread are implictly queued to the 
main thread and handled on its next pass (CTN: docs.cycling74.com n.d.).
The upshot of this is that the short-term timing of events handled in the js object is not reliable - 
depending on other activity, execution of messages can be delayed, with this delay large enough to be audibly noticeable as errors.
Thus, while JavaScript is usable for a great many tasks in Max, realtime programmatic note triggering is not one of them.
This was simple for me to verify, as any heavy redrawing of the graphic layer (such as by resizing the window) will
introduce significant delays to tasks scheduled through the Max JavaScript Task object.

In fact, I began my work combining textual programming with the Max environment by attempting to use the js object 
to build a large-scale sequencing framework. 
Overcoming the timing limitations of the js object was one of the initial motivations for the Scheme for Max project.
Fortunately, there is nothing in the Max SDK (the C and C++ software development kit used for building Max extensions) that requires
one to use any particular thread, thus any high-level language with an interpreter that is available as C or C++ code 
can be used in the scheduler thread safely so long as messages coming from other threads are appropriately queued.

Why use a Lisp language?
----------------------------------------------------------------------------------------------------
Given that using the js object was not deemed satisfactory, the next design question becomes: 
*"Which choose a Lisp language?"*
For the purposes of this discussion I will use "Lisp" when referring to traits shared across the Lisp-family of languages 
(including Scheme, Common Lisp, Clojure, and Racket), and Scheme when referring to the particular dialect used in Scheme for Max.

In the initial research stage of this project (dating back to 2019) I examined various possible high-level languages, 
and reviewed the use of many general-purpose languages in music.
Non-Lisp candidates I evaluated included Python, Lua, Ruby, Erlang, Haskell, OCaml, and JavaScript (i.e. in a new implementation). 

Overall, I concluded that the advantages of working in a Lisp for music outweigh the disadvantages
of its relative unpopularity and its unfamiliar syntax (to most programmers today at least).
These advantages include suitability for representing music; suitability for the typical scenarios and needs of the composer-programmer;
and suitability for implementing the project in Max specifically.

Compared to the other candidate languages mentioned, Lisp languages stand apart in several ways that are germane to this
discussion. (To be clear, some of these traits are shared by some of the other candidates, but I would argue that none of the 
other candidates share all of these traits with Lisps.)

Symbolic computation and list processing 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Lisp is unusual in its first-class support for programming with *symbols* and in its simple, minimal, and consistent syntax (CTN: Taube 2004, 8).
Programming with symbols, also known as "symbolic computation" or "symbolic processing", means
that programs can work directly with not only program *data* but with the *textual tokens* comprising the program itself.
For example, as with any high-level language, we may have a variable named **foo**, at which we have stored the value **99**,
allowing us to refer to the contents bound to that variable (99) by the name **foo**. 
When the interpreter encounters the textual token **foo**, perhaps in an expression such as **+ 1 foo**, 
it will automatically *evaluate* this token, replacing it in an internally expanded form with the number 99. 
But in Lisp, we may also work with the textual token itself, referring to *the symbol foo*,
just as easily as we work with any other primitive type. We can pass it around, put it in lists,
concatenate it to other symbols, and so on.
When we want to refer to the symbol part of a variable (the text to which the value is bound),
we use a facility of the language called *quoting*, by which we instruct the interpreter 
to skip evaluating the symbol as a variable (thus expanding to 99) and instead work with the textual token.
We can quote by using the **quote** function, or by prepending a symbol with a single quote: **'foo**.
This symbolic processing capability is particularly appropriate for music, as we shall see shortly.

In addition to this, Lisp syntax is *entirely* composed of s-expressions, which are parenthetical 
expressions containing lists of symbols and primitives. 
For example, below are several ways to return a list of symbols. We can see that all 
use one or more parenthetical expression as the basic unit of syntax. 

.. code:: scheme

  ;; 3 ways of creating a list containing the symbols foo, bar, and baz
  ;; use the list function
  (list 'foo 'bar 'baz)
  ;; quote the printed representation with a single quote
  '(foo bar baz)
  ;; use the quote function on the printed representation
  (quote (foo bar baz))

The value returned by the above expressions is represented on the console by the text ``(foo bar baz)``.
Note that this looks identical to the source-code for a Lisp function call,
specifically it looks like code we would use to call the function **foo** with the arguments **bar** and **baz**. 
And indeed, if we were to take the lists returned in our example and pass this returned *symbolic* structure 
to the Lisp **eval** function,
that is exactly what would happen - the interpreter would execute whatever function is bound to the symbol **foo**, passing
it the arguments **bar** and **baz**.

Below is an example of doing just this at a Scheme interpreter. (The lines prefaced by **>** are the text
responses from the interpreter that would be printed to a console in an interactive session.)

.. code:: scheme

  ; create a list and save it to the variable my-program
  (define my-program (list 'print 99))
  > my-program
  ; now run it, which will print 99
  (eval my-program)
  > 99
  ; or all in one step
  (eval (list 'print 99))
  > 99

In the example above, we used quoting to create
a list consisting of the symbol **'print** and the number 99, and then
we used **eval** to *run this list as a program*.
The impact of this is profound:
Lisps allow us to easily and elegantly make programs that build lists of symbols and primitives, 
*and these lists we have built can themselves be executed as programs*.

Now to be clear, we can also build a program with a program in other high-level languages, including Python, Ruby, Lua, and JavaScript.
However, in none of these languages is programming *on* the symbolic tokens of the language directly supported the way it is in Lisp.
The result is that in these other language this kind of dynamic programming (also known as "meta-programming") is very involved and 
is typically seen as something to be used only sparingly by expert programmers building reusable tools.
In Lisp, on the other hand, manipulating lists of symbols, and later evaluating them as functions, is the very stuff of which the language is made.

Now, why does this matter for a programming language for music?

As in Lisp code, in music we use lists of symbols to represent functions, relationships, and events.
For example, let us say I write a chord progression, such as **I vi ii V7**.
We have a *list* of four items, each denoted by a symbol: **I**, **vi**, etc.
Each of these symbols represents musical data for a given chord, but by themselves, they don't represent *music* - 
they need a key *to which the function represented by the chord symbol can be applied*.
Thinking computationally, **V7** must be a *function* - it is a description of something we get when we apply a 
particular algorithm (the intervals within the chord along with the scale-step for the root) to a parameter (the tonic key).

In a Lisp language, this can be represented in code that is visually compatible (almost identical even) to what we would use in musical analysis. 
``(chords->notes 'C '(I vi ii V7))`` is a legitimate line of Lisp syntax that could be implemented to be a function
that renders a chord progression into a list of notes, given a tonic of C.
It could even return something symbolic that looks very familiar to a musician, and *on which more of the program can work*. 
A potential return value could be represented by the interactive Lisp interpreter as a nested list containing sub-lists of symbols:
``'( (C E G) (A C E) (D F A) (G B D F))``

Further, because this form of symbolic computation is so central to the language - one of the classic texts is even subtitled 
"A Gentle Introduction to Symbolic Computation" - Lisps include numerous functions for manipulating and transforming lists (CTN: Touretzky 1984). 
For example, we might transpose a list by applying a transposition function, which itself might be built by a function-building function
called **make-transposer**, and we might apply this function to a list of symbols. 
This sounds complicated, and indeed, expressing this in most languages is cumbersome, but in Scheme this is both readable and succinct:

.. code:: scheme

  ; apply a transposition function that transposes all elements in our chord progression by 2 steps
  ; the map function maps a function over a list, returning a new list
  ; (make-transposer 2) creates a function that transposes by 2 specifically
  (map (make-transposer 2) 
    '( (C E G) (A C E) (D F A) (G B D F)))

  ; expressed without first expanding our chord progression
  (map (make-transposer 2)
    (chords->notes 'C '(I vi ii V7)))

This demonstrates that Lisps are particularly well-suited to expressing musical data, relationships, and algorithms in
computer code.
As a result of this suitability, there is a rich history of Lisp use in musical programming, 
and Lisp-based musical programming environments abound, both historical and current. In addition
to those already mentioned, others include
Common Lisp Music, Common Music Notation, MIDI-Lisp, PatchWork, OpenMusic, cl-collider, and many more (CTN: CLiki n.d.). 

Thus the choice of Scheme as the language for the project has several important advantages:

* Code representing musical data can be more succinct, lowering the sheer amount of code the composer must contend with while working.
* Code working with musical constructs can look remarkably similar to the notation that composers are used to, making the code
  more readable, and thus more appropriate for use within a piece of music that may be composed of both data and code.
* Programmers have access to a rich historical body of prior work, with code that can be ported to Scheme for Max relatively easily.


Dynamic code loading and the REPL 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Previously mentioned as *interactive development*, or *REPL-driven development*, Lisp programmers commonly work in an ongoing process 
of evaluating new code in the interpreter and examining the interpreter's output, *while the program runs*. 
At any point, the programmer can send new expressions to the Lisp interpreter, which evaluates the expressions, updates
the state of the Lisp environment, and then prints the return value of evaluating the expressions.
These expressions can define new functions, redefine functions already in use, change state data, or 
interactively inspect or alter the current environment. While this interactive style of development is possible
to some degrees in other high level languages (such as Python and Ruby), it has been available to a deeper degree in Lisp going
back as far as the 1970's! (CTN: Sandewell 1978, 35-39)

For example, the composer-programmer might separate work into files that contain score data and files 
that contain functions for altering or creating music, where the functions might be musical transformations of 
algorithms for generating new content given base score data.
The files of functions can be incrementally edited and reloaded, thus updating algorithm definitions, without needing 
to restart the piece or reset the score data.

In Scheme for Max, the programmer can also trigger
interpreter calls from text interface objects in Max, or even from an external text editor 
by sending blocks of code over the local network into Max. 
Max has a console window to show messages from the Max engine, and this is used by Scheme for Max
for the "print" stage of the REPL loop so that the results of dynamic evaluation can be read by the programmer.

I have personally found this capability to be enormously productive while working on 
algorithmically generated or augmented compositions - the ability to tinker with the algorithms
without necessarily restarting a piece is a significant time saver, and being able to interactively
inspect data in the Max console while doing so is similarly helpful.


Macros and Domain Specific Languages
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
One of the hallmarks of Lisp is the Lisp macro.
We have previous discussed the ease with which the Lisp programmer can programmatically create lists of 
symbols that are then evaluated as syntactic Lisp expressions; the Lisp macro is a linguistic formalization of this process. 
In use, macros look to the programmer just like a regular function calls, but by virtue of being defined as a macro, 
they are first called in a special evaluation pass known as the *macro-expansion* pass.
This runs the code in the body of the macro over the *symbolic arguments* passed into it, returning a
programmatically created list structure (the macro expansion) that is then evaluated. 
Essentially, macros are code blocks that execute twice - first to build the code by working with symbols,
and then to run the code by evaluating it (though 
technically this can be more than twice if macros are nested (CTN: Touretsky 1984, 405-417). 

Macros enable programmers to create their *own* domain-specific languages - 
miniature languages within a language that are closer in syntax and semantics to the problem domain than to the host language. 
This makes it possible for code that uses the macros to be visually aligned with the problem domain, 
making them easier to read and faster to type. 
For example, a macro I use for scheduling events in a score looks like the below:

.. code:: scheme

  (score 
    :1:1       (phrase-a :dur 2b :repeat 4)
    :+8        (phrase-b :dur 8b :repeat 4)
    :9:1:120   (phrase-c :dur 8b :repeat 4))

The time arguments (``:1:1``, ``:+8``, and ``:9:1:120``) are converted by the macro layer into musically meaningful time 
representations, specifically, function calls that schedule events. 
This allows the visual representation of the score code to be more easily read, thus
the flexibility of macros allow me to use textual representations that are very convenient for me as the composer.

But to clarify, this is *not* a separate score language with limited functionality, as is found in Csound.
This *is Scheme code* - it can include *any* Scheme functions and even be built by Scheme functions. 
Thus the use of a language with macro facilities enables the composer to work with different kinds of code 
- function defining code and score code - in one language, without giving up the expressive power of high-level language 
facilities. This use of a general-programming language that can function additionally *as a readable score language*
provides tremendous flexibility to the programmer, breaking the dichotomy between score data and running program  (CTN: Dannenberg 1997, 50-60).

Max and Lisp syntax compatibility
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Finally, there is the fortunate coincidence of the Max message syntax being almost perfectly compatible with Lisp syntax.
This happy accident (we can assume!) means that a composer-programmer can create and run Scheme code *in Max patcher messages*, and
use Max message-building functions to do so.
While this compatibility was not something I was expecting when originally embarking on the design of Scheme for Max, 
it has had a profound effect on the ease with which one can build Max patches that interact with Scheme for Max programs.

A Max message consists of Max *atoms*, which are space-separated tokens that may be integers, floating point numbers, or alpha-numeric symbols.
It may also consist of several special characters: the dollar sign, the comma, and the semi-colon.
The dollar sign is used as a template interpolation symbol: messages with dollar signs in their text body will output template
expansions to downstream objects, injecting arguments they receive in their inlets in place of the dollar signs.  
A leading semi-colon in a Max message indicates the message is a special message sent to the Max engine itself.
Finally, the comma is used to indicate that the message is actually two message, with the two comma-separated halves being sent sequentially.

Notably, the parenthesis, used in Lisp to delimit Lisp expressions, and the colon, used to indicate that a symbol should be a keyword (a special kind of symbol),
have no special significance in Max messages.
Conversely, the dollar sign has no significance in Lisp, and the semi-colon (used for comment characters) and the comma 
(used for back-quote escaping) are easily avoided.

The result of this is that, rather than require the programmer to create special handlers in their code to respond to Max messages 
(as one must do when using the js object), the s4m object is able to simply evaluate incoming messages *as if they were Scheme code*,
saving the programmer the need to write callback functions for every type of incoming message.
This facility is covered in more detail in the next chapter, with an accompanying figure.

Having built some complex programs myself in JavaScript in Max prior to building Scheme for Max, 
I have found this to be a significant advantage of Scheme for Max over the js object. 

Of the possible Lisp languages, why use s7 Scheme?
--------------------------------------------------
When beginning the project, after determining that a Lisp-family language was appropriate, I evaluated a number of 
Scheme and Lisp implementations as candidates.
I will discuss now why the s7 implementation in particular was chosen.
(Note for the curious: the author has informed me that s7 is intended to be spelled lowercase 
as it is named after a Yamaha motorcycle!)

Use in Computer Music 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
s7 was created by, and is maintained by, Bill Schottstaedt, a professor emeritus of the Stanford music centre (CCRMA), 
and the author of Common Lisp Music and the Snd editor. 
s7 is used in in Snd editor (essentially an Emacs-like audio editing tool), and in Common Music 3, an algorithmic composition 
platform created by Henrik Taube (Schottstaedt n.d.).
This has meant that there is a significant body of code from Common Music that can be used with very minimal adjustment in Scheme for Max. 
Indeed, if I were to describe S4M in one sentence, it would be that it is a cross between Common Music and the Max js object.

Linguistic Features
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Not surprising, given the author's involvement with Common Lisp (CL) music systems, s7 is, by Scheme standards, 
highly influenced by Common Lisp. 
It includes Common Lisp *keywords*, which are symbols that begin with and always evaluate to themselves.
s7 also uses Common Lisp style macros (a.k.a. "defmacro" macros), rather than the syntax-case or syntax-rules macros 
in many other Scheme implementations.
To support CL macros safely (without inadvertent variable capture), s7 includes support for first-class environments 
(lexical environments that can be used as values for variables), and the **gensym** function, which is used to create
guaranteed-unique symbols for use in a macro expansion (Schottstaedt n.d.).
Interestingly, and perhaps fortunately for the purpose of adoption, these are features also shared with Clojure, 
a modern Lisp variant with much in common with Scheme, and with wide use in business and web application circles
(Miller et al. 2018).

We can assume these features were chosen by Bill as appropriate for his use case - the solo composer-programmer - 
and indeed in my personal experience they have been helpful for working on projects in S4M.
For example, the ability to use keywords allows us to have symbols in Max messages that will be preserved
as symbols when the message is evaluated by the s4m interpreter, and these are easily differentiated visually in Max 
messages by their leading colon. 

Ease of embedding
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Of the Lisp dialects, Scheme in particular has a further pragmatic advantage.
Due to its minimal nature, it is eminently appropriate for embedding in another language,
and there thus exists a wide variety of embeddable Scheme interpreters.
A functional Scheme interpreter can be created in a very small amount of code -
there is even an implementation named SIOD, for "Scheme In One Defun" (but also referred to as "Scheme in One Day").
SIOD was a project by computer science professor George Carrette, started in 1988, intended to make 
the smallest possible Scheme interpreter that could be embedded in a C or C++ program (CTN: Carrette 2007).

The s7 project in particular is a Scheme distribution intended expressly for embedding in C host programs, and
designed to make that use case as simple as possible.
The core s7 interpreter is distributed as only two files, **s7.h** and **s7.c**, that can simply be included in a source tree.
The foreign function interface (FFI) is very straightforward, making adding Scheme functions to S4M simple.
And, importantly, s7 is fully thread-safe and re-entrant - meaning that there is no issue having multiple, isolated s7 interpreters 
running in the same application, a situation common in a Max patch where many s4m object may coexist, but a feature
not common across all candidate implementations (CTN: Schottstaedt n.d.).

License
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Finally, s7 uses the BSD license, a permissive free software license. 
The BSD license imposes no redistribution restrictions the way the GPL family of licenses do, thus user-developers wishing to 
use s7 in a commercial project are free to do so with no obligations (CTN: Schottstaedt n.d.).

This is a point in s7's favour as many Ableton Live device developers sell devices, and many Max developers sell standalone Max
applications, thus I would also like to allow use of S4M in these contexts.


