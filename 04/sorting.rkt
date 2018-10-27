;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname sorting) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
#|

Here is an algorithm for sorting lists of numbers

  - if the list has 0 elements or 1 element, it is sorted; return it.

  - if the list has 2 or more elements, divide the list into two
    halves and recursively sort them. Note that you can divide the
    elements in half multiple ways; it does not need to be the first
    half and second half; it may even be easier to take the odd numbered
    and even-numbered elements.

  - combine the two sorted sublists into a single one by merging them

Here is an algorithm for merging the two lists:

  - if either list is empty, return the other one
  
  - if both are not empty, pick the list with the
    smaller first element and break it up into
    it's first element and the rest of the list.
    Recur with the entire list whose first element is
    larger and the rest of the list whose first element
    is smaller. Then cons the first element onto the
    result of the recursive call.

Design functions that implement this sorting algorithm.
For each function, write down if it is generative recursion
or structural recursion. Also write down the running
time of each function using Big Oh notation.

|#
