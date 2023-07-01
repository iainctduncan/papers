Conclusion 
=======================================================================
To conclude, I will evaluate the success of the Scheme for Max project
against the stated criteria and goals, 
discuss the limitations of Scheme for Max in its current state, and introduce 
planned and potential areas of future work.

Evaluation
----------
The Scheme for Max project was started in 2019, with a first usable version released in early 2020.
I have thus been using S4M in musical work for three years, and have done so
in a variety of contexts: producing mainstream electronic music within the Max for Live
environment, creating algorithmic process music in standalone-Max,
and creating large Scheme-based frameworks for improvised sequencing.
This work has encompassed 
using Scheme to control virtual synthesizers, voltage controlled analog
synthesizers, Max audio objects, the Csound engine (hosted in Max), and the
Ableton Live environment through the Live API.
While there is certainly room for improvement, and there are limits in the current
incarnation with regard to realtime performance, the project has been successful overall
in meeting my personal goals for a productive, flexible, and interactive computer
music programming platform. 

I will briefly discuss the success of the project in the context of the previously discussed
project goals. 

1) Focus on programming musical events and event-oriented tools
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
This goal has been met well by working in Scheme, and in the event-domain of Max.
Lisp has made creating my own abstractions of musical events simple to do and has made
exploring various algorithmic music techniques fruitful and enjoyable.
I am able to work in traditional musical constructs (notes, bars, sections, etc.) 
but also able to concoct programmatic support for whatever other musical abstractions I choose to think in.

2) Support multiple contexts, including linear composition, real-time interaction, and live performance
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Scoring compositions with Max is an area I have been recently exploring by creating
scoring tools with Lisp macros. 
I am able to score high and low level time scales in Scheme, and this has been productive,
flexible, and importantly, resulted in readable code that is pleasant to use in the composition process. 
Doing so is particularly flexible, as I can change how the macros
execute for certain tasks, allowing me to, for example, fast-forward through scores by
cueing all called functions up to some playback point.
Representing hierarchies of sections of music as functions (as opposed to just notes)
has also proven to be very productive and makes rearranging material particularly efficient.
Of particular note is that working in text files makes working with multiple time bases very simple.

Meeting the goal of realtime interaction has also been successful. 
I am able to rapidly build programs for interacting with the system over MIDI hardware.
Having done this at various points with all of Max, JavaScript, Csound, and C++, I 
can personally attest that working in Scheme has sped up development immensely.
This comes from both the ability to update only certain sections of code without restarting
pieces or programs, and from the flexibility of the language and its support for symbolic
computing and macros. There do exist limits to realtime interaction stemming from performance
issues, which I will discuss below, but these have largely been surmountable.

Live performance is feasible with some caveats at this point. However, it should be 
clarified that this has not yet been tested in actual stage situations. 
The program is remarkably stable; while crashes were common
during the original stages of development, in my current work this 
does not happen anymore. I would not hesitate to run S4M on stage,
provided programs were adequately tested.
However, running *large* Scheme programs while also rendering audio does, in the current incarnation,
require running with some significant latency (for garbage collection), and certain
program behaviour, such as over a hundred delay calls per second, can lead
to garbage collection issues after some period of running.
This would likely be an issue for users wishing to perform
particularly long pieces that use large Scheme sequencing programs and are
rendering audio on the same computer. These issues are discussed further
below.

3) Support advanced functional and object-oriented programming techniques
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
This is an area in which the project has been successful beyond my expectations.
While there is some work required of the programmer to learn advanced programming in Scheme,
resources for doing so are widely and freely available. 
The flexibility of being able to work on algorithms as the program runs is helpful,
and reimplementing patterns and algorithms that I have previously used in other languages
(Max, JavaScript, C, Csound) has been pleasant and fast.
Scheme's multi-paradigm approach has been particularly welcome - I use a mixture
of imperative, functional, object-oriented, and language-oriented development as the situation warrants.

4) Be linguistically optimized for the target use cases
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Having now developed a substantial body of work in Scheme, both music and tools for music,
I personally feel that the linguistic tradeoffs of Lisp, and of Scheme in particular,
are eminently suited to balancing the needs of the composer-programmer and tools-programmer.
In particular, Lisp macros 
enable the tools-programmer to create high-level abstractions that require
little in the way of code from the composer-programmer, and for which the client code 
used in pieces matches visually the way one wants to think about music as a composer. 

While it would be interesting to also try this kind of programming in a typed language
of the ML-family (e.g., OCaml, Haskell, SML), I suspect from my personal experiences that 
the trade-offs between Lisp and ML languages make the Lisp family more 
productive and satisfying for the immediate needs of the composer-programmer.

5) Be usable in conjunction with modern, commercial tools 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
In this area, the project has again been resoundingly successful. 
I have spent much of the last year (2022-2023) developing a large-scale platform for creating music
in Ableton Live in which S4M is used for improvised sequencing, hardware control, algorithmic processes,
mix automation, and scoring. This has not only worked well, but I am able to combine
it with material coming from regular Ableton Live clips with near-perfect synchronization (infact,
as close to perfect as it is possible to get when using message-events in Max for Live of any kind).
Scheme for Max introduces no further timing discrepencies than does Max for Live itself, where 
jiter of up to one signal vector (approximately 1.5 ms at 44100 samples per second) is possible, and is
usually musically neglible. 

Of particular note, being able to control the Live environment through the Live API with S4M has
been particularly successful. The Live API provides a way for Max patches to programmatically control
most elements of the host in real-time, including mixer settings, device settings, the system transport,
sequencer data, and much more. It uses an object model, the Live Object Model (or LOM), that
is based on hierarchal lists of symbols. Users construct lists of numbers and symbols, and send
these to special Max objects to query and control elements of the API (Cipriani, 2020, 676-680).
.. citation (Cipriani, 2020)
Given that the fundamental model is of lists of symbols, it thus lends itself well to implementation in Lisp.
I have created a low-level interface object for working with the Live API, **live-api**, and an accompanying
Max subpatch (provided with S4M), which together provide the functions
**send-path** and **call**, to which LOM paths can be passed. 
Building on this, adding specific functions to accomplish various tasks with the Live API 
requires minimal code:

.. code:: Scheme

  ;; Live API functions to start and stop clips and get/set device params
  (define (fire-clip track slot)
    (live-api 'send-path (list 'live_set 'tracks track 'clip_slots slot 'clip) 
      '(call fire)))
   
  ; as above, but using back-tick lisp syntax
  (define (stop-clip track slot)
    (live-api 'send-path `(live_set tracks ,track clip_slots ,slot clip) 
      '(call stop)))

  (define (get-device-param track device param value)
    (live-api 'send-path `(live_set tracks ,track devices ,device parameters ,param) 
       `(get value)))

  (define (set-device-param track device param value)
    (live-api 'send-path `(live_set tracks ,track devices ,device parameters ,param) 
       `(set value ,value)))
  

6) Support composing music that is impractical on commercial tools
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
I have found Scheme for Max particularly appropriate for composing and programming works that are
not practical or are difficult on mainstream sequencers (e.g., Live, Logic, Reaper). 
By using Scheme as the top-level orchestration layer, whether through score facilities
or algorithmic processes, implementing pieces with complexities such as shifting or multiple concurrent
meters is straightforward, as is manipulating time across multiple scales at once, such as gradually
changing the tempi of different voices at different rates.

Similarly, S4M is well suited to exploring spectral music and other techniques in which the line between a 
component of a sound and a note from an instrument is blurred. For example, if one wants to apply spectral composition
techniques such as controlling many partials of many sounds independently, this is straightforward by combining
Scheme for Max with the csound~ object, and far simpler than would be the case with plain Max.
Scheme programs can create programmtic loops that send Csound score messages representing activations
of sine waves. Having previously experimented with this using Max, Csound, and the combination of the two, I have
found the addition of S4M to be a tremendous improvment.

Overall, I feel that the achievement of this goal is one of Scheme for Max's strongest points, 
and that S4M has the potential to be a significant contribution to the computer music tool landscape 
in this area.


7) Enable iterative development during musical playback
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The support for interactive development has been another area area in which Scheme for Max has succeeded beyond
my expectations.
For my personal work configuration, I have created two small scripts in Python and Vim respectively,
which enable me to send Scheme code to Max directly from my text editor.
This is achieved by having Vim commands send a selected area (the enclosing parenthetical expression)
to standard input (STDIN) of a short Python program, which in turn sends the text over the local
network as an Open Sound Control message to the Max **udp** object, from where it is passed
to an s4m object for evaluation.

I am thus able to work on code in my editor, and in two keystrokes, send blocks of it to Max to run.
I have used this to create hotkeys for starting and stopping Live, reloading my project,
and resetting the interpreter, and have created short convenience functions that I can evaluate
from the editor to cue works to certain places, mute tracks, arm devices, and the like.
The results of these operations (whatever I make the functions return) are printed on the Max console,
and I am also able to use the Max console to inspect data structures interactively.
Of particular note is the ability to change functions even once they are scheduled.
This capability is something I have found exceptionally valuable while working on algorithmic music.

I feel that this is also an area where Scheme for Max can contribute significantly to the
computer music landscape, providing a live-coding platform that does not need to be insulated from
mainstream tools.

Evaluation Summary
^^^^^^^^^^^^^^^^^^^^^^^^^^
To conclude the evaluation,  I feel the project has been almost entirely successful 
in meeting its stated goals.
The one area of concern that remains is suitability for live performances that use realtime interaction with
large programs and would benefit from being able to run with lower latency. 
However, as the current s7 interpreter was not designed for realtime use (indeed upon the first release
of S4M, its success in this regard was received with suprise and enthusiasm by its author),
I believe this is an area in which future work on optimizing
s7 and Scheme for Max for realtime performance will bear fruit.

Limitations and Future Work
---------------------------
Finally, I will discuss the limitations of Scheme for Max in its current incarnation and
the planned and potential work on and with the project.

Limited Integrations
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
At present, Scheme for Max provides new facilities to Max, but does not integrate
with other Max extensions. As a result, many users who would benefit from S4M are
not aware of its capabilities - it is the kind of thing they need to find on their own.
A notable item of planned work that will help address this is implementing an integration with the Bach project.

Bach (the Bach Automated Composer's Helper) is a long-standing open-source 
project that provides Max objects for accomplishing computer-assisted composition
tasks similar to those available in Lisp-based platforms such as Patchworks and OpusMondi.
Bach does this by supporting what the project calls "lllls" -- Lisp-like linked lists -- a high-level
data type corresponding to the Lisp list in its ability to nest and to hold heterogenous data.
In addition, the Bach project, and its extensions such as Cage and Dada, provide
a wide variety of objects for working with these lists, including sophisticated graphical
elements such as staff notation displays and piano rolls.
Bach uses lllls in a similar fashion to how Max uses dictionaires 
and S4M uses s4m-arrays: the data is stored in a global Bach-controlled registry,
and objects can pass references to these between them (Agostini, 2015, 11-27).
.. citation (Agostini, 2015)
However, while being inspired by Lisp data structures and Lisp-based platforms,
Bach is notably missing an interactive Lisp interpreter itself.
Were Scheme for Max also able to work with Bach lllls, the capabilities of both Bach
and S4M would be significantly increased, and the number of users interested in Scheme
for Max would likely also increase significantly.

One of the next major initiatives planned for S4M development is 
developing an integration layer for Bach, and I have met with Andrea Agostini, one
of the Bach developers, to discuss plans already. This work is planned for the summer and fall of 2023.


Real-time Scheduling 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
As previously mentioned, there is an issue that manifests itself when programs
making particularly large numbers of delay calls are run for long periods, especially while
the computer is also doing significant other work (e.g., rendering audio in plugins).
This manifested itself on my system only after I began working on pieces in Ableton
Live in which 16 different Scheme sequencers were running concurrently, each 
making a new delay call on each 16th note, thus producing on the order of 100 delay
calls per second (depending on the tempo).
After some period of time of running without a reset of the interpreter, such as 10 minutes or
so, CPU use becomes too high for realtime rendering. 
The behaviour is similar to what happens when the audio latency is too low or
the heap size is too high, both situations where the garbage collector cannot finish in time.
It thus seems likely (though at this point this is speculation) that the memory
over which the GC is running has inadvertenly grown, and there is a bug in my 
implementation of the scheduled function callback handling that prevents the garbage
collection of already scheduled functions.
This is the most serious limitation at the moment and is something on which I will be actively
working in the summer of 2023.

Garbage Collection
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
In addition to the bug in my implementation, there is the fact that the s7 garbage
collector is not designed for realtime use. There has been significant work
in recent years on garbage collection algorithms, including the development
of various approaches for soft-realtime gargage collectors such as incremental collectors. 
An incremental collector does not finish
all its work on every pass, and would likely perform better in an audio situation
as the work can be distributed over time. Audio computation is, by its nature,
"bursty", with much work happening during the computation of the audio blocks
corresponding to times with many note onsets. Allowing the gc to leave unfinished
business until a subsequent pass, and giving the user the opportunity to configure 
how this is done, has the potential to significantly lower
the latency at which Scheme for Max can be used.
This, however, will require major development work, and should be considered
a long-term potential area of exploration.

Thread Limitations
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
At present, the user can choose between running the s4m object in the 
low-priority main thread or high-priority scheduler thread, but cannot
run the interpreter in the audio thread.
Were it possible to run an instance in the audio thread, S4M could be
used to produce audio signals at single sample temporal accuracy.
The previously discussed jitter of event onsets in Max is only an issue
for Max *event messages*. Generating timing data as part of an audio stream
is not affected. (Lyon, 2012, 121-179)
.. citation (Lyon, 2012)
This could be useful for those wishing to sequence synthesizers controlled
by control voltages, as this is done in modern audio workstations by outputing
control voltage signals as audio streams. 
While Scheme, as a high-level language with a garbage collector, is unlikely 
to be appropriate for heavy digital signal processing, control voltage
signals do not necessarily need to be created at the same bit-depth or
sample rate as regular audio to be useful. For example, in the Csound language,
it is common to use *k-rate* signals, generated at a divisor of the sample
rate, to control many attributes of synthesis. These can be generated
at lower resolution, and one can use interpolation when a smoother output
signal is needed (Smaragdis, 2000, 126-128).
.. citation (Smaragdis, 2000)
It is thus possible that creating
control rate signals for purposes such as control-volt gates (controlling note onsets),
envelopes, and low frequency oscillators could all be practical in Scheme.

This would require creating a variant of the Scheme for Max object that would
run the Scheme interpreter within the Max audio rendering loop,
and use some form of thread-safe queuing to pass Max messages in and out of the
scheduler or main thread.
It is likely that this would be more practical when used in conjuction with
an improved garbage collector. 
While control rate signals generated from Scheme are unlikely to be possible
with the same latency as those generated from C (given the unavoidable extra
computation), the convenience of doing so may well make the endeavour worthwhile,
especially as computers continue to become faster.

Running in the audio thread could also make it possible to create objects
that combine Scheme for Max and other audio systems in one Max object.
This could be used, for example, to create a Scheme-capable Csound object,
in which Scheme functions that directly access the Csound API could interact
with Csound at a deeper and more temporally accurate level than is currently possible
with the scenario of a separate s4m and csound~ object.

Difficulty of Extension
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Scheme for Max is open-source software, licensed under the permissive BSD license,
enabling any one to extend it if desired. 
This is potentially attractive to users who would like to integrate Scheme code
with processes that will be faster to execute in C.
The s7 foreign function interface makes this quite straightforward - it does not
require much in the way of code to add a C function that can be called from 
Scheme and vice versa, and this was indeed one of the motivations for choosing s7.
However, the programming logistics around doing so are prohibitively cumbersome:
one must go through all the setup necessary to create a Max extension with the
Max SDK, and one must also navigate and alter the main s4m.c file.

A potential area of work to address this would be the creation of plugin system
or automated compilation system for Scheme for Max extensions. 
This could even use other languages that compile to C, such as Zig or OCaml.
While I feel this would be a powerful additional piece of functionality, 
the target user base for this feature is likely very small.
This is thus a long-term potential area of exploration.

Conclusion
----------

In conclusion, I believe the Scheme for Max project has been successful and has the potential
to make a significant contribution to the landscape of computer music programming. 
It succeeds in making programming in Lisp accessible and convenient, and enables
the programmer to work in a productive, flexible, and exploratory manner alongside
commercial and research-oriented tools alike. 
I believe it provides much needed capabilities
to both patching platforms and to textual DSLs as an orchestration layer, and makes
the development of sophisticated and complex music more attainable.
Scheme's flexibility and power make it an ideal glue language 
in a multi-language environment, allowing users to bridge previously separated
tools, approaches, and techniques. 
And finally, I believe, and certainly hope, that the addition of Scheme to Max and 
the Ableton Live platform will introduce many new and potential programmers to the 
joy of programming music in Lisp.







