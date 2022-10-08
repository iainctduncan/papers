********************************************************************************
Related Work
********************************************************************************

To understand the design decisions and justification for creating s4m, it is necessary that we be familiar with some related projects, 
especially the Max JavaScript object and the Common Music algorithmic toolkit. 

The Max JavaScript object 
==============================

Overview
--------
From a functionality perspective, the closest thing to the s4m object is the Max built-in ``js`` object. 
The js object embeds an ECMA5 interpreter (an older JavaScript implementation) in a Max object, and provides a wide variety of integration functions. 
The user provides a filename as an argument to the js object, and this file is loaded from the file system on object instantiation. 
The js object allows the user to write JavaScript code that runs in the Max process, and for this code to receive and send Max 
messages (through the object inlets and outlets) and have direct access to a variety of Max data structures and API (TODO footnote) calls. 
For example, a user can access named Max buffers, tables, and dictionaries, can interact with the Max global transport, 
can schedule code to run at a later time through the Task interface, and can script the patcher through the thispatcher interface 
(i.e. create and connect new objects in a Max patch).
In M4L, there also exist Live API integration functions, enabling users to develop Ableton "control surfaces" in JavaScript. 
(A "control surface" in Live's parlance is a script that handles midi input from hardware controllers and triggers activity through the Live API. 
This can include triggering clips, controlling devices, and interacting with the Live transport.)

It is important to note that the ``js`` object does not run in the Max DSP thread - activity in the JavaScript interpreter can only be 
triggered by incoming Max messages or by scheduled calls using the Task facility. 
One can calculate audio in code and fill an audio buffer that will be later be played, but this is essentially non-realtime calculation.

There also exist two related objects, ``jsui`` and ``jstrigger``. 
The former is a version of the ``js`` object with an OpenGL interface for making graphical user interface widgets. 
The programmer provides a ``draw`` function with OpenGL code. The latter is an object in which the user can type a JavaScript 
expression directly in the object parameters, and this will be executed on receipt of Max messages.

The JS object is the most popular (based on forum activity) way for Max users to work in a patcher in a textual programming language.
It is the only way of running an interpreted language in a patcher that is officially supported by Cycling 74. 
In fact, it was using the js object combined with the disatiscation with the limitations of the js object that led me to the development of s4m.

Language
--------
The interpreter runs JavaScript 1.8.5, "a Mozilla specific superset of ECMAScript 5." (CITE Max docs) 
ECMA5 was released in 2010 and superseded by ECMA6 in 2015. 
It is not clear why the js object has not been updated to a more recent version of ECMAScript - I have been unable to find anywhere this is covered in the official documentation from Cycling 74.

Thread of Execution
-------------------
The most notable limitation of the js object is that it is limited to running in the Max UI thread. 
When messages from the scheduler thread are received (i.e. originating from MIDI input, metronomes, or scheduler functions) they are implicitly defered and run on the next pass of the UI thread, as if they had passed through a **defer** object. 
This implicit deferal has several ramifications. 
The first is that timing of execution of JavaScript code is unreliable.
The UI thread is meant to be used for any activity that could take too long for the audio or scheduler thread to execute, such as redrawing the onscreen graphics and file system interaction. 
The upshot of this is that it take little activity in a Max patch for events originating from the js object to be audibly delayed, thus rendering the js object impractical for building and real-time event producers or for altering real-time events.

The second ramification is that patches that connect messages coming from the scheduler thread to a js object have their call chain broken. 
As covered in the background section, Max messages execute synchronously, with all activity down a branch of a patch completing before execution runs down sibling branches. 
This means it is normally straighforward for a user to trace the flow of messages and their side-effects visually, following the depth first and right to left ordering of branch execution.
When part of a branch includes a call to an object that creates a delay, this visual representation is made inaccurate. 
Objects that delay messages a delay include defer and pipe, which delay messages on to the scheduler thread, and defer and deferlow, which delay messages on the UI thread (with deferlow placing them at the end of a queue).
With one of these objects in the patch branch, execution will stop at the delaying object as if it is the end of a branch, continuing back of the branch and to the left. 
Complicating this is the fact that this behaviour depends on the thread of execution of the message - a defer object does nothing if the incoming message is already in the UI thread.
The result of this is that if the js object is used in a patch that handles scheduler thread activity, the visual layout of the patch is no longer an accurate representation of the control flow. 
The user must remember that execution stops, and resumes from some point asynchronously. 
This makes many common patching idioms unusable for a significan number of cases (i.e. cases such as loops in which object outlets feedback into object inlets.)
For example, any live MIDI input, messages from a metronome object, or messages coming from turning audio signals into messages will be difficult to trace when used with the js object.

File Loading
-------------
.. 




The Common Music algorithimic music platform
=============================================



