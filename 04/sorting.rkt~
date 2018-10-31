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

;; A [Listof Number] is either:
;; - '()
;; - (cons Number [Listof Number]

;; O(nlogn)
;; merge-sort : [Listof Number] -> [Listof Number]
;; given a list of numbers, return the list in ascending order
;; gererative recursion
(define (merge-sort a-list)
  (cond
    [(or (empty? a-list) (= (length a-list) 1)) a-list]
    [else
     [local [(define my-split-list (split-list a-list))] ;; (length of a-list)/2
       (merge-two-lists
        (make-posn
         (merge-sort (posn-x my-split-list))
         (merge-sort (posn-y my-split-list))))]]))

;; Examples
(check-expect (merge-sort '()) '())
(check-expect (merge-sort '(1)) '(1))
(check-expect (merge-sort '(1 2 3 4)) '(1 2 3 4))
(check-expect (merge-sort '(4 3 2 1)) '(1 2 3 4))
(check-expect (merge-sort '(1 1 1)) '(1 1 1))
(check-expect (merge-sort '(1 2 1 2)) '(1 1 2 2))
(check-expect (merge-sort '(1 6 3 5 7 3 2)) '(1 2 3 3 5 6 7))

;; merge-two-lists: [Listof Number] [Listof Number] -> [Listof Number]
;; assemble two sorted lists into one sorted in ascending order
;; strategy: structural decomp. and structural recursion
;;O(n)
(define (merge-two-lists a-posn)
  (cond
    [(empty? (posn-x a-posn)) (posn-y a-posn)] ;;1
    [(empty? (posn-y a-posn)) (posn-x a-posn)] ;;1
    [else
     (cond
       [(< (first (posn-x a-posn)) (first (posn-y a-posn))) ;;1 + 1 + 1
        (cons (first (posn-x a-posn)) (merge-two-lists (make-posn
                                                        (rest (posn-x a-posn))
                                                        (posn-y a-posn))))]
       [else 
        (cons (first (posn-y a-posn)) (merge-two-lists (make-posn
                                                        (posn-x a-posn)
                                                        (rest (posn-y a-posn)))))])]))

;; Examples
(check-expect (merge-two-lists (make-posn '() '())) '())
(check-expect (merge-two-lists (make-posn (list 1) '())) (list 1))
(check-expect (merge-two-lists (make-posn (list 2) (list 1))) (list 1 2))
(check-expect (merge-two-lists (make-posn (list 3 5) (list 1 4))) (list 1 3 4 5))
(check-expect (merge-two-lists (make-posn (list 3 5 6 7) (list 1 4))) (list 1 3 4 5 6 7))
(check-expect (merge-two-lists (make-posn (list 3 5) (list 1 1 4))) (list 1 1 3 4 5))



; split-list: [Listof Number]-> (make-posn [Listof Number] [Listof Number])
; given a list of numbers, splits it into two lists of numbers
; structural decomp. and functional comp.
;; O(n/2)
(define (split-list a-list)
  (local [;; split-list: [Listof Number] [Listof Number][empty] Number
          ;; -> (make-posn [Listof Number] [Listof Number])
          ;; given a list and an integer < length of the list,
          ;; return the a list containing the first n numbers of that list
          (define (split-list start-list end-list n)
            (cond
              [(empty? start-list) (make-posn start-list end-list)]
              [(zero? n) (make-posn start-list end-list)]
              [else
               (split-list (cdr start-list) (cons (first start-list) end-list) (sub1 n))]))
          
          ;(check-expect (make-list-n '(1 2 3 4) '() 2) (make-posn '(3 4) '(2 1)))
          ;(check-expect (make-list-n '(1 2 3) '() 1) (make-posn '(2 3) '(1)))
          ;(check-expect (make-list-n '() '() 5) (make-posn '() '()))
          ;(check-expect (make-list-n '(1) '() 0) (make-posn '(1) '()))
          ]
    (split-list a-list '() (floor (/ (length a-list) 2)))))
  

(check-expect (split-list '(1 2 3 4)) (make-posn '(3 4) '(2 1)))
(check-expect (split-list '(1 2 3)) (make-posn '(2 3) '(1)))
(check-expect (split-list '()) (make-posn '() '()))
(check-expect (split-list '(1)) (make-posn '(1) '()))









    