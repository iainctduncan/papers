Features and Usage  (6300 words)
====================================================================================================

Status: needs editing, code needs testing, needs citations and example pictures

In this chapter I will outline discuss some of the principal features of s4m from the perspective of a composer-programmer
using s4m to create musical works. 
In the interest of space, I will not cover all of S4M's functionality, however the interested
reader can consult the online documentation in which all capabilities are covered.
(https://iainctduncan.github.io/scheme-for-max-docs/ )

This chapter assumes some familiarity with the Max platform, though readers unfamiliar with Max should be able to follow along.
Where I refer to a message sent to the s4m object, I am referring to a Max message, such as would occur
were a message object connected to an inlet of the s4m object. 

Installation
-------------
Scheme for Max is released as a Max Package, which contains: the s4m and s4m.grid Max externals;
a collection of Scheme source files; a Max help patch demonstrating features and use;
and some example patches and Max for Live devices using S4M.
In order to use S4M, the Max user must downloads the package file and uncompresses it in their Max 
"Packages" directory, after which it will be possible to create an **s4m** object in a Max patch
and to open the s4m help patch for assistance.

Object Initialization
----------------------

Bootstrap files
^^^^^^^^^^^^^^^
When the s4m object is created in a Max patch, it will initialize itself by loading the bootstrap file, **s4m.scm**.
This contains Scheme code on which the documented s4m functionality depends, and also loads several other Scheme dependencies.
This boostrap file is available for inspection and alteration by the user, and it is expected that advanced users will 
alter their bootstrap file, allowing them to automatically load additional files that they intend to be using regularly. 

By default, the boostrap file loads the file **s74.scm**, which contains additional Scheme definitions that are not specific to Max.
s74 is intended to be an extension to s7 to provide convenience features that I assume most users will want available. 
Bill Schottstaedt (author of s7) intends to keep s7 minimal (CITE PERSONAL CORRESPONDENCE), 
thus rather than fork s7, I have added s74 as an optional layer.
It adds various higher-level functions taken from, or inspired by, less minimal Scheme implementations such as Chez and Chicken,
as well as from the related Lisp dialects of Clojure, Racket, and Common Lisp.

The bootstrap file also loads several files that are packaged with s7 itself but are optional: **stuff.scm**, **loop.scm**, and **utilities.scm**.
These files come with s7 itself, and define several macros borrowed from Common Lisp and used in Common Music, such as **loop**, **dolist**, and **dotimes**.  

Once the s4m object has loaded s4m.scm and its subsequent dependencies, it is ready to be used.

Source Files
^^^^^^^^^^^^^
The user can load source files into the s4m object in several ways.
The primary way is to provide a file name as the first argument in the s4m object box in Max, similar to how this done
in many other Max objects that load files, such as the js and buffer objects.
S4M will search the Max file paths (user configured paths for source code search) to find the named file, and will load it if found.
This file is then considered the main file for the object instance.
Double clicking the s4m box will print the full path to the main file in the console.

Sending the s4m object the **reset** message will re-initialize the object, recreating the s7 interpreter and reloading the bootstrap files
and the main file. 
Sending s4m a **reload** message will reload the main file, *without* resetting the interpreter.
The difference here is that if one has made definitions in the interpreter from outside the main file (how this happens will 
be covered shortly), these will not be erased on a reload, but will on a reset.

Sending s4m a **source some-file.scm** message will load some-file.scm and set it as the main source file.
This can be useful in cases, such as in a Max for Live device, where it may be convenient not to have to edit the Max patch to change the main file.
(The licenses required to use Max for Live and to edit in Max for Live are different). 
For example, one might create a device where a text box can be updated and is interpolated into a **source** message,
allowing a user of the device, who may not have the ability to edit devices, to change the main file. 

The **read some-file.scm** will load a file (again searching on the Max file path) without resetting the interpreter or changing the s4m main file.
This is useful when working on a program or piece while it runs: a user can put state variables and score data in one file 
and algorithms in another, allowing them to reload the algorithms file after changing it, while leaving the state and score data alone.

In the event that the user has multiple simlarly-named files on their Max search path, Max will load the first one it finds,
and print a message to the Max console indicating that multiple source files were found and which one it loaded. 
(This is a feature of Max, and has nothing to do with s4m specifically - it comes with the use of the SDK functions to load files from the search path.)

.. TODO: figures of loading some files

Inlets and Outlets
^^^^^^^^^^^^^^^^^^
By default, the s4m object will be created with 1 inlet and 1 outlet. 
The **@ins** and **@outs** attribute arguments can be used at instantiation time to create additional inlets and outlets, to a maxium of 32 outlets.
While these are implemented as Max *attributes*, they cannot be changed in the Max object inspector as their number must be set before object initialization.
They can only be set as **@** arguments in the object box.


Input
--------------------------------------------------------------------------------


Inlet 0 Scheme Expressions
^^^^^^^^^^^^^^^^^^^^^^^^^^
Input to the s4m object works differently depending on whether one uses the main inlet (inlet 0) or subsequent inlets. 
A common pattern in Max objects is for objects to accept "meta" messages in inlet 0 - messages that configure the object,
but are not calls to execute the objects main functionality.
S4M follows this pattern, and supports a number of meta messages, such as the previously mentioned **reset** and **source** messages.
While these message have an effect on the Scheme interpreter, they are handled by the s4m object's C functions,
rather than being passed to the Scheme interpreter for processing. 
I refer to messages that are handled this way as "reserved messages", as they are not meant to be used
as function names in Scheme (technically one could do so, but tracing which component is handling the message will not be obvious).

Any messages to inlet 0 that are not handled as reserved messages are evaluated as calls to the Scheme interpreter.
Internally, S4M adds implicit enclosing parentheses around any non-reserved messages that do not already start and end with parentheses,
and then passes the message to the s7 interpreter for evaluation.
This allows users to make more calls to S4M more visually readable - for example, a message of **my-fun 99** will be treated as **(my-fun 99)**.
The return value from evaluation is printed to the Max console, and S4M provides various facilities for controlling
how much is printed to the console. 

Messages that are surrounded by parentheses are *always* evaluated as Scheme code, and can include nested expressions
(i.e., one could technically call a Scheme function named **reset** this way, though this is not recommended!).

This facility makes it very straightforward for a user to add input mechanisms to their programs. 
For example, if they want a number box to update a Scheme variable, they can use Max's dollar sign interpolation facility
in a message such as **set! var-name $1**, connecting a number box or dial to this message, and connecting the message box to inlet 0.
Moving the number box will now result in Scheme calls to set the my-var variable to the value chosen.
This capability significantly reduces the amount of code the user must write to make interactive patches when compared to the Max js object, 
as the js object requires explicit handler methods to be made for any input (CITE docs).

A result of this input facility is that when one uses a symbol in a Max message sent to inlet 0, the interpreter will take this
to be a variable name in the running Scheme program. 
Should the user wish to pass in a *symbol* (not refer to a variable), they can use the standard Scheme leading single quotation mark to quote the symbol.  
The can also use an s7 *keyword* (a symbol beginning with a colon, that always evaluates to itself), in which case evaluation 
does not change the fact that the keyword is a symbol.
Conveniently, Max does not assign any special meaning to either single quotation marks or colons, thus this presents no issue from Max messages.
(One can, for example, even name various Max objects such as buffers with colon-prefixed names.)

For the majority of use cases, this is the easiest way to send input to the Scheme interpreter.
When one wants to do something with an argument from Max, one can use message interpolation or the **prepend** object 
to turn the incoming argument into a Scheme expression, and have the interpreter evaluate it.

There do exist, however, several convenience functions in case users want to handle input with even less boilerplate in their Max patch.
The **f-int**, **f-float**, **f-bang**, and **f-list** handlers are automatically invoked when the s4m object receives an
integer, float, bang, or list respectively.
If the user defines a function so named, it will be invoked.
(They are named **f-{{type}}** simply to avoid the inconsistency that would result had we used **int**, **float**, and **bang**, 
as **list** is a built in Scheme function.)

Inlet 1+ 
^^^^^^^^
There are times when it is not desirable that the incoming symbols in Max messages be taken as Scheme variable names (because they are evaluated).
An example of this is dealing with incoming OSC messages, where one may not have full control over the incoming parts of the messages, 
and thus inserting single quotation marks to indicate symbols is perhaps not possible.
For this kind of situation, input to inlets over 0 are not automatically evaluated as Scheme code.
This means that in order to accept input to inlets over 0, one must create a handler function and register it with 
Scheme for Max using the **listen** function. 
The call to register a handler with **listen** takes arguments for the inlet, type of incoming
message, and the handler function, where the type of incoming message can be one of: integer, float, symbol, or list.
This handler function always receives its arguments in a bundled list, allowing handlers to be generic,
and also allowing the same handler to be registered for multiple types of message. (It is up the handler
to deal with this accordingly).

Below is an example of defining a listener for a message consisting of an integer, and 
a second for a list.

.. code:: Scheme

  ;; handler message, all arguments are bundled into the args variable
  (define (my-int-func args)
    (let ((int-arg (args 0)))
      (post "got the int:" int-arg)))

  ;; register it to listen for integers on inlet 1
  (listen 1 :int my-int-func)

  (define (my-list-func args)
    (let ((list-length (length args))
          (first-arg   (args 0)))
      (post "received a" list-length "item list, first item:" first-arg)))
 

Output
--------------------------------------------------------------------------------
The s4m object can output a standard Max message from any of its oulets using the **out** function.
This is accomplished by passing the **out** function an outlet number and either a single value or a Scheme
list of output values. 
Output values must be either integers, floats, symbols, or strings.
Code to output various messages is shown below.

.. code:: Scheme

  ;; output number 99
  (out 0 99)
  ;; output a max list of ints
  (out 0 (list 1 2 3))
  (out 0 '(1 2 3))
  ;; output a bang
  (out 0 'bang)
  ;; output the value of my-var
  (out 0 my-var)
  ;; output the max symbol "set"
  (out 0 'set)
  ;; output the max message "set 99"
  (out 0 (list 'set 99))


Sending Messages
--------------------------------------------------------------------------------
In addition to sending messages by outputting through the s4m object's outlets and connecting the
s4m outlets to destination objects, we can also send messages directly (without patch cables)
to objects that have been given a Max **scripting name**. 
On instantiation, and additionally on receipt of a **scan** message, the s4m object
iterates over all objects in the same patcher as the s4m object and recursively through
any descendent patchers. On finding any object with a scripting name, a reference
to the object is placed in a registry in the s4m object, implemented as a Scheme hash-table
with scripting names as keys and object references as values.
The **send** function can then be used to directly send messages to these objects.
This uses the message sending functionality in the Max SDK, and is functionally equivalent
to sending a message to a destination object via a patch cable.

If one wants to send a message to a destination that is not contained in the same patcher
(or a child patcher), one can use a Max **send** and **receive** pair of objects, giving
a scripting name to the send object. 

A variant of send exists, **send***, which flattens all arguments to allow conveniently
sending list messages.

Code to send messages to a named destination is shown below:

.. code:: Scheme

  ;; update the contents of a number box that has scripting name "num-target"
  ;; by sending it a numeric message
  ;; we quote num-target below as we want the symbol num-target, not the
  ;; value of a variable named num-target.
  (send 'num-target 99)
  
  ;; send a message box a message to update to the contents to "foobar 1 2 3"
  (send 'msg-target 'set 'foobar 1 2 3)
  
  ;; if we had the list ('foobar 1 2 3) in a variable named "msg":
  (send* 'msg-target 'set msg)
  
This facility allows one to orchestrate complex activity in a Max patch without
having predetermined connection paths.

Buffers & Tables
--------------------------------------------------------------------------------
Max contains two objects for storing arrays of numerical data: the **buffer** 
and the **table**. Buffers are typically used to store floating-point sample
data while tables are typically used to store integers. Both provide
the programmer the ability to use indexed collections, and can have names,
allowing objects that are not connected to a main buffer or table object
to interact with them. The main use for buffers is as a container
for audio data that can be played back in various ways as well as 
manipulated programmatically by reading from and writing to them. 
An interesting feature of buffers is that the abstraction of the buffer
of samples can be accessed by multiple Max objects by referring to the
buffer by name, the name being provided as an argument to the **buffer**
object that instantiates the buffer. 

Scheme for Max provides a collection of functions for reading and writing
to and from buffers and tables, as well as convenience functions for 
getting the length of table or buffer and verifying if there exists
a particular named buffer or table (**buffer?**, and **buffer-samples**,
**table?**, **table-length**). 

The simplest way of using these is to read or read a single index
point. However, in the case of buffers, at the C level, Max locks a buffer before a read
or write operation to ensure thread-safety in case other objects (that
may be running in other threads) attempt to access the same buffer.
Similarly, Max provides an ability to **notify** on a buffer update,
so that objects sharing the buffer (such as visual display objects) 
can update. 
Consequently, interacting with a collection of samples from the same 
buffer with a Scheme loop that makes repeats
calls to **buffer-ref** or **buffer-set!** is slower than necessary,
as locking, unlocking, and notifying will happen on every loop interation.
For these scenarios, s4m functions exist to copy blocks of samples between
Scheme vectors (Scheme's basic array collection) and buffers, in
which optional starting index points and number of samples are provided as arguments.
At the C level, these lock, unlock, and notify only once, running
direct low-level memory copies for all samples.

.. TODO: buffer example code

While buffers (and to a lesser degree, tables) are implemented around the primary use case
of storing sample data, they can be used for storing any numerical
data in arrays. The s4m facilities thus provide a complement to the
Max functions, enabling iterative array manipulation with more convenient
looping constructs than are built in to Max.

.. TODO: buffer example

Dictionaries
--------------------------------------------------------------------------------
Another high-level data collection abstration provided by Max is the Max
**dictionary**, a key-value store in which one can store a wide variety
of Max data types as values, and use integers, floats, symbols, or strings 
as keys. Max provides a rich API for working with dictionaries, including
the ability to refer to them by name across many objects, serialize them
to JSON, update them from JSON files, and even send references to them
between objects. There are a number of Max objects that have the ability
to dump their contents to dictionaries, and various display handlers. 
(TODO examples, cite docs)

The Scheme equivalent of a dictionary is the **hash-table**, a key-value
store that can hold any valid Scheme object, either as a key or value.
S4M provides functions to interact with Max dictionaries as well
as convert between Max dictionaries and Scheme hash-tables. 
Notably, these are recursively implemented: converting a Max
dictionary to a Scheme hash-table will convert all values in the 
dictionary, regardless of depth of nesting.
Interesting, Max supports numerically indexed arrays in dictionaries,
which can contain mixes of types, even though
there is no way of directly working with arrays of heterogenous types 
in the platform.
Thus, the use of a dictionary as a way to have simple arrays is common
in Max programming (TODO CITE). S4M converts these nested arrays
to Scheme vectors, where these vectors can contain a mix of types 
(including further nested dictionaries and arrays).

Similar to Common Lisp and Clojure, s7 Scheme (but not all Schemes) provides
a **keyword** data-type, which is a symbol starting with a colon that
always evaluates to itself. (TODO CITE). These are commonly used as keys in
hash-tables (TODO CITE). This is a convenient practice in Max, as one does not have worry about
quoting or unquoting as data passes through evaluation layers such
as when messages from from Max through inlet 0 of an s4m object.
Conveniently, Max allows naming dictionaries with a leading colon,
allowing us to use keywords even at the top level.

S4M provides the functions **dict-ref**, **dict-set!**, 
**dict->hash-table**, **hash-table->dict**, and **dict-replace**
for working with dictionaries.
Of note is that these provide some convenience functions
for dealing with nested dictionaries without having to nest
calls to dict-ref and dict-set!.

.. code:: Scheme
  ;; get a value from max dict named "test-dict", at key "a"
  (dict-ref 'test-dict 'a)

  ;; get value at key "ba" in nested dict at key "b"
  (dict-ref 'test-dict (list 'b 'ba) )

  ;; get the value at index 2 in the nested vector at key "c"
  (dict-ref 'test-dict '(c 2) )

  ;; set a value in max dict named "test-dict", at key "z"
  (dict-set! 'test-dict 'z 44)

  ;; set a value that is a hash-table, becomes a nested dict
  (dict-set! 'test-dict 'y (hash-table :a 1 :b 2))

  ;; set value at key "bc" in nested dict at key "b"
  (dict-set! 'test-dict (list 'b 'bc) 111)

  ;; set a value that is a hash-table, creating an intermediate hash-table automatically
  (dict-replace! 'test-dict (list 'foo 'bar) 99)

  ;; create a hash-table from a named Max dictionary
  (define my-hash (dict->hash-table 'my-max-dict-name))

  ;; update a Max dict from a hash-table
  ;; if the Max dictionary does not exist, it will be created
  (hash-table->dict (hash-table :a 1 :b 2) 'my-max-dict-name)


s4m-arrays
--------------------------------------------------------------------------------
While in Max one has access to arrays of hetergenous type through dictionaries,
and arrays of integers and floats through buffers and tables, there is
no direct interface to statically sized arrays of a single basic C type.
Scheme for Max fills this gap by providing its own internal implementation of arrays,
the **s4m-array**, which provides an interface to static C arrays.
These are created with the **make-array** function, providing a name,
size, and type, where type may be **:int**, **:float**, **:char**, or **:string**.
These arrays are stored by name in a global registry in the Scheme for Max
code, allowing multiple s4m objects to use them to share data between instances.
As the arrays are created in the s4m global registry, these persist beyond
the life of a single s4m object, and are freed only on a restart of Max.

S4M provides functions for working with these point-by-point,
(**array-ref** and **array-set!**) as well functions for copying
blocks of data to and from Scheme vectors (**array->vector**, **array-set-from-vector!**).

.. code:: Scheme
  
  ;; create a 128-point array of integers, naming with a keyword 
  (make-array :my-array :int 128)

  ;; copy a value from one array to another
  (array-set! :destination-array dest-index 
    (array-ref :source-array source-index))

  ;; update a block of data from a Scheme vector
  (array-set-from-vector! :display 0 #(0 1 2 3 5 6 7 8))  

Notably, unlike Max buffers, tables, and dictionaries, s4m-arrays do not
include any thread protection. They are intended to be used in cases
where speed of access is important, leaving synchronization issues up to the
programmer. 

The motivating use case for s4m-arrays was that of driving graphic displays
of tabular data in as close to real-time as possible, such as one
one would when making a tracker-style interface to a sequencer.
(TODO CITE trackers?) In this scenario, one might have one s4m instance
that contains a sequencer engine that works with tabular sequence data,
and a second instance, running the low-priority thread off a timer, that drives
a graphic display of this data.

In this scenario, we have an implementation of a **producer-consumer**
pattern: we know that only the sequencer will produce data, writing to the
s4m-array, and only the consumer will read the data. 
We also know that if the consumer should get partially updated data
(perhaps its thread runs part way through an update from the producer),
this is not a serious problem - some ripple in the display as data refreshes
is acceptable to the user in the name of real-time performance.
(TODO CITE this happening in modern DAWS??)
Given our strict producer and consumer scheme, and our acceptance of ripple,
the s4m-array is preferable to using data structures such as buffer or table,
which will run more slowly on account of the thread-synchronization code
that they run. 

The s4m.grid object
--------------------------------------------------------------------------------
The missing piece for the scenario just discussed is a display element, 
and for this purpose Scheme for Max provides the graphical display object, the **s4m.grid**. 
The grid provides a simple visual grid on which we can draw values in each cell.
It is implemented as a Max UI object (CITE), built in the C SDK,
and has several attributes that may be changed in the Max inspector window,
controlling spacing, font size, striping, conversion to MIDI note names,
vertical versus horizontal orientation, 
and whether a value of zero should be drawn or remain blank.

The grid can be updated in two ways. The first is to send it a Max list message.
On receipt of a list, the grid will update each cell from the list, iterating
either by rows then columns or vice versa, depending on the orientation attribute.
The second update method is to read directly from a named s4m-array, on 
receipt of the **readarray** message. 
In this case, the grid iterates through the array (again according to the
orientation attribute), updating each cell. 
The updating from an s4m-array has the (speed) advantage that no Max atoms or
message data structures need to be created for each argument - the
numerical arguments are read directly from contiguous memory in the display
function.
When driving a large grid from a timer, this has a significant impact on the 
processing load created. The result of this is that it is practical to have
several large grids updating multiple times per second without creating
problematic loads.

The intended workflow is that the programmer will have
a component of their sequencing system acting as a view driver. 
This can be code that runs on a periodic timer (perhaps every 100 to 200 ms),
queries which ever Scheme structures they want to view (such as 
reading the sequence data vectors from a Scheme sequencer),
and writes the data which we want to view into an s4m-array (acting
as the producer).
Either on a separate timer (or the same timer if desired), a
grid element will be sent the display message with the name of this
array, acting as the consumer.

In this workflow, the s4m-array acts as a *framebuffer* (CITE),
a data structure that virtually represents a display element, and
the entire system acts as an *immediate mode GUI*. (CITE)
Immediate mode GUI's decouple the display from the data production,
making it possible for the display to accurate reflect the current
state of sequencing data regardless of how it was set. 
This is desirable in an algorithmic music platform as one cannot
assume that the state of the sequencing data originates from
GUI actions - it could come from autonomous processes, network
requests, MIDI input, and the like. 
The disadvantage of an immediate mode GUI is the processing cost:
it is constantly running data queries and updates regardless of whether
data has changed. 
Thus, the low-level speed optimizations of the s4m.grid and s4m-array 
facilities make immediate mode displays practical where previously they were not.
In my personal experiments, comparison with the Max built in jit.cellblock
(the built in tabular display element) showed very significant speed 
increases - from unusable with one 64 x 16 grid, to usable with 
four 64 x 16 grids with minimal CPU impact.

.. TODO screen cap of my grids


Scheduling Functions (needs editing and code testing)
--------------------------------------------------------------------------------

Arguably the most important feature of Scheme for Max
is its advanced scheduling and timing features, and their integration
with the Max threading and transport subsystems. 
On a surface level, they are quite straightforward: s4m provides
functions that allow one to schedule execution of an arbitrary Scheme
function at some point in the future, the simplest of this being the
**delay** function.

In the example below, an anonymous function is created and put on the scheduler
to execute in 1000 milliseconds. The call to delay returns a
handle that can be used to cancel the scheduled function if desired.

.. code:: Scheme
  
  ;; create a lambda function that prints to the console,
  ;; and schedule it for 1 second in the future, saving the handle
  (define my-handle
    (delay 1000 
      (lambda () (post "Hello from the future!"))))
  
  ;; cancel its execution
  (cancel-delay my-handle)

The delay function has variants that allow one to schedule
in ticks, based on the Max global transport, at 480 ticks per beat,
and in quantized ticks where execution time is forced to align to a tick
boundary regardless of at what time the call to delay was made.
The tick delay functions will also only execute if the Max transport is
playing, making it possible to synchronize scheduled functions accurately
with other Max sequencing tools or with the Ableton Live built in sequencers.

.. code:: Scheme
  
  ;; schedule my-function for 1 quarter note from now, if transport running
  (delay-t 480 my-function)
  
  ;; schedule my-quantized-function for 1 quarter note from now, but forcing now be
  ;; interpreted as on the nearest 16th note boundary from the time
  ;; of the scheduling call
  (delay-tq 480 120 my-quantized-function)
  
At an implementation level, these use the Max C SDK's **clock** functions, 
which allow one to precisely schedule
execution of a callback function. It is important to note that in 
modern versions of Max, these functions are designed to preserve
long-term temporal accuracy regardless of immediate jitter.
Jitter, in this context, refers to the difference between the scheduled
time and the actual execution time as one would see if analyzing recorded audio.

For optimal real-time audio performance in Max, the recommended
settings are to have "audio in interrupt" and "overdrive" enabled. (CITE Max docs) 
When both of these are turned on, the Max engine alternately runs
a DSP pass (calculating a signal vector of samples), and a scheduler
thread pass. This means that real time of events stemming from 
the scheduler thread execution can be off by up to a signal
vector of samples, resulting in small timing discrepencies.
However, what is important to note is that the clock functions
in current versions of Max compensate for this in the long run such
that this discrepency does not accumulate. 
Tests I made during development confirmed that even after long
playback times, clock driven functions did not accumulate jitter,
and that if one sets the Max signal vector size to 1 sample, 
the timing on the clock functions is sample accurate.

The Scheme for Max functions use these clock facilities by putting
a reference to the Scheme function passed to the delay functions
into a special internal registry, keyed by their handles. 
When the C clock callback runs, this is retrieved and the function
is taken from the registry and executed.

There is nonobvious capability granted by the combination of this facility 
and the nature of Scheme's lexical scoping. This is that
Scheme for Max uniquely makes it possible to easily specify a function
to be run in the future, with that function using values that can
be taken from the environment *at the time of scheduling*, 
or *at the time of execution*. 
This is not possible in regular Max patching, and while it is technically
possible using JavaScript, it would be of limited use in JavaScript
as the timing of said functions can potentially have unusable 
levels of jitter due to the fact that the js object only executes
in the low priority thread.

This facilty makes algorithms and real-time interaction possible in
interesting ways. One can, for example, create a patch in which
dials or hardware change some musical value. This can be captured,
so to speak, at scheduling time, such that when the function executes in the future,
the value *where the dial was* is used. Alternatively, one can
use a function that explicitly looks in the global environment 
for settings at run time.
Below is an example of a function that uses both of these facilities.
The value read from **dial-1** will be used as it was at scheduling
time, while the value from **dial-2** will be looked up in the future.

.. TODO check and verify this code

.. code:: Scheme
  
  ;; capture the value of g-dial-1 and use it in the function
  ;; look up the value of g-dial-2 in the future
  (delay-t 480 
    (let ((dial-1-capture g-dial-1))
      (lambda ()
        (let ((dial-2-now (eval 'dial-2)))
          (post "dial-1 was:" dial-1-capture)
          (post "dial-2 is:" dial-2-now)))))

In combination with s4m's capability of updating code interactively while
programs run, this scheduling flexibility enables the programmer-performer
to edit algorithms used in algorithmic music even once they are already
scheduled. 

Finally, these facilities also enable a workflow known as
"self-scheduling" or "temporal recursion" (CITE lazzarini) in which
a repeating function schedules the next pass of itself. 
This facility enables the composer to create interesting evolving
generative proccesses, as each pass of a function can change the data,
or even the code, of the next pass of the function. One might think 
at first glance that this would result in an accumulation of timing
jitter, but the implementation of Max clocks does indeed make this possible
while preserving sample-accuracty over long periods of time, something
I have tested extensively.

Below is an example of a function scheduling itself. The first iteration
of this function would need to be manually created. The temporal recursion
will stop when the variable **playing** is set to false.


TODO: test this code

.. code:: Scheme

  ;; a variable to turn on and off playback
  (define playing #f)

  ;; a function that schedules itself to run on every quarter note
  ;; and keeps track of how many times it has run
  (define (my-process runs)
    (post "run number:" runs)
    (if playing
      (delay-t 480 
        ;; create an anonymous function that wraps the next call to my-process
        (lambda ()(my-process (+ 1 runs))))))

  ; a function to start the process
  (define (start)
    (set! playing #t)
    (my-process 0))

  ; a function to stop the scheduling chain
  (define (stop)
    (set! playing #f))

The above can, of course, be combined with the previously mentioned
lexical scoping capabilites, enabling implementations of complex,
interactive, algorithmic process music in succint and flexible code.
The Scheme for Max online documentation and example repositories contain
examples of interactive algorithmic sequencers implemented in this way.
      
Garbage collector functions (needs editing)
--------------------------------------------------------------------------------
As a high-level, dynamically-typed language, Scheme includes a 
**garbage collector** (a.k.a. a **gc**), a language subsystem that cleans up
and frees unused memory that has previously been allocated by the program.
Garbage collection spares the programmer the tedious work of manually allocating,
tracking, and freeing the memory used by variables in the language.
It is a standard feature of most modern high-level programming languages,
such as Java, Python, Ruby, JavaScript. 
The problem with garbage collection when one is doing soft real-time
work (where "soft" means that missed deadlines are undesirable, but not catastrophic,
such as would be the case in avionics software), is that the gc
must periodically do a pass in which it scans over the program
memory, looking for unused memory allocations and freeing them, and
this can be a computationally expensive process when the program is large or
uses large amounts of data.
Further complicating things, garbage collection is of indeterminate duration,
as the work that the gc must do is heavily dependent on the particular algorithms
and data structures used in the program over which it is running
(i.e., a program of some gven size and memory use may require more or less
garbage collection depending on how precisely it is written).
(CITE).

For theses reasons, the use of garbage collected languages is not common
in real-time audio programming, where the program must be doing constant calculations
to produce streams of samples.
Scheme for Max, however, is intended to be used at the *note level*,
rather than the *audio level*, thus the time between blocks of computation
is potentially much higher (the temporal gap between notes), giving us 
(potentially) adequate time for the gc to finish. 
All modern DAWs allow a user to configure the output audio buffer size,
corresponding to the number of samples the program pre-computes, and thus
also corresponding to the latency of real-time operation.
While the s7 garbage collector will cause issues if attempting to run
Scheme for Max programs with a very low buffer and latency (e.g.,
64 samples or less), on a modern computer and moderately sized program,
the gc is able to run within the latency period of an output buffer of 128
or more - sufficiently low for playable latency.

Nonetheless, a heavy Scheme for Max program can run out of time for
the garbage collector, resulting in audio underruns and audible clicks.
For these cases, Scheme for Max provides some additional facitilites
for controlling whether and when the gc runs.

The first of these, perhaps counterintuitively, allows one to control 
when the gc runs on timer, allowing it to run *more* frequently
than is the case if one does not force a gc run. This increases
the overall work the gc does, but lowers how much work it must do
on each pass, allowing each pass to complete more quickly.

Sending the **gc-disable** message to the s4m object disables automatic
running of the gc, allowing one to explicitly force a run by sending
the **gc-run** message, which can be triggered off a timer such as a
Max metronome. In my experience, setting this to somewhere between
200 - 300 ms works well and provides better real-time performance
than is posssible using the automatic gc.

A second facility is to change the heap size of the Scheme for Max object.
The lower the heap size, the faster the gc runs as it must run over less
memory (CITE bill correspondence). The s4m object allows an initial
**@heap** attribute to set the starting heap size. This works well so 
long as one checks through testing whether the heap allocated will be big enough.
If it is not, a *heap reallocation* will be required when s4m is out of memory,
which is very likely to cause audio issues. 
Users can use s7's built in gc reporting by turning on the **gc-stats** flag,
which will result in output to the console on each gc pass, including the
amount of memory it must run over. This can be used to ensure the initial
heap size is adequate.

Finally, if the performance of piece is of a reasonable duration, the
user may elect to disable the garbage collector all together.
This is done again by sending the **gc-disable** message, but without
using any forced runs following it. In this case, the heap will likely
need to be quite large as the memory use of the program will grow as it
runs, with no unused memory ever freed. In programming parlance, 
this is referred to as a "memory leak", and is normally considered 
a bug. However, given that the the size of audio sample libraries
used in music production is now in the gigabytes (CITE), it is certainly
not unreasonable for one to let a program grow in memory on the order
of megabytes!

Summary
--------
This covers the main features and capabilities of Scheme for Max
as of version 1.0. 
Additional functions and variations on those covered here are
covered in both the official online documentation and in the Max help file.  
Additionally, various tutorials with examples using the functions
covered here are available, and are linked from the main GitHub project
page.







