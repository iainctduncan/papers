Introduction 
=============

It is not an exaggeration to say that music making was
completely revolutionized by the advent of personal computers fast
enough to render audio in realtime almost 30 years ago. The advances
in software synthesis and audio processing in that time have been profound -
audio processing capabilities that were the domain of million dollar recording budgets
at the advent of the compact disc are trivial on a commodity laptop today and possible
with even free software.

A side effect of the rapid progress in realtime audio computation is that many techniques 
used principally in the context of *non-realtime* computer music have largely fallen out of the public light.
However, in the last decade computers have reached speeds such that some of the 
tools and approaches previously associated only with non-realtime rendering have become
feasible even in a realtime scenario.
One of these, the one with which I am involved, is the programming of computer music in the
Lisp family of languages.
With its support for symbolic processing, recursion, and interactive development,
Lisp has always been an elegant and productive way to represent and build music (CTN: Dannenberg 1997, 291). 
However, the accepted wisdom has been that one does not try to do anything 
where the same computer is generating significant amounts of digital audio in real time
while running a Lisp or similar high-level, garbage-collected language. 
This is now not just possible, but practical even at latencies usable by serious instrumentalists 
(i.e., sub 20 ms), allowing it to be used on stage as well as in the studio.

I believe we are, as a result, at the cusp of a renaissance of the use of high-level programming languages in music. 
JavaScript is used as an extension language in Max, 
Python and Ruby are used for algorithmic composition,
and even Haskell is used in live-coding performances 
(Lyon 2012, 13-16; Mclean and Dean 2018, 650-651, 597, 258).
And a new generation of computer
musicians is discovering the elegance, the productivity, and the joy of doing this work
with Lisp, a language that I and many others will argue is uniquely suited to expressing musical
abstractions in code. 

The Scheme for Max project is, among other things, an attempt to make music programming in a Lisp
- specifically the Scheme dialect of Lisp - accessible and practical to the "regular" computer musician working in a "regular" studio.
Scheme for Max (S4M) provides an extension to the Max audio/visual programming platform
that embeds a Scheme interpreter, allowing the user to create fully functional Scheme programs that 
interact with the rest of the Max environment, and which do so with high temporal accuracy.
S4M can be used to embed single-line programs directly in visual Max patches, or to build
programs of thousands of lines that do everything from sequencing MIDI
to controlling analog hardware and editing audio.
And it can be used for music of all sorts, from complex contemporary scored music, to interactive
live improvisation, to generative and stochastic algorithmic composition.

While I am far from the only one working on new ways to use Lisp in computer music (even in a realtime context),
I believe Scheme for Max achieves something unique. 
By creating an environment that runs seamlessly and flexibly inside the tremendously successful
Max platform (and thus also inside the even more tremendously successful Ableton Live digital audio workstation),
Scheme can be productively used in close tandem with both popular, 
commercial music tools and the vast library of specialized, academic, and research tools available for Max.
And by the happy coincidence of Scheme's syntax compatibility with Max message syntax, it can be even be used
in baby-steps - new programmers can add the power of Scheme to their Max patches with
only a few lines of code without even reaching for a text editor.
I believe Scheme's consistent, minimal syntax and interactive development style provide an ideal 
introduction to textual programming for the curious Max user.
With Scheme for Max, one is not forced to choose between the power and flexibility of Lisp and the 
convenience and accessibility of commercial music software. 

This thesis introduces the Scheme for Max project. I begin by discussing the landscape into which it fits
and its precedents and inspirations. I cover the motivations and goals for the project, discussing
my own musical and technical desires. 
I examine its design and capabilities. And finally, I conclude by evaluating
how well it has succeeded, discussing its limitations, and outlining my future plans for the project. 

For reasons of space, I have not covered every feature of the project, nor have I delved into the
low-level implementation details and the underlying C code. I have limited myself to discussion appropriate
to an interested computer musician, rather than a professional programmer or computer scientist.
That said, the project is open-source and freely available, so the 
interested reader is encouraged to consult the GitHub project page for further details if desired,
where they will find links to comprehensive documentation, help files, demo videos, and source code.
Code samples presented here in Scheme should be comprehensible to a new programmer, 
but if the reader requires more help, I direct them to my "Learn Scheme For Max" online
e-book in which I introduce Scheme programming from first-principles, available again
from the main project page at (https://github.com/iainctduncan/scheme-for-max).



