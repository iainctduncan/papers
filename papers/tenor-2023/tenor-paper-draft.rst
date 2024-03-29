Draft content for the tenor paper

Introduction
------------
Scheme for Max (S4M) is an open-source extension to the Max music programming platform (formerly Max/MSP).
S4M enables running Scheme programs as part of Max patches, and host integration facilities  
make it possible for users to script, live-code, automate Max events, and triggere tightly timed
Scheme functions from the Max scheduler. The S4M interpreter uses s7 Scheme,
an open-source Scheme Lisp implementation created and maintained by Bill S. of CCRMA.
Max is a visual programming environment, but does not include a built in score system. 
In this paper, I will demonstrate how Scheme for Max 
enables one to use Lisp macros to make a flexible and powerful
text-based score system, and discuss ramifications and advantages of this approach. 
I will demonstrate this by creating a small score system similar to that used in the Music-N family
of applications, such as Csound. 
While some familiarity with programming on the part of the reader will be helpful, I will begin
with a short review of Scheme syntax in the hopes that it will make the paper accessible to those with 
limited programming experience.
Finally, it should be noted that the material covered is also applicable to the Pure Data (Pd) music programming
environment through the companion project, Scheme for Pd.

Text Score systems
------------------
In this day of high-resolution displays and fast computers, one might wonder why we 
would want to use a plain text score system, such as the Csound score format, so
let us start there. 

For those unfamiliar with Csound, a Csound score file is a plain-text file consisting of
line terminated statements. There are several kinds of score statement, but this discussion
will be limited to the principal type, the instrument statement, 
where each statement corresponds to one instrument event. 
The most usual circustance is that each instrument event corresponds to a single musical note, 
but they could also signify any temporal event handled by Csound orchestra instruments (chords,
automation of author instruments, effects, etc.). 

An example of a Csound score i-statment is the below:

.. code::

  ;instrument  start  duration  pfields p4    p5    p6    etc ...  
  i 1          0      2                 .9    4.5   .33  

This tells Csound to initiate an event from instrument 1, starting at time 0, lasting for 2 beats,
using the (arbitrarily long) list of additional parameter field data points: .9, 4.5, .33, etc.
In modern versions of Csound, p-fields (as the parameter points are called) may also contain strings.
Score statements may also use some special characters in place of numbers, where these alludie to previous statements,
such as the . and + symbol to repeat and increment respectively.

.. code::

  ; three sequential notes of duration 1, at beat 0, 1, and 2
  i 1   0   1   .9
  i 1   +   .   .8
  i 1   +   .   .8

Note that this differs from a midi message in a several ways:

* The number of data fields is abitrarily long, and does not need to specified in advance.
  All space-separated tokens until a new line will become note parameters passed to the instrument code.
* Numbers are specified in floating point numbers, giving us arbitrary precision 
  up to the maximum supported by the system, usually 32 or 64 bits (integers are interpreted as round number floats).
* One score event encodes both the start and end time of an event (through the duration value) rather 
  than a seperate message being needed to indicate the end of an event, as is the case with MIDI
  note-on and note-off messages. In this respect, the score statement is more like a traditional musical score.

While simple by today's standards, this simple format, stored in plain-text, has a number of advantages.

Accuracy
^^^^^^^^^
It is straight-forward in a text format to express exactly what we want to happen and when.
In contrast with MIDI, we can have as many parameters for an event as we would like,
confident that all parameters will be used in the very first calcuation of audio, as opposed to potentially
arriving to the instrument after the first sample of audio is rendered, as can be the case with MIDI.
This because sending many paramaters to a MIDI instrument requires sending many sequential
controller messages over a serial network.  Additionally, we are given 32 or 64 bit accuracy
in floating point numbers, compared to the MIDI 7 and 14 bit numbers. (CITE)

Tooling
^^^^^^^^^
We can use sophisticated text-oriented programming tools for editing, searching,
storing, and analysing. Many text editors have small programming languages built
in to them for generating text programmatically, and  we can run easily run external programs over text files, 
allowing algorithmically assisted composition at the editing stage.
(TODO example of CSound score processing tool CITE)

Size
^^^^^^^^^
Plain text scores are very small. While modern computers can deal with very large files,
small score size still opens up possibilities. These can be transmitted over networks with
very low latency, used on micro-controllers, or more easily analysed in large collections for
machine learning purposes.

Interoperability
^^^^^^^^^^^^^^^^^
Coverting text formats to other text formats is a simple task compared to dealing with 
binary formats. It is not hard to have a client program input a text score and translate it as we desire. 
It is also simple to send a text format over common protocols such as Open Sound Control.

While certainly not the right fit for every task, given these advantages, I propose
that a similar text score format is useful even in graphic oriented platforms such 
as Max and Pure Data.

Additionally, there are some advantages specific to create a score system with Scheme macros
that go beyond the facilities given us by Csound scores.


Scores as data versus scores as programs
----------------------------------------
In the case of a regular Csound score, we have a text file with score data, separate from
our program files. 
(They may be embedded together in a container file, but fundamentally the distinction holds.)
The composer creates a score, saves it, and then runs the Csound program to play or
render the music. 
Or perhaps they run some other program to ingest and transform the score prior to using the the result
being used by Csound.
In any case, the score is read and parsed as a block of text by a consuming program
(the parser), and likely saved in an intermediate data structure prior to use by the main engine.

Now a parser is a complex part of the internals of the platform and
is not something a composer-programmer would normally touch. (I will call the person principally 
programming to make music the composer-programmer, in 
contrast with the developer-programmer, who is building something like Csound.)
In the case of Csound, the composer-programmer will, in addition to the score files, likely 
write orchestra files to specify what will be done with the note data. 
But it is extremely unlikely they would change how the parsing itself works. 
This would involve digging in the Csound source and recompiling Csound itself, and requires
a programming proficiency an order of magnitude greater than is required to simply use Csound.
If I wanted to significantly change or extend the score language for my given piece, for all practical 
intents and purposes, I would need to write a translation layer.
For example, perhaps I want to add another symbol with a special score meaning, 
much like the "." and "+" - doing so would be a formidable endeavour.

In contrast, when we make scores with Lisp macros, this is not the case. 
There is, to be sure, more to learn to get going. But once up and running, 
extending the semantics of our score system requires very little additional code and
it is work that is practical for a composer-programmer working on a particular project.

The reason this is possible is because a macro based score sytem does not put the
score in a seperate data file that is parsed and consumed by a main program.
Rather, the score content is a part of our executable Scheme program itself.
It is handled no differently than any of the other Scheme files we use in a
piece when we use Scheme for Max. 
Lisp macros allow us to extend Scheme syntax such that text in a form suitable for 
scoring becomes an extension to the language and we can intermingle this
with regular Scheme function definitions and invocations as we see fit.
This has the ramification that extending or altering the working of the
score format requires nothing more than overriding functions or macros in our 
(Scheme) score file or files we include into our score. 
In essence, we do not use a score file format at all - rather we extend the language to
allow programming in a score-like domain specific language (DSL).

This approach comes with  advantages beyond those previously itemized for Csound scores. 

* We can mix function calls and data however we would like. In addition
  to constant symbols and numbers, we can embed function calls directly in score lines,
  and should we wish, we could make ways to indicate that the function call should happen 
  either at the time of parsing, or at the time of the scheduled event. 

* We can redefine how score events are interpreted part way through a piece. 
  This can include changing both how the score works and how the instrument works,
  and part way through can again mean either partially through the body of text or the time elapsed.

* We can easily create layers of score abstractions, allowing us to reuse blocks of score
  more readily and more flexibily. Score statements are function invocations,
  and can thus receive whatever parameters we want and call other functions in turn.

This approach is of course not without its own limitations and challenges,
but my own experiences of working this way with Scheme for Max over the last year have been 
overwhelmingly positive and productive.

Let us now look at how we can use Lisp macros to build a score lanugage for use in our Schem programs.


A review of Scheme functions and evaluation
-------------------------------------------
Before we delve into macros, we should review Scheme function syntax and evaluation.
(If you are familiar with Lisp or Scheme, you can probably skip this section.)

Scheme code is composed of s-expressions, which are parenthetically enclosed series 
of white-space delimited tokens, such as **(a b c d)**.
When the Scheme intepreter evaluates an s-expression, it interprets the first 
token as a symbol representing a function, invoking it with the 
rest of the tokens used as arguments to the function. 

In the examples below, lines beginning with a ; are comments, and
are ignored by the interpreter, while lines beginning with > are the
printed return value from the intepreter in an interactive REPL (read-evaluate-print-loop) session. 

.. code:: scheme

  ; call the + function, returning 6
  (+ 1 2 3)
  > 6

  ; call the list function, which returns a list comprising the arguments
  ; note the printed representation of the returned list is enclosed in parentheses
  (list 1 2 3)
  > (1 2 3)

Expressions may be nested, in which case they are evaluated from the innermost outwards,
with inner expressions being substitued with their return values prior to outer evaluation.

.. code:: scheme

  (* (+ 1 2) (+ 3 4)) 
  ; expands behind the scenes first to (* 3 7)
  ; which then returns 21
  > 21
  
Nested calls to the list function produce nested lists.

.. code:: scheme

  (list (list 1 2) (list 3 4))
  > ((1 2) (3 4))

Variables are defined by binding symbols to values with the **define** statement. 
Evaluating a variable returns the value to which it is bound. 
(Note that in s7 Scheme, the define statement itself also returns the value bound.)

.. code:: scheme

  ; define a variable named my-var.
  ; the define call also returns the value
  (define my-var 99)
  > 99
  ; subsequently evaluating the symbol returns the bound value 
  my-var
  > 99

Functions are defined with either the **define** or **lambda** statements (which are identical but for syntax). 
Below are two examples of defining a function named "sum-list" that receives two arguments and 
returns a list consisting of the two arguments and their sum.

The lambda form returns an anonymous function. In the example below, we 
create a function that takes two paramaters, **a** and **b**, and
then returns a list. The return value of the lambda (which is our function) is then
bound to the symbol **sum-list** through the define call.

.. code:: scheme

  (define sum-list 
    (lambda (a b) 
      (list a b (+ a b))))
  
There is also a short hand version of the above in which the function name
is the first value in the parameter list expression.

.. code:: scheme

  (define (sum-list a b)
    (list a b (+ a b)))
  
After making these definitions, we can call sum-list by evaluating an s-expression with the
sum-list symbol in the first slot. 

.. code:: scheme

  (sum-list 1 2)
  > (1 2 3)
  ; with a nested expression as an argument
  (sum-list 1 (+ 2 3))
  ; expands first behind the scenes to (sum-list 1 5)
  > (1 5 6)
  
There is one piece of Scheme we need further before we can tackle macros.
In the examples above, we can see that the interpreter returns lists in 
a printed form that looks exactly like an s-expression used in our program code. 
This is no accident, and is in fact the defining feature of the Lisp family of
languages, of which s7 Scheme is one. (CITATION)
If we construct a list programmatically, we can then execute it as if it is a 
regular block of code by using the **eval** function.

.. code:: scheme

  ; define a list of our function and two arguments
  (define list-code (list sum-list 1 2))
  > (sum-list 1 2)
  ; now we have a list of a function and two arguments
  ; passing this to eval treats it as code we want to run
  (eval list-code)
  > (1 2 3)

Thus, we can build programs programmatically. There is no difference to the
interpreter between a list we make with calls to the list function and one we make
by typing code. 

Finally, **eval** has a mirror-image form, **quote**. 
When we want to use a token in our program but have the intrepreter treat it as a symbol 
(rather than evaluate the symbol and use the bound value)
we can use the quote function, or its short-form, the single quotation mark.

.. code:: scheme

  ; bind the value 10 to the symbol my-var
  (define my-var 10)
  > 10
  ; evaluating my-var returns the bound value
  my-var
  > 10 
  (eval my-var)
  > 10
  ; but wrapping it in quote gives us the symbol
  (eval (quote my-var))
  > my-var
  ; short cut
  (eval 'my-var)
  > my-var
  ; which can be nested back and forth 
  (eval (eval (quote my-var)))
  > 10

Thus we can build Scheme programs dynamically by using quote to build lists,
and then calling eval on these lists. When you say reference to Lisp as
the "programmable programming language", this is what is meant. (CITE)

That was a whirlwind tour, but now we are ready for macros! 

Lisp Macros
------------------------

A Lisp macro is a special type of callable form, with two key differences from a function.
While s7 is a Scheme, the macro system it supports is the Common Lisp style def-macro variety,
rather than a Scheme specific variety such as syntax-case or syntax-rules.

First, when we use a macro, it looks like we are calling a function, but the rules of evaluation 
for the arguments are different.  
When a function is called, any arguments to the function are reduced as far as they can be
prior to being used by the function body. If we pass in **(+ 1 2)**, the code in the function
only sees the value **3**. 
In contrast, when a macro is called, the arguments to the macro are used by the body
*as they are written*. If we pass **(+ 1 2)** to a macro, the macro receives and uses the
s-expression **(+ 1 2)**, not the reduced value. In effect, the arguments
are received by the body *as if they were quoted*. (CITE?)

The second difference is that whatever the macro returns is then evaluated.
The normal scenario being that the macro returns a list that we want to have treated
as code. It builds a list programmatically as in our earlier examples, and the
evaluation of that list (executing the code we have built programmatically) is automatic.

Put another way: arguments are passed in as symbolic expressions, and the return value
is evaluated again. Our job is to build and return a program (as a list), and the macro
will run it when it returns. (This can involve recursively nested macros, but we can
ignore that for the purposes of this discussion.)

The way this works is that macros are run in two passes. The first is the "macro-expansion" pass,
which receives the symbolic (code-block) arguments from the macro call. The macro-expansion 
returns an s-expression and in the second execution pass, this code expression is evaluated.
By separating these two stages, the macro is able to interpret how expressions passed to it
should be handled. It can transform them into alternative syntax forms, or evaluate them, as it sees fit.

Let's look at some examples. 
Take the following definition of a function to return a list of its three parameters.
(The post function prints arguments to the console. In S4M, printed output is
prefaced by "s4m:")

.. code:: scheme

  (define (to-list-f a b c)
    ; print and then return a list of a, b, and c 
    (post "args in list:" (list a b c))
    (list a b c))

When we call this in our REPL, we see both the output from the call to post, and the returned list.
If we pass in a nested expression as one of the arguments, 
we see the value is reduced before it gets to post.

.. code:: scheme

  (to-list-f 1 2 (+ 3 4))
  s4m: args in list (1 2 7)
  > (1 2 7)

Now let us do the same thing, but as a macro, using the define-macro form.

.. code:: scheme

  (define-macro (to-list-m a b c)
    ; print and then return a list of a, b, and c 
    (post "args in list:" (list a b c))
    (list a b c))

Let us try the same call:
  
.. code:: scheme

  (to-list-m 1 2 (+ 3 4))
  s4m: args in list (1 2 (+ 3 4))
  s4m: Error
       attempt to apply an integer 1 to (2 7) in (list a b c)

Two things have happened here. First we see the output from 
the post call worked, and showed us that the body of the macro is 
working with the s-expression **(+ 3 4)**. 
And then we see an error message. The error message is coming
from the automatic evaluation of the list we are returning. 
The list returned is **(1 2 (+ 3 4))**, and if try to evaluate that
at the repl, first **(+ 3 4)** is reduced to **7**, and then the interpeter
complains that it doesn't know how to apply the function 1 to
the arguments 2 and 7.

.. code:: scheme

  (eval (list 1 2 (+ 3 4))
  s4m: Error
       attempt to apply an integer 1 to (2 7) in (list a b c)

If instead we pass arguments that will make our macro build a list where the first element
is indeed a function, all is fine. Let's try valid argument lists.   

.. code:: scheme

  (to-list-m list 2 (+ 3 4))
  s4m: args in list (list 2 (+ 3 4))
  > (2 7)

  ; pass in the + function
  (to-list-m + 2 (+ 3 4))
  s4m: args in list (+ 2 (+ 3 4))
  > 9

To help the intrepid macro programmer, Lisps include a **macroexpand** function.
Enclosing a macro call in macroexpand will execute the macro, but skip the final
automatic evaluation of the returned list.

.. code:: scheme

  (macroexpand (to-list-m + 2 (+ 3 4)))
  s4m: args in list (+ 2 (+ 3 4))
  > (+ 2 (+ 3 4))

And we can see that if we use macro expand with our problematic list, we get
back our list, but we do not get an error message as the interpreter no
longer tries to evaluate it at the end.

.. code:: scheme

  (macroexpand (to-list-m 1 2 (+ 3 4)))
  s4m: args in list (1 2 (+ 3 4))
  > (1 2 (+ 3 4))

There is another way we can avoid the error we see above, and that is to write
our macro such that we do not evaluate our problematic list. We can do this
by returning some other harmless list, and while this may seem counterproductive,
it give us a way to write functions that receive s-expressions. Our macro becomes
a callable that works on symbolic arguments, potentially produces side-effects 
(such as our call to post), and returns a value that is harmless and ignored.

.. code:: scheme

  (define-macro (to-list-m2 a b c)
    ; print and then return a list of a, b, and c 
    (post "args in list:" (list a b c))
    ; maybe we do something else with our list too
    ; now we return false, which evals as false without error
    #f )

Calling it with any arguments is now safe; no error is produced.

.. code:: scheme

  (to-list-m2 1 2 (+ 3 4))
  s4m: args in list: (1 2 (+ 3 4))
  > #f

  (macroexpand (to-list-m 1 2 (+ 3 4)))
  s4m: args in list (1 2 (+ 3 4))
  > #f

The reason macroexpand produces the exact same output is because evaluating false
returns false, no matter how many times we do it. We say false is a value
that evaluates to itself. 

An alternative for advanced programmers is to find a way to return a quoted
list, so that the macro evaluation pass gives us the list we want (rather than a call to a function).
This requires rather more involved Lisp programming, so it will not be explained
here, but is included for the experienced or curious. (See a Lisp reference on 
"backquoting" for an explanation.)

.. code:: scheme

  (define-macro (to-list-m3 a b c)
    (post "args in list:" (list a b c))
    `(list (quote ,a) (quote ,b) (quote ,c)))
  
  (to-list-m3 1 2 (+ 3 4))
  s4m> args in list: (1 2 (+ 3 4))
  > (1 2 (+ 3 4)) 
 
The important business for our discussion is that we can pass code-blocks in the form of parenthentical
expressions or symbols into macros, which can then run programs that interpret these almost however we would like.
The parenthetical expression can be a list of arbitrary symbols that can be parsed, transformed,
split, merged, and so forth, and this is done simply by code that is running in the interpreter and
that can use any other code definitions currently valid in our intepreter environment. 
Now we have everything we need to make score systems with macros. 

A Simple Macro Score 
---------------------
Given that we are now able to handle arbitrary s-expressions as we see fit, we can now
make a macro that will be used similarly to a Csound score. If we are content with 
having to enclose our lines in parentheses, this can be expressed concisely. 
The result of processing each score line will be a call to a schedule function,
which will put a future call to an output function on to the Max scheduler, through the
S4M **delay** function. This is used to schedule a function at some point in the future,
expressed in milliseconds.

Our desired interface with the score will look like the below, where **score**
is the score macro, **play-note** is the output function to which we want to delegate
output, and **500** is the number of milliseconds per beat.
Note that because this is a macro, we do not have to have defined **C2** and **D2**;
the macro will receive those as quoted symbols. We can leave making sense of those
to our output function (**play-note**).

.. code:: scheme

  ; put three sequential 1 beat notes on the scheduler
  (score play-note 500
    ; beat  arbitrary note data
    (1.0    .5 C2 .99)
    (2.0    .5 D2 .74)
    ; etc
  )

We will use a **for-each** loop in the score macro to iterate through all the score lines,
passing them to a **lambda** function that in turn uses a **schedule** helper. Note that
for-each returns nothing (it is called to cause side effects), so we do not need to 
explicitly return false to avoid the errors previously encountered. Note also that
the signature of the macro uses the dot notation to bundle an arbitrarily long group of s-expressions
of score events into a list, **exprs**. Our macro expects to receive a symbolic name of
an output function argument, **output-fn-sym**, which will be eval'd to get our actual
output fun. This of course depends on the output function and the schedule function
being defined so we will start with those. Our output function, **play-note**, could use any Max
facility for playing audio (through the Scheme for Max interface), but for this example, it will simply print to the console.
Our schedule function simply destructurs the list of event parameters, using the
first (the beat) to calculate the start time for the scheduled event, and making a new
list with the remaining event parameters as the arguments to pass to the output function. 
 
.. code:: scheme

  (define (play-note . args)
    (post "play-note" args))
 
  (define (schedule beat ms/beat output-fn note-data)
    (delay (* beat ms/beat) 
      (lambda ()(apply output-fn note-data))))

  (define-macro (score output-fn-sym ms/beat . exprs) 
    (for-each 
      (lambda (expr)
        (let ((beat (first expr))
              (output-fn (eval output-fn-sym))
              (evt-data (rest expr)))
        (schedule beat ms/beat output-fn evt-data)))
      exprs))

This is all we need to have a simple score player. Let's try it out.
(You'll have to take my word that the bottom three lines are appearing 500 ms apart!)
  
.. code:: scheme

  (score play-note 500
    (1.0    .5 C2 .99)
    (2.0    .5 D2 .74)
    (3.0    .5 E2 .49)
  )
  s4m> #<unspecified>
  s4m: play-note (C1 E1 G1) 
  s4m: play-note (F1 A1 E2) 
  s4m: play-note (G1 B1 D2) 
  
Adding extra functionality is surprisingly simple. Let us add the ability
to increment times, as Csound does. In this version, a plus sign can be used
to indicate that we want to increment the beat by one from the previous beat.
This requires us to keep track of the beat we are on with some more advanced
looping, but I hope it is evident that, provided the programmer has learned
Scheme, this is not much additional work.

.. code:: scheme

  (define-macro (score-2 output-fn-sym ticks/beat . exprs) 
    (let ((output-fn (eval output-fn-sym)))
      (let out-loop ((beat 0) (exprs exprs))
        (let* ((evt-data (first exprs))
               (cur-beat (if (eq? (evt-data 0) '+) (inc beat) (evt-data 0))))
          (schedule cur-beat ticks/beat output-fn (rest evt-data))
          (if (not-null? (rest exprs))
            (out-loop cur-beat (rest exprs)))))))

And now we can use the **+** symbol to increment beats:

.. code:: scheme

  (score-2 play-note 480
    (1.0    .5 C2 .99)
    (+      .5 D2 .74)
    (5.0    .5 E2 .49)
    (+      .5 F2 .74)
  )

Further extensions are likewise straightforward. We could, for example, decide
we don't like enclosing each statement in parentheses, and come up with an alternate
syntax. Provided we give some indication other than a carriage return of a new line, this
would simply require a new loop at the beginning that ingests all the tokens of all the expressions
and then explicitly groups them into the per-event lines. 
For example we could preface end all lines with a semi-colon.

.. code:: scheme

  (score play-note 500
    1.0    .5 C2 .99 ;
    2.0    .5 D2 .74 ;
    3.0    .5 E2 .49 ;
  )

Length: 4700 words

TODO: 

- some additional possibilities
- limitations: characters we can't use, didn't discuss capture problem 
- conclusion

Citation possible

- Touretzkey - GISC
- Graham - On Lisp
- ?? SICP on evaluation?
- Csound book on scores
- some csound score utility
- s7 documentation on s7 approach to hygeine
- perhaps something from Notes from the Metalevel or Simoni algorithmic composition



