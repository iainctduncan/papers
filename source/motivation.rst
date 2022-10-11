**********
Motivation
**********
 
.. status 
  - 2022-10-08 is at 448 words


Project Goals
=============

Scheme for Max is the result of many years of exploring computer music platforms for composing, producing, and performing music, both commercial and contemporary new music.
The project design came out of my experiences, both positive and negative, with a wide variety of tools, both commercial and academic.
Broadly, the goals I set out to achieve with the creation of Scheme for Max are that the tool should:

#. Focus on programming musical events and event oriented tools
#. Support multiple contexts: scored composition, realtime interaction, and live performance
#. Support advanced functional and object-oriented programming techniques
#. Be linguistically optimized for the target use cases
#. Be usable in conjunction with modern, commercial tools 
#. Support composing music that is impractical on commercial tools
#. Enable interactive development during musical playback

These goals will act as our reference when discussing the sucess of design and implementation decisions.
Let us examine each of these in further detail:

1) Focus on programming musical events and event-oriented tools
-----------------------------------------------------------------
While many approaches to programming computer music exist, the majority of domain specific computer music langauges are designed around the needs of rendering audio streams, acting as higher level langauges for digital signal processing.
Examples of these include Csound, SuperCollider, Chuck, and Nyquist.
My goal for the project is rather to focus the design decisions around the programming of musical *events*, unencumbered by the need to also support DSP processes.
The intent is that the tool will be used in conjunction with other software that handles the lower level DSP activity, whether this is by delegating to other programming languages (e.g. Max, Csound, Chuck, etc.) or by sending messages to external audio producers through MIDI or OSC messages.
The decision not to have the tool handle DSP (i.e. calculating some multiple of 44100 samples per second) significantly reduces the amount of ongoing computation, which opens linguistic possibilities.
The most notable being that use of higher-level, interpreted, and garbage-collected languages becomes potentially feasible. 
I believe that reducing the scope in this way enables an approach that is much more efficient for the act of composing from a user-programmers perspective.

2) Support multiple contexts: scored composition, realtime interaction, and live performance
-----------------------------------------------------------------------------------------------
On modern computers, it is now possible to run complex computer music processes in real time, where "real time" means there are not any audible audio issues from missed rendering deadlines, and the system can run with a latency low enough for the user to interract with music with an immediacy appropriate to playing instruments (i.e. 5-20ms). 
Meeting this goal thus implies that one can iteract with a composition built in the system while it plays while maintaining a feeling of immediacy, and that an instrumentalist ought to be able to perform with objects created in the tool with a latency that allows accurate performances.
However, there also exist types of music where a predetermined score of great complexity is the most appropriate tool, where this complexity may exceed the capabilities of human players. 
Ideally, the project would satisfy all of these context:
it should be usable to create entirely prescored pieces such as the piano etudes of Conlon Nancarrow, where the score is so dense as to be unperformable by human players;
it should be usable in the studio to compose music that is developed through real-time interactions with algorithmic processes and live-programmed tools such as sequencers;
and finally, it should be usable on stage, for example to create performances in which a human being plays physical instruments that interact with the program.

3) Support advanced functional and object-oriented programming techniques
-------------------------------------------------------------------------
By reducing the DSP needs of the tool, it should also become possible to support both a deeper and broader range of programming idioms.
A problem among many DSP focused computer lanugages is that by virtue of needing to meet DSP constraints, they lack linguistic flexibility.
For example, one can not put an arbitrary function into the score in Music-N family languages (i.e. Csound).
My goal is that the tool support advanced functional programming idioms, many of which are now in the broader programming mainstream, having beend adopted into mainstream languages such as JavaScript, Java, Python, and Ruby.
This could potentially include support for first-class functions, lexical closures, message-passing object-orientation, tail recursion, higher-order types, etc.
The support of these programming idioms ought to make it possible for programmer-composers to express their intent more succinctly, with the code better representative of musical intent.


4) Be linguistically optimized for the target use cases
--------------------------------------------------------------------------------------------------------
Support for higher level functional and object-oriented programming idioms can be done in a variety of general programming languages, with the differences between these languages having ramifications on the development process. 
All language design involves tradeoffs - what is most convenient for a small team of expert users early in the process of development can be a hindrance for a large team of mixed expertise working on a very large code base.
Design of the tool should take this into account. 
Composers working on pieces are normally working solo or in very small teams.
The work typically consists of building many smaller projects (relative to the size of a large commercial code base that is), all of which are likely to build on some common set of tools and processes reused across pieces.
The linguistic design of the tool should take this into account and be squarely optimized for this scenario, favouring whatever is most efficient for process of composing and interacting with the system while the program runs.


5) Be usable in conjunction with modern, commercial tools 
----------------------------------------------------------------------------------------------------
A problem with many of the existing academically oreinted computer music tools is that they were designed with the expectation that the user would be using only the tool in question - that in effect, the tool always gets to "be the boss".
For example, Common Music enables composing in a high-level language (Scheme), but to be used in real-time must be run from the Grace host application, where it uses the Grace scheduler for controlling event times.
There is no option to have the Common Music scheduler synchronize to an external clock, and thus combining music coming from Common Music with musical elelements coming from a commercial sequencing program such as Live is not practical.
As commercial music software becomes more and more sophisticated, especially in the areas of sound design and emulation of analog hardware, working in a platform that cannot support use of commercial plugins becomes less and less attractive.
Thus a goal of the project is to ensure that, whatever its design, it lends itself well to composing and producing music where some elements may originate from or stream to commercial tools such as Ableton Live and modern VST plugins.
The user of the tool should not be faced with the choice of using the power of the tool, or having the convenience and audio quality of modern commercial tools available to them.

6) Support composing music that is impractical on commercial tools
----------------------------------------------------------------------------------------------------
While being able to work with commercial tools is a goal, this cannot be at the expense of supporting compositions that are impractical on commercial platforms.
Naturally, commercial music tools are designed around the needs of the majority of users. 
The visual and interface design of sequencers and workstations such as Ableton Live, Logic, and Reaper make assumptions that do not stand up to many 20th century or new music practices.
For example: that there will be only one meter at a time, that meter will not change too frequently, that the time scale of composition used across voices is similar, that the number of voices is not in the thousands, that repeats signs are in the same places across voices, etc.
These design constraints are straightforward to loosen in a high-level textual language.

7) Enable iterative development during musical playback
----------------------------------------------------------------------------------------------------
The last, but not least,  goal of the project is to ensure that all of the goals so far can be achieved in a way that allows interactive development during audio playback. 
Users of modern commercial tools on modern computers do not expect to have to render works offline unless they are doing something quite exceptional in terms of audio processing.
The modern expectation is that one can update a sequence during its loop, for example, and hear the change on the next pass.
This is efficient in terms of composition, and provides the ability to use the ear as the judgement source as ideas are explored.
Languages in the Lisp family (and some others) also allow this kind of workflow during software development, an idiom know as REPL drivent development (REPL being a reference to the Read Evaluate Print Loop).
Code can be updated while the program is running, allowing an exploratory style of development that is ideal during early prototyping, and I believe highly desirable in the composition process. 
Indeed, there exists an entire musical community dedicated to this aspect of music programming, known as "Live Coding", in which the performer takes the stage with minimal advanced material prepared and composes in the programming language in view of the audience (often with the code projected on screen).
The project should support this style of working and performing.

TODO: quote from cope on hearing
