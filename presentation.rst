Introduction 6 min.
- Scheme for Max
  - what we will cover
    - background and related work in computer music
    - design decisions and motivations for scheme for max
    - features of the project
    - how well it succeeded, limitations, future work

Background
- goal: 
  - better computer music programming platform for an advanced user
  - both for the composer-programmer and tools-programmer

- computer music platform families
 
- DSLs
  - a textual language designed around musical use
  - historical: MUSIC N family
  - current: Csound, SuperCollider, ChucK, Faust
  - advantages
    - less for a composer to decide and learn
    - easier to get up and running making music
  - disadvantages
    - less flexibilty
    - harder to program complex algorithms
- Visual Patchers
  - visual dataflow languages in the Max and Pd family
  - advantages
    - easy to create performer interaction
    - no assumptions about how we think of music
  - disadvantages
    - musical abstractions must be decided by the programmer
    - complex algorithms are cumbersome
    - large software is difficult
- General Purpose languages
  - libraries vs frameworks
  - examples of library approach STK, PortMidi, PortAudio,  
  - examples of frameworks
    Common Music, Nyquist, Common Lisp Music, JUCE
  - advantages
    - flexibility
    - implementing complex algorithms is not hard
    - modern dev tooling
  - disadvantages 
    - much more to learn, decide, and build

- Multi-language or Hybrid approach
  - definition
  - examples
    - Csound API 
    - clients to SuperCollider
    - JS object in Max
  - advantages
    - one can use each platform for its strengths
  - disadvantage
    - much more to learn

- Scheme for Max
  - sits in the hybrid space
  - embeds a GPPL, specifically Scheme, in the Max visual patcher.

- why make those choices?

- why Max?
  - maturity and breadth of objects
  - works well with commercial tools
    - hosts VST instruments
    - synchronizes well
    - runs in Max4Live
  - designed originally around event-oriented real-time interaction 
    - while DSLs like csound can now do this and max can
    - these orginal design drivers still effect what is easy or cumbersome in the platform

- why not JS in Max?
  - low priority thread

- why a lisp
  - support for symbolic computation appropriate for music
  - historical work
  - interactive development

10 min - get it down

********************************************************************************
Features 8 min

- running code from files 
  - load and run main file as argument
  - loading subsequent files
  - reloading certain files

- running code from Max messages
  - syntax compatibility
  - using Max messages as Scheme code for input

- receive Max messages as input

- interacting with Max global data
  - buffers
  - tables
  - dictionaries

- sending Max messages without patch cables

- scheduling events
  - using closures
  - integration with master clock
  - accepts beats or ms
  - can be quantized
  - closures of data
  - self scheduling


********************************************************************************
Conclusion (5 min)

Successes:
- performance is better than expected, and is totally usable for realtime sequencing
  - temporally accurate
  - works well in Max 4 Live
- language design
  - much more productive to code in
  - code is minimal, readable, and representative of music
  - advanced resources available
- interactive development
  - my use in Vim

Limitations
- realtime performance does hit limits
- if programs are very large the gc can take too long
- no running in the audio thread

Future Work
- fixing the memory leak
- integration with the Bach Project
- work on the real-time garbage collection
- versions that can run in audio thread





