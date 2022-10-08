**********************
Bibilography
**********************

Taube, Heinrich.  *Notes from the Metalevel: Introduction to Algorithmic Music Composition* Taylor & Francis, London UK. 2004

Taube introduces his Common Music 3 algorithmic music environment and the Scheme language on which it is based, and 
covers a wide variety of algorithmic music techniques, along with a brief history of algorithmic music.
The book provides a beginner's guide to Scheme as it is provided in Common Music, using musical examples. 
This includes coverage of Common Music specific tools such as the Common Music "processes", as well as linguistic features in Common Music that come from Common Lisp (on which earlier version were based) such as the loop macro.

Chapters of programming tutorial are alternated with etudes, in which the techniques covered are used in musical examples. 
The etudes progressively cover more complex musical tools and approaches, including microtonality, sonification, probablistic programming, Markov processes, spectral composition, and more.



Simoni, Mary and Dannenberg, Roger. *Algorithmic Composition: A Guide to Composing Music with Nyquist*, University of Michigan Press, Ann Arbor, 2013.

This book introduces the Nyquist algorithmic composition environment (by author Dannenberg) and the SAL language, a high level language used in both Nyquist (and Common music) that is translated to XLISP internally but provides the user with a (likely) more familiar syntax than lisp. 
It begins with a history and overview of algorithmic composition and various tools used.
Most of the book consists of a programming manual suitable for beginner programmers, with chapters organized by programming techniques such as conditions, functional programming, iteration, recursion, etc. 
Chapters include musical examples, and suggestions for further exploration and listening.
Later chapters delve more deeply into complex algorithmic music approaches such as probablistic methods, recursive musical structures, and pattern generation. 
As the Nyquist language is able to handle both synthesis and event generation, some discussion of synthesis is also included.
The book concludes with a very thorough list of further resources for algorithmic composition and Lisp, and an extensive listening list.


Alex McLean, Roger T. Dean *The Oxford Handbook of Algorithmic Music*, Oxford University Press, Oxford. 2018

This book provides an overview of the world of algorithmic music at the time of writing.
It consists of 35 contributions from various authors, organized into four parts, with each part containing a collection of academic papers and a "Perspectives on Practice" section with related artist statements or experience reports.
The parts consist of: "Grounding Algorithmic Music", "What Can Algorithmic Music Do?", "Purposes of Algorithms for the Music Maker", and "Algorthmic Culture".
The contents vary widely, with some chapters focused on musicology and music history, and others discussing technical details of specific tools such as Tidal platform, by editor Alex McClean. 
Of particular value are the resource lists and further reading suggestions in each chapter.


Abelson, Harold; Sussman, Gerald Jay; Sussman, Julie. *Structure and Intepretation of Computer Programs*. 2nd edition, MIT Press, Cambridge Massachusetts, 1996.

Widely considered one of most important computer science texts written, this book was originally intended as an introduction to computer science for MIT students. 
It is written in the MIT Scheme language, and begins from first principles in Scheme.
In addition to how the Scheme language is programmed, the book delves deeply into how a Scheme interpreter actually works.
It begins with the smallest possible subset of Scheme that could be implmented, and progresses through various programming approaches, ssuch as purely functional programming, imperative programming with assignment, object orientation with message passing, recursion, and ultimately, meta-circular evaluators. 
This book is of particular value for understanding the ramifications of different language design features, for example, discussing what must happen in the interperter once we add the ability to mutate variables to a language.


Touretzky, David S. *Common Lisp: A Gentle Introduction to Symbolic Computation*, Dover Publications, Mineola NY, 2013.

A reprint of the 1990 version, this book provides a thorough but accessible guide to the Common Lisp language.
It is notable for its use memory diagrams to help the reader understand the way lists are processed in Lisp (and Scheme), and a detailed guide to the way evaluation and quoting work in Lisp, culminating in coverage of the Common Lisp macro system.
As s7 Scheme uses the Common Lisp macro system (rather than a Scheme specific hygeinic macro system), this book provides an appropriate introduction to macro programming for a user of Scheme for Max.
The book has been made available free in digital form, and thus is an important resource for users of Scheme for Max.


Graham, Paul. *On Lisp: Advanced Techniques of Common Lisp*, Prentice Hall, 1994.

On Lisp covers advanced techniques of Common Lisp programming, with particular focus on macro programming. 
It is an appropriate second book on lisp macros (following Touretzky's introduction) and goes into the problem of avoiding variable capture in macro programming in depth (a.k.a. "hygeinic macros"), as well as advanced macro techiques such as read macros, anphoric macros, and macros that return functions.
The author (the founder of a successful Lisp based startup that sold to Yahoo) also provides his opinion on where and how to use macros most effectively, and how to build software "from the bottom up", beginning with the development of libraries and domain specific language tools.
The book has been made available free in digital form, and thus is an important resource for users of Scheme for Max.


Lyon, Eric *Designing Audio Objects for Max/MSP and Pd*, A-R Editions, Middleton Wisconsin, 2012.

This book provides and introduction to programming externals (of which Scheme for Max is an example) in the C language for Max/MSP and Pure Data.
It assumes a high familiarity with the C programming langauge, but starts at the very beginning of the development of extensions to Max and Pd. 
While the book is now outdated in some places relative to the current software development kits for Max and Pd, the necessary adjustments are not difficult to find in online documentation.
The code chapters begins with a simple external, and proceeds to complex externals such as anti-aliasing oscillators, sequencers running in the DSP loop, and porting a Csound unit generator to Max. 
While the coverage is focused on making audio objects, rather than message-based objects such as Scheme for Max, the explanations of the Max and Pd underlying system in C is extensive and was very valuable in learning to develop Max extensions.


Prata, Stephen. *C Primer Plus, 5th edition*. Sams, Indianapolis, Indiana. 2005.

At 950 pages, this book provides a comprehensive guide to programming in the C langauge.
The Scheme implementation used for Sheme for Max (s7) is implemented in ANSI C, and the Max C SDK is also used for the development of Scheme for Max, thus a thorough resource on older (ANSI-99) C was necessary. 
The book begins from the very beginning of programming in C, and covers all the core features in C programming.


Cipriani Alessandro, Giri Maurizio. *Electronic Music and Sound Design: Theory and Practice with Max 8. Vol 1*, ConTempoNet, Rome, 2019.

The fourth edition of theses books provides the most in depth tutorials on Max programming available. 
Chapters are presented in pairs, with a Theory and Practice chapter for each subtopic.
The theory chapters focus on the sound design and computer music principles in use, while the practice chapters cover the Max objects and knowledge needed to implement the concept in question.  
The topics covered include both sound synthesis and event/message oriented aspects of Max programming, with chapters covering topics such as: additive and vector synthesis, substractive synthesis, control signals, and list and message processing.


