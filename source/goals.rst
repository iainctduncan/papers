Project Motivation and Goals 
============================================

Overview
--------
Scheme for Max is the result of many years of exploring computer music platforms for composing, producing,
and performing music.
The project requirements were born from my experiences, both positive and negative, with a wide variety 
of tools, both commercial and non-commercial.
Broadly, the requirements I set myself for the project are that it should:

* Focus on programming musical events and event-oriented tools
* Support multiple contexts, including linear composition, real-time interaction, and live performance
* Support advanced functional and object-oriented programming techniques
* Be linguistically optimized for the target use cases
* Be usable in conjunction with modern, commercial tools 
* Support composing music that is impractical on commercial tools
* Enable iterative development during musical playback

These goals will act as our reference when discussing the success of design and implementation decisions.

Focus on programming musical events and event-oriented tools
-----------------------------------------------------------------
While numerous options for programming computer music exist, most domain-specific computer music languages are 
designed principally around rendering audio, essentially acting as higher-level languages for digital signal processing (DSP).
Examples of these include SuperCollider, ChucK, Faust, and to a lesser degree, Csound. 
My goal for the project is instead to focus the design decisions first around the programming of musical *events*,
unencumbered by the need to also support DSP programming.
The intent is that the tool will be used in conjunction with other software that handles the lower level DSP activity,
whether this is by delegating to other programming languages (e.g. Max, Csound, ChucK, etc.) 
or by sending messages to external audio generators through MIDI or OSC (open sound control) messages.
The decision to have the tool itself not handle DSP 
significantly reduces the amount of ongoing computation, which opens linguistic possibilities.
The most notable being that the use of higher-level, interpreted, and garbage-collected languages becomes feasible,
even in a realtime context. 
I believe that reducing the scope in this way enables an approach that is more productive 
for the specific act of *composing*, in that the features of high-level languages afforded by this decision
are, in my opinion, tremendously helpful when working programmatically with musical abstractions.

Support multiple contexts, including linear composition, realtime interaction, and live performance
-------------------------------------------------------------------------------------------------------
As previously discussed, on modern computers it is now possible to run complex computer music processes in realtime, 
where acceptable realtime performance means there are not any audible audio issues from missed rendering deadlines, and the system can run with a 
latency low enough for the user to interact with the music with an immediacy appropriate to playing instruments (i.e., between 5 and 20 ms). 
Meeting this goal thus implies that the project will enable one to interact with a composition while it plays, 
and that an instrumentalist ought to be able to perform with objects created in the tool with a latency that allows accurate performances.
However, there also exist types of music where a predetermined score of great complexity is the most 
appropriate tool, and where this complexity may exceed the capabilities of human players. 

My goal is that the project should satisfy all of these criteria.
It should be usable for creating entirely pre-scored pieces, such as the piano etudes of Conlon Nancarrow, 
where the score is so dense as to be unperformable by human players.
It should also be usable in the studio to compose music that is developed through realtime interactions with 
algorithmic processes and/or sequencers.
And finally, it should be usable on stage, for example to create performances in which a human being plays
physical instruments or manipulates devices that interact with the program.

Support advanced functional and object-oriented programming techniques
-------------------------------------------------------------------------
The project should support advanced high-level programming idioms, many of which are now in the broader 
programming mainstream, having been adopted into mainstream languages such as JavaScript, Java, Python, and Ruby.
This could potentially include support for first-class functions, lexical closures, 
message-passing object-orientation, tail recursion, higher-order types, continuations, and so on.
The support for these programming idioms ought to make it possible for composer-programmers to express 
their intent more succinctly, with the code better representative of musical abstractions, and should
also make the tool more attractive to advanced programmers who might otherwise
feel they need to use a general-purpose programming language.

Be linguistically optimized for the target use cases
--------------------------------------------------------------------------------------------------------
Support for higher level functional and object-oriented programming idioms can be done in a variety of 
programming languages, with the differences between these languages having ramifications on the development process. 
All language design involves trade-offs - what is most convenient for a small team of expert users early 
in the process of development can be a hindrance for a large team of mixed expertise working on a very large code base.
Design of the project should take this into account. 

I think we can safely assume that composers working on pieces are typically working solo or in very small teams.
The work of a composer-programmer likely consists of building many smaller projects (smaller relative to the size of a large 
commercial code base that is), all of which may build on some common set of tools and processes reused across pieces.
The linguistic design of the project should take this into account and be optimized for this scenario, 
favouring whatever is most efficient for the process of composing and interacting with the system while the program runs,
and favouring the linguistic trade-offs appropriate for the solo developer who is likely to be able to
hold the entire program in one brain.

Be usable in conjunction with modern, commercial tools 
----------------------------------------------------------------------------------------------------
A problem with many of the existing computer music DSLs is that they were designed with the
expectation that the user would be using only (or principally) the language in question - that in effect,
the DSL would always get to "be the boss".
For example, Common Music enables composing in a high-level language (Scheme or SAL), but to be used in real-time,
this Scheme code must be run from the Grace host application, where it uses the Grace scheduler for 
controlling event times (CTN: Taube 2009, 451).
Thus combining music coming from Common Music with musical elements coming from a commercial sequencing program such as 
Ableton Live is not terribly practical if one wants tight synchronization and the "clock-boss" to be Ableton Live.
As commercial music software becomes more and more sophisticated, especially in the areas of sound design 
and emulation of analog hardware, working in a platform or multi-language scenario that doesn't support 
the use of commercial plugins, or at least synchronizing closely with commercial software, becomes less and less attractive to me.
Thus a goal of the project is to ensure that, whatever its design, it lends itself well to composing and 
producing in scenarios where some musical elements may originate from or stream to commercial tools such
as Ableton Live and modern VST plugins.
The user of the project should not be faced with a binary choice between using the power of the project or
having the convenience and audio quality of modern commercial tools.

Support composing music that is impractical on commercial tools
----------------------------------------------------------------------------------------------------
While being able to work with commercial tools is a goal, this cannot be at the expense of supporting 
compositions that are impractical to render purely on commercial platforms.
Naturally, commercial music tools are designed around the needs of the majority of users. 
The visual and interface design of sequencers and workstations such as Ableton Live, Logic, and Reaper 
make assumptions that do not stand up to many 20th century or new music practices.
These assumptions could include: that there will be only one meter at a time, that the meter will not change too frequently,
that the time scale of composition used across voices is similar, that the number of voices is not 
in the thousands, that the piece macro-structure is the same across voices, that all voices share the same tempo, 
and so on. While certainly one can find ways around these assumptions in commercial tools, the work
involved can be laborious and discouraging.
However, these assumptions do not need to be made for a tool using a high-level textual language.

Enable interactive development during musical playback
----------------------------------------------------------------------------------------------------
Finally, a goal of the project is to ensure that all of the goals listed so far can be achieved in a way that 
allows *interactive development* during audio playback. 
As with a hardware or commercial step sequencer, I should be able to update a looped sequence during playback, 
and hear the change on the next iteration of the loop, without having to stop and restart playback.
This workflow is productive compositionally, and provides the ability to use the ear as the judgement source as ideas are explored.
Languages in the Lisp family (and some others) allow this kind of workflow during software development, 
an idiom know as *interactive programming*, or *REPL-driven development* (REPL being a reference to the Read-Evaluate-Print Loop).
In this style of development, code is incrementally updated while the program is running, allowing an exploratory style of development 
that is ideal during early prototyping and during the composition process (CTN: Taube 2004, 8).
For the domain of algorithmic music, interactive development provides the same kind of immediacy one
gets with sequencers that allow updating data during playback. 
Indeed, there exists an entire musical community dedicated to this kind of music programming, 
known as "live coding", in which the performer takes the stage with minimal or no material prepared in advance
and composes in the programming language in view of the audience, often with the code projected on screen
(CTN: Roberts and Wakefield 2018, 293-294).
While *performing* live coding is not a personal goal of mine, the ability to live code while *composing* is.
The project should support this style of working.

Conclusion
----------
By explicitly listing the motivational goals and requirements of the project, I can
better describe why I made the design choices I made (Max, s7 Scheme),
and subsequently evaluate whether the project as a whole is successful.

