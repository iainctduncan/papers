Introduction - (967 words)
==========================

It is not an exaggeration to say that making music with computers was 
completely revolutionized by the advent of personal computers fast
enough to render audio in real-time almost 30 years ago. The advances
in software synthesis and audio processing in that time have been profound -
audio processing capabilities that were the domain of million dollar recording budgets
at the advent of the compact disc are trivial on a commodity laptop today. 
And yet, in the realm of computer assisted
composition and algorithmic music, things are surprisingly similar to the way they were in the 1990's.
Programming computer music is still principally done with either visual patcher languages
such as Max and Pure Data, or specialist domain-specific textual languages such as Csound
and SuperCollider. Despite the vastly faster processors in home computers, the fundamental
tools of composing "serious music" at the computer have not changed signficantly.
Even mainstream composers use commercial tools that look not all that different from the versions
available in the last century. 
And while some new computer music languages have 
arisen, such as ChucK and Faust, the fundamental patterns of composing at the computer
have arguably not changed significantly.
The main focus of music and audio software developers has instead been on rendering audio better, 
faster, and cheaper.

And yet something has changed in the last 10 years, and in an almost unnoticed way as far as the mainstream
of music software is concerned.
Home computers have now reached speeds such that previously impractical approaches,
approaches abandoned in the advance of real-time audio generation, are once again practical.
One of these, the one with which I am involved, is the programming of computer music in Lisp.
Lisps have a rich history in the field of computer music, going back to the very
early days of the field. With their support for symbolic processing and iteractive development,
Lisps have always been an elegant and productive way to represent and build music.
However, until relatively recently, Lisp has been relegated to the world of non-real-time
computer music. The accepted wisdom has been that one does not try to do anything 
real-time heavy, where heavy means the computer is generating significant audio, with a Lisp or similar
high-level, garbage-collected language. However, with recent advances in processor speeds, running these types
of languages at the same time as heavy audio rendering is now not just practical, but possible
even at latencies usable by serious instrumentalists on stage.

We are seeing a renaissance of the use of dynamic programming languages in music. JavaScript is
used as an extension language in Max. Python is used for algorithmic composition.
Even Haskell is used in live-coding performances. And a new generation of computer
musicians is discovering the elegance, the productivity, and the joy of doing this work
with Lisp, a language that I and others argue is uniquely suited to expressing musical
abstractions in code. 

The Scheme for Max project is, among other things, an attempt to make music programming in a Lisp
- specifically Scheme - accessible and practical to the "regular" computer musician. 
Scheme for Max (S4M) provides an extension to the Max audio/visual programming platform
that embeds a Scheme interpreter, allowing the user to create Scheme programs that interact in 
temporally accurate real-time with the rest of the Max environment.
It can be used to embed single-line programs directly in Max messages, or to build
programs of thousands of lines that do everything from sequencing MIDI
to controlling analog hardware and editing audio.
And it can be used for everything from complex contemporary scored music, to interactive
live improvisation, and to generative and stochastic algorithmic composition.

While I am far from the only one working on new ways to use Lisp in computer music (even in a real-time context),
I believe Scheme for Max achieves something unique. 
By creating an enviroment thats runs seamlessly and flexibly inside the tremendously successful
Max platform (and thus also inside the even more tremendously successful Ableton Live digital audio workstation),
Lisp can easily be used in close tandem (and perfect synchronization) with both popular, 
commercial music tools and specialized, acadmic and research tools.
And by the happy coincidence of Scheme's syntax compability with Max, it can be even be used
in baby-steps - new programmers can add the power of Scheme to their Max patches with
only a few lines of code, and that without even reaching for a text editor.
With Scheme for Max, one is not forced to choose between the power and flexibility of Lisp and the 
convenience and accessibility of commercial music software. 

This paper introduces the Scheme for Max project. I begin by discussing the landscape into which it fits
and its precendents and inspirations. I cover the motivations for the project and the goals by which
I judge its success. I then examine its design and capabilities, and finally, I evaluate
how well I feel it has succeeded and discuss my future plans for it. 

For reasons of space, I have not covered every feature of the project, nor have I delved into the
low-level implementation details and C code. I have limited myself to discussion appropriate
to an interested computer musician, rather than a professional programmer or computer scientist.
That said, the project is open-source and freely available, so the 
the interested reader is encouraged to consult the GitHub project page for further details if desired,
where they will find links to comprehensive documentation, help files, demo videos, and source code.
Code samples presented here in Scheme should be comprehensible to a new programmer, 
but if the reader requires more help, I point them to the "Learn Scheme For Max" online
e-book in which I introduce Scheme programming from first-principles, available again
from the main project page at (https://github.com/iainctduncan/scheme-for-max).


