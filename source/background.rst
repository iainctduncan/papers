Background - Computer Music Programming Languages (4300 words)
==============================================================

Status: 2023-06-02 edited, needs citations, needs proof read

What is Computer Music Programming?
-----------------------------------
To frame the discussion of the the motivation and goals of the Scheme for Max project, I will 
first briefly survey the computer music programming landscape, discussing several families of 
language, their approaches to programming computer music, and the advantages and disadvantages of these
for various kinds of user and projects. 

To begin, I would like to clarify exactly what I mean by "computer music programming".
I am using the term to refer to programming in which both the tools used and the composition itself
are programmed on a computer. 
I say this using the word "composition" in its broadest sense - the composition could
be a linearly scored piece of set length and content, or an interactive program with which 
a performer interacts but that contains prepared material of some kind. 
This is distinct, for example, from commercial music tools (such as sequencers or digital
audio workstations) in which a computer program is run as the host environment, but the compositional
work itself is stored as data within that program (for example in a prorietary binary format or
in MIDI files), and would not normally be considered a computer program
in itself.

Using this definition of computer music programming, we can draw a further distinction
between two kinds of programming and programmer:
we have programming that is specific to a composer, one or more artistic pieces of work.
we have programming of tools and frameworks that will be used by many people and in potentially 
many contexts.
For the purpose of this discussion, I will refer to the people doing these as the "composer-programmer"
- a term also used by Curtis Roads in "Composing Electronic Music" (Roads, 2015, 341) -
.. citation (Roads, 2015)
and the "tools programmer" (my own terminology). These may, of course, be the same
person at different times.
This distinction is important, as the goals of these two programmers, and thus the
ideal design of supporting technology, can frequently be very different. 
The composer-programmer likely wishes the tools to be as immediately convenient as possible to 
an individual, while the tools-programmer may be 
developing tools for use by a larger community and may prefer design decisions  
that favour long-term code reusability and sharing at the expense of immediate convenience.
As we will see, the various computer music languages, platforms, and approaches 
favour one of these hypothetical programmers.

Beyond these distinctions, I use the term "computer music programming" as broadly
as possible - we will consider graphic platforms with which a beginner can be immediately
productive as well as tools for advanced programming languages that are only accessible
to experienced computer programmers.

Requirements for a Computer Music Platform
-------------------------------------------
Prior to examining the programming platforms, let us examine some 
common requirements of the composer-programmer so that we can assess how the various
options meets these needs.  
While the list of possible requirements is potentially long, I will group
them into three high level requirements that are personally important to me as
a composer and performer. Note that not all of these are necessarily fulfilled well, or at all,
by each of the possible platforms a composer might use - some offer
only partial support for a requirement, or perhaps even none at all. (Lazzarini, 2013, 1) 
.. citation (Lazzarini, 2013) 

Support for Musical Abstractions
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
To be maximally productive in producting musical works, the computer music language should provide
musically meaningful abstractions that support how the composer thinks about music.
Examples of these abstractions would be some programmatic construct for representing 
notes, scores, instruments, voices, tempi, bars, beats, and the like.
The more of these that are supported in the language itself, the less the programmer
must decide and code themselves. 
Probably the most important of these abstractions are those concerning musical time
- a good computer music language must have an implementation of *logical time*,
allowing the programmer to schedule events accurately in a way that makes sense
to the user but that also works for rendering or playing in real-time to a degree of accuracy
appropriate for music. (Dannenberg, 2018, 3)
.. citation (Dannenberg, 2018)

However, it should be noted that the importance of these abstractions being readily provided
by a language varies widely amongst composer-programmers:
while some composers will be relieved not to have to decide how to implement 
the concept of beats and tempi in their work, others may be expressly looking for platforms
that do not come with any assumptions on how one might think about these.
Computer music programming languages thus also vary widely in their areas
of focus and the problems they attempt to solve for the programmer (Dannenberg, 2018, 4).
.. citation (Dannenburg, 2018)
For example, the Csound language comes with a built-in abstraction of a score system,
that in turn depends on abstractions representing beats and tempi (Lazzarini, 2016, 157).
.. citation (Lazzarini, 2016)
In contrast, the Max platform takes the design approach of giving the user
an almost blank canvas, deliberately avoiding any assumptions that the user
will make music of any particular style or in any particular way. (Puckette, 2002, 34)
.. citation (Puckette, 2002)

For my own purposes, I would ideally like to have the ability to score conventional music without
necessarily being required to implement a score system myself, but still have the flexibility of being able
to implement my own or greatly alter the abstractions that come with a language. 
A system meets my requirements if it is feasible for me
to score complex works and have them played back accurately enough for a recording. 
My personal yard stick is to ask whether I could
reasonably program and render a piece such as "Ionization" by Varese, with its shifting
meters and cross-rhythms between instruments - an endeavour which would be frustratingly 
difficult on standard commercial tools.

Support for Performer Interaction
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The platform should make it possible for a performer to interact with a 
a piece while it plays. Various computer music languages support interaction through 
manipulating a computer directly (through text, network input, or graphical devices), 
through physical input devices such as MIDI controllers and network-connected hardware, 
and even through audio input, allowin the perfomer to interact with the program by playing
an acoustic instrument.

Again, the importance of this varies with the composer and the platform.
In fact, this was not even possible with early computer music languages such
as the MUSIC-N family, with which the process of rendering audio from a score file 
took far longer than the duration of a piece. (Wang, 2008, 6)
.. citation (Wang, 2008) needs page checked

However, since the advent of realtime-capable systems, this has become a
standard feature in computer music platforms.
In fact, in contrast to the Music-N languages, the Max platform was designed
to support performance-time interactivity first, with the ability to render audio only added later
as computers became capable of doing both. (Puckette, 2002, 33)
.. citation (Puckette, 2002)
As someone who comes principally from a jazz and contemporary improvised music
background, being able to create complex systems that support realtime input is a high priority to me.


Support for Complex Algorithms
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Finally, the platform should provide support for programming algorithms of significant complexity.
It should be possible to make the platform, for example, do things that are impractical
or impossible for the human perfomer or for the composer working at a piano with score paper.
My personal goals include creating music that combines algorithmically generated 
material with traditionally scored and improvised material. 
For my algorithmic work, I want to explore techniques and forms that would be impractical
if one is individually entering notes, thus instead requiring programmatic implementation of
algorithms. 
However, it is also important to me that a performer be able to interact with the algorithms.
That, to quote Miller Puckette on his original design goals for Max, 
basic musical material should be "controllable physcially, sequentially, or algorithmically;
if they are to be controlled algorithmically, the inputs to the algorithm should 
themselves be controllable in any way". (Puckette, 1991, 68)
.. citation (Puckette, 1991)

While one could certainly come up with further requirements, these three provide the basis
on which I will discuss the main families of computer music programming tools, and
around which we can discuss how Scheme for Max complements existing options.

Computer Music Platform Families
--------------------------------
For the purpose of keeping this discussion within a reasonable length,
I will likewise categorize the historical and currently popular computer music programmimg
environments into three general categories: domain-specific textual languages, visual patching
environments, and general purpose programming languages that are run with music-specific libraries
or within musical frameworks. 

I will briefly discuss each of these, listing examples, but focusing on a representative tool from each family.
I will provide my observations and experiences of the advantages and disadvantages of each, 
drawing both on the literature and on my personal experiences with tools from each category 
over the last 25 years.

Domain-specific Textual Languages
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
A domain-specific language (DSL) for music is a textual programming language designed
expressly around making music with a computer. (Wang 2008, 1)
.. citation (Wang, 2008, check page - replace with better DSL def citation if I find one

Interestingly, the first example of programming computer music (that one might reasonably
consider as more than experiment) used a music DSL, namely Max Matthew's MUSIC I
language, created in 1957. 
MUSIC I (originally refered to as simply MUSIC) was a domain specific language written in assembly 
IBM 704 mainframe at Bell Labs.
It was able to translating a high-level language with musical abstractions to assembly code,
and could (through various intermediary steps) output digital audio. 
MUSIC I was followed by various refinements by Matthews (Music II through V),
and by similar languages by others. 
Its lineage continues to this day in the Csound language, still under active development and widely used,
and one with which I have extensive experience. (Manning, 2013, 187-189)
.. citation (Manning, 2013)

While the source code of Csound piece, for example, is clearly a computer programs 
(and would be recognizable as such to one familiar with programming)
the way in which it turns code into music would not likely be obvious at a glance to a programmer unfamiliar with music.
The language is, to a significant degree, designed around high-level abstractions suitable for particular ways
of creating a composition, and has a particular way in which it is run to make the final product. 
Historically, running such a program meant rendering a piece to an audio file, but
with modern computers (and versions of Csound) the rendering can be done in real time.
While originally these programs were not something with which a performer could interact,
facilties now exist in Csound for performers to interact with the programs while they play. (Lazzarini, 2016)
.. citation (Lazzarini, 2013)

In addition to Csound, other actively developed examples from this general family of language
include SuperCollider, ChucK, Faust, along with many others,
each of which has a particular focus or approach to the problems of computer music.

A notable advantage of a using a music DSL is that many of the hard
decisions that face the programmer, and much of the work, has been done already. 
The composer-programmer is not starting with a blank slate: 
the language provides built-in abstractions ranging from
macro-structural concepts such as scores and sections to individual notes and beats.
Music DSLs thus significantly simplify the task of programming music and reduce
how much the composer-programmer must learn and program to begin making music (Lazzarini, 2017, 26).
.. citation (Lazzarini, 2017)
In Csound, for example, a program consists of an "orchestra" file, containing
programmatic instrument definitions, and a "score" file, containing a score
of musical events notated in Csound's own data protocol.
These are used together to render a scored piece very precisely to audio, 
either as an offline operation or as a real-time operation.

In the simple example in figure 1, we have a instrument playing a
short melody driven by the score.

.. TODO insert Csound code example

..

With these clearly musical constructs, DSL's are attractive to the composer-programmer, 
but on the other hand, the tools-programmer is significantly more constrained than when
working in a general purpose language.
This can be frustrating for experienced programmers coming from general purpose languages,
who may wonder where their function calls and looping constructs went and how they can
express programming algorithms in the abstractions provided by the language.
For example, in Csound one can program a form of recursion, but this often involves creating
instruments that play notes that in turn schedule notes. (Lazzarini, 2016, 116)
.. citation (Lazzarini, 2016)
The use of the note  as the fundamental
unit of computation (where a "note" is an instance of an instrument definition activated at
some time, for some duration) introduces a barrier requiring the tools-programmer not just 
to understand the concept of recursion, but to also understand how to translate it
into an unusual syntax. 

That said, music DSLs generally provide ways of *extending* the mini-language with 
a general purpose language, allowing the tools-programmer to add new abstractions suitable
for the composer-programmer to use in a piece.
In Csound, for example, a tools-programmer may create a new opcode (essentially the equivalent
of a Csound class or function) using the C language,
compiling it such that it can be used in the same way as any built in opcode that comes with Csound.
(Fitch, 2011, 581)
.. citation (Fitch, 2011)

It should also be noted that the ease with which composer-programmers can work 
with these languages has led to broad popularity in the music community, and this
in turn has led to many programmers creating publically available extensions, thus providing
a rich body of work for the programmer to draw upon.
Csound, for example, is still actively used and developed today, which is
remarkable for a language first developed in 1986. (Manning, 2013, 189).
.. citation (Manning, 2013)
If an extension is popular and useful enough, it may even find its way into the
main language or into official repositories of extensions.


So how does a music DSL such as Csound stack up with regard to our three high level requirements?
Certainly, we are given many high-level musically meaningful abstractions. 
Creating linear pieces according to a set score is straightforward.
Performer interaction is also possible in modern versions, though programming 
an interactive system is somewhat cumbersome in that tasks that would require simple programming
in a general purpose language 
must be done in an unusual manner to fit in the music-centered paradigm of Csound.
For example,  making a component to receive, parse, and translate MIDI input according
to some arbitrary rules requires making an "instrument" and having the
score turn on "always-on" notes (Lazzarini, 2106, 175).
.. citation (Lazzarini, 2016)
Clearly we are bending the built in abstractions to other purposes, 
at the expense of easily comprehensible code.

Likewise, expressing complex algorithmic processes can be difficult.
Being a textual language, expressing mathematical formulae is straightforward. 
But anything truly complex, for example, building a constraint system incorporating 
looping, sorting, and filtering is prohibitively cumbersome.
Absent regular functions and iteration, these kind of ideas can be very difficult to express,
requiring a great deal of code that is subverting the design of the language.

Returning to our distinction between the composer-programmer and the tools-programmer,
one could say that music DSLs are heavily optimized for the composer-programmer
and for the process of composing a (relatively speaking) traditional linear piece.
Or, to put it another way, Csound and its like are appropriate for making *pieces*,
but cumbersome for making *programs*.  

Visual Patching Environments
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
A quite different family of computer music languages comprises the visual "patching" environments,
such as Max and PureData (a.k.a Pd). 
First created by Miller Puckett while at IRCAM in 1985, 
Max was designed from the outset to support real-time interactions with performers.
In a typical use case, the Max program would output messages (which could be MIDI data, but were not 
necessarily), and these would be rendered to audio with some other tools, such
as standard MIDI-capable synthesizers or other audio rendering systems. 
Later versions of Pure Data and Max added support for generating audio directly,
as computers became fast enough to generate audio in real-time (Puckette, 2002, 34).
.. citation (Puckette, 2002)

In Max and Pure Data,
the composer-programmer places visual representations of objects on a graphic canvas, 
connecting them with virtual "patch cables". When the program (called a "patch") runs,
each object in this graph receives messages from other connected objects, processes the 
message or block of samples, and optionally outputs messages or audio in response.
A complete patch thus acts as a program where messages flow  
through a graph of objects, similar to data flowing through a spreadsheet application.
The term "dataflow" has been used to describe this type of program (Farnell, 2010, 149)
.. citation (Farnell, 2010, 149)
though it should be noted that the Miller Puckette himself asserts that it is not
truly "dataflow" as the objects may retain state and ordering of operations with the graph
matters. (Puckette, 1991, 70)
.. citation (Puckette, 1991)

A large body of ready made objects are available for Max and Pure Data, both included
in the platforms and as freely available extensions. These include objects
for handling MIDI and other gestural input, timers, graphical displays,
facilities for importing and playing audio files, mathematical
and digital signal processing operaters, and much more (Cipriani, 2019, XI).
.. citation (Cipriani, 2019)

This visual patching paradigm differs significantly from that of Csound and similar DSLs. 
The program created by a user is best described as an interactive environment,
rather than a piece.
A patch runs as long as it is open, and will do computations in response to 
incoming events such as MIDI messages, timers firing, or blocks of samples
coming from operating systems audio subsystem (Farnell, 2010, 149).

.. TODO max patch figure
In figure 2 we see a simple Max patch in which ....TODO

In contrast to textual DSLs such as CSound, patching environments have comparatively
little built in support for musically meaningful abstractions.
There is no built in concept of a score, or even a note, and there is no
facility for linearly rendering a piece to an audio file.
The programmer must build such things out of the available tools. 
In this sense, these environments are more open ended than most DSLs - one
builds a program (albeit in a visual manner) and this program
could just as easily be used to control lighting or print output to a console
in response to user actions as play a piece of music. And indeed, modern versions of Max
and Pure Data are widely used for purely visual applications as well as music,
through the Jitter (Max) and Gem (Pd) collections of objects.
There is nothing intrinsically musical about the patcher environments -
the environments are much more open ended in this way than the musical DSLs.
As Max developer David Zicarelli put it in his paper on the 17th anniversary of Max,
it is, compared to most programs, "a program which does nothing", presenting the user 
with a completely blank canvas (Zicarelli, 2002, 44).
.. citation (Zicarelli, 2002)

Returning to our requirements, the fundamental strength of patching environments
is the ease with which one can create programs with which a performer interacts.
A new programmer can realistically be making interesting interactive environments
that respond to MIDI input within the first day or so of learning the platform. 

However, making something that is conceptually closer to a scored piece is much more
difficult than in a language such as Csound.
It is most definitely possible, but it requires the programmer to be
familiar with the workings of many of the built in objects, and to make
a not insignificant number of decisions, such as  
how data for a score should be stored, what constitutes a piece (or even a note!),
how should be playback be controlled or clocked, and so on.

Implementing complex algorithms is also a difficult task in the patching languages.
The dataflow paradigm is unusual in that it requires one to write programs entirely
using side-effects. Objects do computations in response to incoming messages, which, under
the hood, are indeed function calls from the source object to the receiving object,
but the receiving objects have no way of *returning* the results of this work to the caller - they
can only make new messages that will be sent to downstream objects, resulting in more
function calls until the chain ends.
Describing this programming terminology: the flow of messages creates a call chain 
of void functions, with the stack eventually terminating when there are no more functions
called. (Cycling 74, 2023)
.. citation (Cycling 74)  TODO how to do this?
While easy to grasp for new programmers, 
this style of programming makes many standard programming practices difficult to implement,
such as recursion, iteration, searching, and filtering. 
Thus, much like the musical DSLs, but for a different set of reasons, complex 
algorithms that would be straightforward in a general purpose language can require
significant and non-obvious programming.

General Purpose Languages
^^^^^^^^^^^^^^^^^^^^^^^^^
Our third family of computer music programming languages is that of 
general purpose programming languages (GPPLs), such as C++, Python, JavaScript, Lisp, and so on. 
The use of GPPLs for music can be divided broadly
into two approaches, corresponding to the mainstream software development
approaches of developing with libraries versus developing with 
inversion-of-control frameworks.

In the library-based approach, the programmer works in a general purpose language,
much as they would for any software development, and uses third-party 
musically oriented libraries to accomplish musical tasks.
In this case, the structure and operation of the program is entirely up to the programmer.
For example, a programmer might use C++ to create an application, creating sounds
with a library such as the Synthesis Tool Kit (Cook, 2002, 236-237),
.. citation (Cook, 2002). 
handling MIDI input and output with PortMidi (Lazzarini, 2010, 784-795)
.. citation (Lazzarini, 2010)
and outputing audio with the PortAudio library (Maldanado, 2010, 364-375).
.. citation (Maldanado, 2010).
While the use of these libraries significantly reduces the work needed by the programmer,
fundamentall they are simply making a C++ application of their own design.

In the second approach, a general purpose language is still used,
but it is run from a muscially-oriented host, which could be either
a running program or a scaffolding of outer code (i.e., the host
is in the same language and code base but has been provided to the programmer).
The term "inversion-of-control" for framework-based development of this type refers to the fact
that the host application or outer framework controls the execution of 
code provided by the programmer - the programmer "fills in the blanks", so to speak.
Non-musical examples of this are the Ruby-on-Rails and Django frameworks for web development,
in which the programmer need provide only a relatively small amount of Ruby or Python
code to create a fully functional web application.
.. citation RoR and Django sites TODO.
A musical example of this is the Common Music platform, in which
the composer-programmer can work in either the Scheme or Common Lisp programming language,
but the program is executed by the Grace host application, which 
provides an interpreter for the hosted language, along 
with facilities for scheduling, transport controls, outputting MIDI, and so on (Taube, 2009, 451-454).
.. citation (Taube, 2009) 
The framework-driven approach thus significantly decreases the number
of decisions the programmer must make and the amount of code that
must be created, while still preserving the flexibility one gaines from
working in a general purpose language.

While the framework-oriented approach is ultimately less flexible than the
library-oriented approach, as the programmer must work within the architectural
constraints imposed by the framework, the strength of GPPLs compared to either
textual DSLs or visual patching platforms is undoubtedly flexibility, especially with
regard to implementing complex algorithms.
With a general purpose language, the programmer has far more in the way
of programming contructs and techniques available to them. 
Implementing complex algorithms is no more difficult than it is in any 
programming language. Looping, recursion, nested function calls, and complex
design patterns are all practical, and the programmer has a wealth of resources
available to help them, drawing from the (vastly) larger documentation
available for general purpose languages. (CITE dannenburg here on GPPL
.. TODO citation needed
Of course, this comes at the cost of giving of the programmer both a great deal more 
to learn and a lot more work to do to get making music. 
In the library-based approach, it is entirely up to the programmer to figure out 
how they will go from an open-ended language to a scored piece,
and even in the framework-driven approach, the programmer begins with 
much more of a blank slate than they typically do with a musical DSL.

General purpose languages are thus attractive to composers wishing
to create complex algorithmic music, or to those wishing to create sophisticated
frameworks or tools of their own that they may reuse across many pieces. 
With general purpose languages, the line between composer-programmer and tools-programmer
is blurred and managing this division is one of the tricker problems 
with which the programmer must wrestle.

General purpose languages can also provide rich facilities for 
performer interaction, but again, at the cost of giving the programmer much more
to do. Numerous libraries exist for handing MIDI input, listening to
messages over a network, and interfacing with custom hardware. 
However, the amount of work and code required to use these is dramatically
higher than doing the same thing in a patching environment - an order of 
magnitude, at least!
However, *relatively speaking*, the additional work required decreases as the complexity
of the desired interaction grows. Given a sufficiently complex interactive
installatation, at some point the tradeoff swings in favour of the general
purpose language. Where precisely this point is depends a great deal
on the expertise of the programmer - to a professional C++ programmer, the
savings of using a patching language may be offset by the power of the 
(C++) development tools with which the programmer is familiar.

Multi-Lanugage Platforms 
^^^^^^^^^^^^^^^^^^^^^^^^^^
.. perhaps rename multi-language?
.. TODO cite 

Finally, we have what is, in my personal opinion, the most powerful approach to computer music programming:
the multi-language hybrid platform. 
As programming tools and computers have improved,
it has become more and more practical to make computer music using more than one platform at a time
in an integrated system.  

This multi-language approach has been explored in a wide variety of schemas. 
The simplest is that of taking the output from one program
and sending it as input to another. With the Csound platform, this
is straightforward: instrument input, whether real-time or rendered, 
comes from the textual score statements, and these can be created by programs
made in other languages that either write to files or pipe to the Csound engine (ffitch, 2011, 655).
.. citation (ffitch, 2011)
However, in many modern platforms, tighter integrations are now possible
through application programming interfaces (APIs) that let languages directly call
functions in other languages, as they run. 
One can, for example, run Csound from with a C++ or Python program, interacting 
directly with the Csound engine using the Csound API (Gogins, 2013, 43-46).
.. citation (Gogins, 2013)
One can also run a DSL such as Csound inside a visual patcher, using open-source
extensions to Max and Pd that embed the DSL engine in a Max or Pure Data object (Boulanger, 2013, 189).
.. citation (Boulanger, 2013)
And one can even run a general purpose languauge *inside* a DSL or visual platform,
such as Python inside Csound, (Ariza, 2009, 367)
.. citation (Ariza, 2009)
or JavaScript inside Max (Cycling74 FIX). 
.. citation (Cycling74 docs) FIX

Note that a multi-language platform differs from the previously discussed practice of 
*extending* a patching language or DSL with a GPPL such as C or C++.
In the multi-language hybrid scenario, the embedded GPPL is used
by the *composer-programmer* to make potentially piece-specific code, 
rather than solely by a tools-programmer creating reusable tools in the environment's extension language.
However, it should be mentioned that it is feasible to prototype algorithms in an embedded high-level language such as 
JavaScript and port them later to the extension language (C or C++) 
should they reach sufficient complexity and stability to warrant the low-level work.

In the hybrid scenario, the combination of the various platforms 
provides the programmer with a tremendous amount of flexibility (Lazzarini, 2013, 108).
.. citation (Lazzarini, 2013)
One could, for example, use visual patching to quickly
create a performer-interaction layer, have this layer interact with 
a scored piece in the CSound engine, and simulatenously use an embedded GPPL to
drive complex algorithms that interact with the piece.

The cost of this approach is simply that it requires the programmer to learn
more - a great deal more. Not only must they be familiar with each of the individual
tools comprising the hybrid, but they must also learn how these integrate with each other.
This necessitates not just learning the integration layer (e.g., the nuances of the csound~
objects interaction with Max), but likely also understanding the host layer's
operating model in more depth than is required of the typical user.
For example, synchronizing the Csound score scheduler and the Max global
transport requires knowing each of these to a degree beyond that required of the 
regular Csound or Max user.

Nonetheless, the advantages of the hybrid approach are profound.
The hybrid programmer has the opportunity to prototype tools in the 
environment that presents the least work, and to move them to a more 
appropriate environment as they grow in complexity. 
Numerous performance optimizations become possible as each of the 
components of the hybrid platform have areas in which they are faster or slower.
Reuse of code is made more practical - experienced programmers
moving some of their work to GPPLs can take
advantage of modern development tools such as version control systems,
integrated development environments, and
editors designed around programming. And finally, the complexity 
of algorithms one can use is essentially unlimited.
.. TODO cite Dannenberg on GPPLs for complex algorithms

Conclusion
^^^^^^^^^^^
It is in this hybrid space that Scheme for Max sits.
S4M provides a Max object that embeds an interpreter for
the s7 Scheme language, a general purpose language in the Lisp family (Schottstaed)
.. citation (Schottstaedt) TODO website citation

Given the myriad options existing already in the hybrid space,
we might well ask why a new such tool is justified, why 
specifically it ought to use an uncommon language, and why it should
be embedded in Max specifically rather than some other platform or langauge.
To answer these questions, first we will look at my personal motivations,
and secondly at why I chose Max and s7 Scheme to fulfill them.






