********************************************************************************
Scheme for Max
Background and related work
Design decisions and motivations
Features and capabilities
Evaluation, limitations, future work

********************************************************************************
High-Level Goals
Build a better computer music programming platform
Target advanced users and programmers doing hard things
Help both composer-programmers and tools-programmers

********************************************************************************
Domain-Specific Languages for Music
Music N, Csound, SuperCollider, ChucK, Faust
Easy to get making music
Less to decide
Less flexibility
Cumbersome for programming complex algorithms
Cumbersome for building large tools

********************************************************************************
Visual Patching Languages
Max, PureData, Reaktor, VCV
Easy to get started
Easy to build performer interactions
No assumptions about music structure
A lot to decide to get making music
Cumbersome for programming complex algorithms
Cumbersome for building large tools

********************************************************************************
General Purpose Programming Languages
C, C++, Python, Ruby, Lisp, etc.
Libraries: STK, PortMidi, PortAudio
Frameworks: Common Music, Common Lisp Music, JUCE
Very flexible
Appropriate for complex algorithms
Good tools for large software projects
MUCH more to learn, decide, and build

********************************************************************************
Multi-Language Hybrids
Csound in C or Python, Csound or SuperCollider in Max, JavaScript in Max
Use strengths of each component
EVEN MORE to learn!

********************************************************************************
Scheme for Max
Uses Scheme, a GPPL in the Lisp family
Embeds this in Max (and Pure Data) 
... where it can work with other (Csound, SC, Faust, VSTs)
Essentially a cross between the js object and Common Music

********************************************************************************
Design Decisions


********************************************************************************
Why use Max?
Maturity, popularity, breadth of objects
Plays well with commercial tools
Designed around musical events rather than DSP
Has an open-source equivalent

Why not use Max's JavaScript object?
Only runs in the low-priority thread
Dog's breakfast of a language
Not open-source, no Pd version 

Why use Scheme (a Lisp)?
Symbolic computation and macros are great for music
Large body of historical and related work
Interactive development 

Features and Capabilities

Running Scheme files
Load a main file
Load other files additively
Write and read to/from file system

Evaluating Max messages as code
Max and Scheme syntax compatibility
No need to write callbacks

Receiving Max messages in callbacks
- useful for external messages (OSC)
- creating callbacks

Interacting with Max data structures
- buffers, tables, dictionaries
- recurive conversions
- fast vector copying

Sending Max messages
Send messages without cables
Enables use as orchestrator
Enables patcher scripting & live-coding

Scheduling Events
Scheduling anonymous functions
Milliseconds, beats, quantized beats
Transport integration
Lexical scoping and closures


What has worked
Performance and stability suitable for real-world use
Scheme and Lisp are great for music
Interactive development is awesome

Limitations
Realtime limits (garbage collector)
Currently a memory leak bug
Does not run in audio thread

Future Work
Integration with Bach Project
Work on realtime garbage collection
Run in audio thread

