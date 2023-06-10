Max Background (1280 words)
===========================

(content from old rtf file)

Section 2 - Background on Max/MSP

In order to understand the role filled by Scheme for Max, it is necessary for
us to understand in some detail the Max music programming environment in which
it runs. 

Max, previously named Max/MSP, is the predominant visual programming
environment for creating interactive multi-media in music academia, as well as
in commercial music circles through "Max for Live", an extension to the Ableton
Live digital audio workstation embedding Max in Ableton Live. Created
originally by Miller Puckette in {year} while working at IRCAM, Max was created
so that composers of interactive computer music could change their pieces
without the assistance of a programmer. Max programs ("patches" in the Max
nomenclature) are created by placing visual objects on a canvas ("the
patcher"), and connecting them in a graph with visual "patch cords". Max
objects in a patcher send messages to each other in a data-flow execution
model, whereby a message from one object (the source) triggers execution in one
or more receiving objects, who in turn send on messages to further objects.
Patch execution can be triggered by various forms of real-time input, such as
keyboard or mouse events, MIDI input, and networking events, as well as by
scheduled events through objects such as the “metronome”. Max messages can be
sent implicitly between objects, when one object is attached to another through
a patch cord, or explicitly in dedicated “message” objects. Messages are
represented visually as lists of Max atoms, which may be symbols, integers, and
floating point numbers.  Execution follows a depth first and right-to-left
order, enabling the programmer to deterministically control the execution flow
through the visual layout of the patch cords.  (i.e., A source object sending
messages out to multiple receiving sub-graphs results in the right hand message
path completing execution before moving left, rather than spawning two
concurrent threads of execution.)  When patching, messages can be inspected by
sending them to a “print” object (to print to console) to a message object (to
update the visual object with the message contents).

In addition to the event-based message execution model, Max also supports a
stream-based digital audio execution model. Objects with names ending in the
tilde character (i.e. “adsr~”) are DSP handler objects (“MSP” objects in Max
nomenclature), and are connected to each other through special patch cords
representing a constant flow of digital audio. Internally, Max objects are
implemented to work either in the DSP execution context or the message
execution context (indicated by the presence or absence of the tilde character
in the object’s name), but  DSP objects may also receive event (“regular”)
messages for controlling various paramaters.  For example, a gain~ object
receives digital audio in its top “inlet”, passing it out the bottom “outlet”
after applying a multiplier for altering the signal amplitude;  a message sent
to the right hand inlet of the gain~ object changes this multiplier, and the
gain object will use the received multiplier until receiving another value in
the right-hand inlet. Whenever audio processing is turned on, there will be a
constant flow of audio between connected DSP objects, though it may be zeros.
S4M executes at the event level, using only regular messages and thus does not
implement DSP operations, however some awareness of Max DSP operations will be
necessary to understand both the advantages and limitations of S4M relative to
existing scripting solutions.

Max execution is spread between 2 to 3 threads, depending on various
configuration settings. In regular execution, there will be one (optional) DSP
thread, and two message handling threads. The high-priority thread (also known
as the “scheduler thread”) is intended for any low latency or timing critical
events, and is by default used when messages originate from MIDI input or a
metronome object. The low-priority (also known as the “main thread” and “GUI
thread”) is used for any messages that originate from GUI interaction. The
entire Max patcher is run on each of the high and low threads, meaning that an
object may be active in any thread.  There are additionally objects for moving
messages from one thread to another (“delay”, “pipe”, “defer”, “deferlow”),
which internally put the message received onto the queue for the desired thread
(e.g. “pipe” puts messages on the scheduler queue to be executed in the high
thread after a certain amount of time).

While Max itself is a commercial, closed source tool, it includes a software
development kit for extending Max by writing a Max object (called an
“external”) in either C or C++, and a rich library of open source 3rd party
extensions exist, of which Scheme For Max is one. 

Internally, Max messages are implemented as pair of data entities consisting of
a symbol (required) and an optional array of Max atom structures, where each
atom structure has a member for the atom type and one for its value.  The first
symbol of a message is called the “message selector”, and may be implicit or
explicit. For example, if one creates a message object with an integer as the
contents, the actual message sent by clicking on this object will consist of a
hidden selector of the symbol “int”, followed by a one item array where the
first item is an integer atom, while a message containing multiple integers
would produce  a selector of “list”, followed by an array of atoms. In order to
respond to Max messages, an external must have a handler method for the
selector implemented, though there is also the facility to handle messages
generically and thus to dispatch uncaught messages to handler functions. Thus
execution in an internal begins when a selector handler runs, and the message
structure enables objects to provide a generic API to any other object that is
the same as that used in visual patching. Message handlers are normally
declared as returning void, as in normal execution an object does not respond
to the object that triggered its execution, but instead passes on further
messages out an “outlet”, or has some side effect. Most typically, an object
completes its work by either updating state (a “cold” operation) or by
executing some calculation and then sending a new message with the results out
an outlet (a “hot” operation). Side effects can include updating internal state
of an object, writing to accessible shared data structures (such as tables and
buffers), or directly calling other objects through their methods. Thus, while
the normal flow of execution is for objects to handle messages without
returning values, and pass on further messages, it is possible for some objects
to directly call methods on other objects, getting back a value. There are also
global SDK functions that change the Max internal environment but  do not use
the message passing signature. For example, there exists a global transport
object, and it is possible for an object to directly change the global
transport tempo.

Extending Max thus consists of creating a new module file, that contains a data
structure for object state, some boilerplate functions for class and object
instantiation and destruction, and a series of message handling functions, with
likely some message output functions. The external is compiled using the Max
SDK, and can be added to a plugin directory that Max will scan on boot,
allowing users to use the external in their patchers as if it was a core Max
object. 

Scheme for Max is implemented as an external that embeds the s7 Scheme
interpreter, with various message handlers implemented for both object
operations (e.g. “reset” or “read”) and handlers that translate Max data
structures into s7 structures and then call s7 Scheme functions through the s7
foreign function interface.

