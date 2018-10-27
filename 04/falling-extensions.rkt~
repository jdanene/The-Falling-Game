;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname falling-extensions) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
#|

The goal of this assignment is to extend your falling game.

In addition to the extensions listed below, find all opportunities to
abstract the functions that you have already written using map,
filter, and other such higher-order functions.

1) make objects that would be touching the paddle, if they were
   at the bottom of the screen, look different. That is, help the
   player to understand the extent of the paddle with a subtly
   different faller image. (This applies to the new types of fallers
   you add for the second part of the homework too.)

2) make a new type of faller, such that, when it touches the paddle,
   the paddle gets wider and another such that, when it touches the
   paddle, the paddle gets narrower. These fallers should appear at
   regular intervals (not randomly) in your game. For example, every
   10th faller could be a shrinking faller, say.

In order to avoid being overwhelmed by the changes to the game, first be
sure you have a good test suite for your existing game. Second, pick only
one small aspect of the above bullets to work on first. Break the changes up into two
phases: a refactoring phase and then a semantics-breaking change. That is,
first change the program in such a way that the game plays the same as it
played before but that prepares you for the new game's behavior. Once that
change is implemented and tested, then change the behavior in a second
(usually much easier) step. At each stage, make sure you have a complete set
of passing tests and, even better, check each change in to git so you
can exploit the 'git diff' command.

Feel free to change the data definition of world to accomplish these changes.

|#
