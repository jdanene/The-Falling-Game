;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname falling_extension) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require 2htdp/image)
(require 2htdp/universe)
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

#|


The player gets 10 points for each falling item that
the paddle catches and loses one point each time they
tap to reverse direction, but the score should never
go below zero.

MOVE THE PADDLE BY PRESSING THE "Space-Bar" KEY

|#

;; a World is
;;   (make-world paddle          -- a shrink/expand indicator, paddle position,
;;                                  paddle image, paddle x-corrdinate
;;               list-of-faller   -- faller positions and images
;;               number          -- score
;;               number          -- number of clock ticks)
(define-struct world (paddle fallers score tick))

;;a paddle is
;;(make-paddle stretch direction image number)
(define-struct paddle (stretch direction image x))

;; a stretch is either a
;; "expand"
;; "shrink"
;; "constant"

;; a direction is either
;;   - "left"
;;   - "right"

;;A faller is
;;(make-faller faller-image number number)
(define-struct faller (image x y))

;;A faller-image is either a
;; - normal-image
;; - touch-image

;;A normal-image is either a
;; -FALLER-IMAGE
;; -EXPAND-FALLER-IMAGE
;; -SHRINK-FALLER-IMAGE

;;A touch-image is either a
;; - TOUCH-MAIN-IMAGE
;; - EXPAND-TOUCH-FALLER-IMAGE
;; - SHRINK-TOUCH-FALLER-IMAGE


;; a list-of-faller is either
;;   - '()
;;   - (cons faller list-of-faller)



;; CONSTANTS

;; Faller Image
(define FALLER-IMAGE (circle 10 100 "blue"))

;;Exanding paddle faller Image
(define EXPAND-FALLER-IMAGE (circle 10 100 "pink"))

;;Shrink paddle faller Image
(define SHRINK-FALLER-IMAGE (circle 10 100 "red"))

;; Touch Faller Image
(define TOUCH-MAIN-IMAGE (circle 10 "solid" "blue"))

;; Touch expanding faller Image
(define EXPAND-TOUCH-FALLER-IMAGE (circle 10 "solid" "pink"))

;; Touch shrink faller Image
(define SHRINK-TOUCH-FALLER-IMAGE (circle 10 "solid" "red"))


;; Paddle Image
(define PADDLE-IMAGE (rectangle 50 12 "solid" "black"))
;;Width of Canvas
(define WORLD-WIDTH 300)
;; Height of Canvas
(define WORLD-HEIGHT 300)
;; Canvas to render images on. 
(define WORLD-CANVAS (empty-scene WORLD-WIDTH WORLD-HEIGHT "SteelBlue"))

;; Max-Width Paddle
(define MAX-PADDLE-WIDTH (/ WORLD-WIDTH 3))

;;Min-width paddle
(define MIN-PADDLE-WIDTH 20)

;; A HARDNESS-LVL represents the probability of a ball being added each tick. 
;;- a number between [0,100] 
(define HARDNESS-LVL 9)

;;Maximum amount of fallers to be falling at one time
(define MAX-AMT-FALLERS 20)

; Number of ticks for shrink faller  to appear
(define SHRINK-TICK 40)

; Number of ticks for expand faller  to appear
(define EXPAND-TICK 30)

#|--------------------- Test Constants -------------------------------------------|#
(define TEST-FALLERS (list (make-faller FALLER-IMAGE 204 15)
                           (make-faller EXPAND-FALLER-IMAGE 24 25)
                           (make-faller FALLER-IMAGE 245 175)
                           (make-faller SHRINK-FALLER-IMAGE 90 270)
                           (make-faller FALLER-IMAGE 120 80)))

(define TEST-PADDLE (make-paddle "constant" "right" PADDLE-IMAGE 100))

(define TEST-WORLD (make-world TEST-PADDLE
                               TEST-FALLERS
                               40
                               300))

#|------------------------------Image Helper functions -------------------------------|#

;; Half Width
(define (get-half-width image)
  (/ (image-width image) 2))

;; Half Height
(define (get-half-height image)
  (/ (image-height image) 2))

#|----------------------------- tick-tock function code ----------------------------------|#


#|--------start: code to update paddle every tick (paddle-x, paddle-direction,
                 paddle-stretch, paddle-image)---|#

;; update-paddle\x: number string img-> number
;; Every tick moves the `paddle' left of right depending on `direction'.
;; UPDATE: PADDLE-X
;; strategy: strucutral decomposition
(define (update-paddle\x paddle-corr direction paddle-image)
  (cond [(string=? direction "left")
         (if (not (<= (- paddle-corr (get-half-width paddle-image)) 0))
             (- paddle-corr 1)
             paddle-corr)]
        [else
         (if (not (>= (+ paddle-corr (get-half-width paddle-image)) WORLD-WIDTH))
             (+ paddle-corr 1)
             paddle-corr)]))

(check-expect (update-paddle\x 50 "left" PADDLE-IMAGE) 49 )
(check-expect (update-paddle\x 50 "right" PADDLE-IMAGE) 51)
(check-expect (update-paddle\x 0 "left" PADDLE-IMAGE) 0)
(check-expect (update-paddle\x WORLD-WIDTH "right" PADDLE-IMAGE) WORLD-WIDTH)


;; update-paddle\direction: number string image-> direction
;; if the `paddle' is at the boundary change `direction' to the opposite direction.
;; UPDATE: PADDLE-DIRECTION
;; strategy: strucutral decomposition
(define (update-paddle\direction paddle-corr direction paddle-image)
  (cond [(<= (- paddle-corr (get-half-width paddle-image)) 0) "right"]
        [(>= (+ paddle-corr (get-half-width paddle-image)) WORLD-WIDTH) "left"]
        [else direction]))


(check-expect (update-paddle\direction 5 "left" PADDLE-IMAGE) "right")
(check-expect (update-paddle\direction (- WORLD-WIDTH 5) "right" PADDLE-IMAGE) "left")
(check-expect (update-paddle\direction  100 "right" PADDLE-IMAGE) "right")
(check-expect (update-paddle\direction 100 "left" PADDLE-IMAGE) "left")


;; faller-equal-paddle?: paddle faller -> boolean
;; Returns #true if paddle hits the faller. 
;; strategy: structural decomp
(define (faller-equal-paddle? paddle faller)
  (let* ([paddle-width (image-width (paddle-image paddle))]
         [paddle-height (image-height (paddle-image paddle))]
         [faller-height\half (get-half-height (faller-image faller))]
         [paddle-width\half (get-half-width (paddle-image paddle))])
    (and (<= (- (paddle-x paddle) paddle-width\half)
             (faller-x faller)
             (+ (paddle-x paddle) paddle-width\half ))
         (equal? (+ (faller-y faller) faller-height\half) 
                 (- WORLD-HEIGHT paddle-height)))))

(check-expect (faller-equal-paddle? (make-paddle "expand" "left" PADDLE-IMAGE 10)
                                    (make-faller FALLER-IMAGE 10  (- (- WORLD-HEIGHT 12) 10))) #true)
(check-expect (faller-equal-paddle? (make-paddle "expand" "left" PADDLE-IMAGE 30)
                                    (make-faller FALLER-IMAGE 5  (- (- WORLD-HEIGHT 12) 10))) #true)
(check-expect (faller-equal-paddle? (make-paddle "expand" "left" PADDLE-IMAGE 30)
                                    (make-faller FALLER-IMAGE 4  (- (- WORLD-HEIGHT 12) 10))) #false)
(check-expect (faller-equal-paddle? (make-paddle "expand" "left" PADDLE-IMAGE 10)
                                    (make-faller FALLER-IMAGE 12  WORLD-HEIGHT)) #false)
(check-expect (faller-equal-paddle? (make-paddle "expand" "left" PADDLE-IMAGE 10)
                                    (make-faller FALLER-IMAGE 12 10)) #false)


;;check-paddle\stretch: paddle faller-> stretch
;; If (faller-x) hits the paddle then depending on the faller-image the paddle stretch is set to
;; either "expand" or "shrink"
;; Created to be used in the map function within the function `update-stretch'
;; strategy: structural decomposition
(define (check-paddle\stretch paddle faller)
  (if (faller-equal-paddle? paddle faller)
      (cond [(equal? (faller-image faller) EXPAND-FALLER-IMAGE) "expand"]
            [(equal? (faller-image faller) SHRINK-FALLER-IMAGE) "shrink"]
            [else (paddle-stretch paddle)])
      (paddle-stretch paddle)))


(check-expect (check-paddle\stretch (make-paddle "constant" "left" PADDLE-IMAGE 10) 
                                    (make-faller EXPAND-FALLER-IMAGE 10
                                                 (- (- WORLD-HEIGHT 12) 10)))
              "expand")
(check-expect (check-paddle\stretch (make-paddle "constant" "left" PADDLE-IMAGE 10) 
                                    (make-faller SHRINK-FALLER-IMAGE 10
                                                 (- (- WORLD-HEIGHT 12) 10)))
              "shrink")
(check-expect (check-paddle\stretch (make-paddle "constant" "left" PADDLE-IMAGE 10) 
                                    (make-faller FALLER-IMAGE 10
                                                 (- (- WORLD-HEIGHT 12) 10)))
              "constant")
(check-expect (check-paddle\stretch (make-paddle "constant" "left" PADDLE-IMAGE 10) 
                                    (make-faller TOUCH-MAIN-IMAGE 10
                                                 (- (- WORLD-HEIGHT 12) 10)))
              "constant")
(check-expect (check-paddle\stretch (make-paddle "constant" "left" PADDLE-IMAGE 10) 
                                    (make-faller EXPAND-TOUCH-FALLER-IMAGE 10
                                                 (- (- WORLD-HEIGHT 12) 10)))
              "constant")
(check-expect (check-paddle\stretch (make-paddle "constant" "left" PADDLE-IMAGE 10) 
                                    (make-faller SHRINK-TOUCH-FALLER-IMAGE 10
                                                 (- (- WORLD-HEIGHT 12) 10)))
              "constant")
(check-expect (check-paddle\stretch (make-paddle "constant" "left" PADDLE-IMAGE 0) 
                                    (make-faller SHRINK-TOUCH-FALLER-IMAGE 60
                                                 (- (- WORLD-HEIGHT 12) 10)))
              "constant")



;; update-paddle\stretch: list-of-fallers paddle -> stretch
;; Goes through all the list-of-fallers checks if paddle hits one of the fallers,
;; if so updates stretch appropriately. Note the stretch variable changes iff the
;; image associated with the faller that was hit is a normal-image. (see definition)
;; UPDATE: PADDLE-STRETCH
;; strategy: abstraction
(define (update-paddle\stretch fallers paddle)
  (let* ([stretch-list (map (λ (f) (check-paddle\stretch paddle f)) fallers)]
         [stretch-canidates (filter (λ (s) (not (string=? s (paddle-stretch paddle)))) stretch-list)])
    (cond [(empty? stretch-canidates)
           (paddle-stretch paddle)]
          [else
           (first stretch-canidates)])))


(check-expect (update-paddle\stretch (list (make-faller FALLER-IMAGE 0 0)
                                           (make-faller FALLER-IMAGE 1 9)
                                           (make-faller FALLER-IMAGE  2 20)
                                           (make-faller FALLER-IMAGE 7 WORLD-HEIGHT)
                                           (make-faller EXPAND-FALLER-IMAGE 8
                                                        (- (- WORLD-HEIGHT 12) 10))
                                           (make-faller FALLER-IMAGE 9 WORLD-HEIGHT))
                                     (make-paddle "constant" "left" PADDLE-IMAGE 8)) "expand")

(check-expect (update-paddle\stretch (list (make-faller FALLER-IMAGE 0 0)
                                           (make-faller FALLER-IMAGE 1 9)
                                           (make-faller FALLER-IMAGE  2 20)
                                           (make-faller FALLER-IMAGE 7 WORLD-HEIGHT)
                                           (make-faller SHRINK-FALLER-IMAGE 8
                                                        (- (- WORLD-HEIGHT 12) 10))
                                           (make-faller FALLER-IMAGE 9 WORLD-HEIGHT))
                                     (make-paddle "constant" "left" PADDLE-IMAGE 8)) "shrink")

(check-expect (update-paddle\stretch (list (make-faller FALLER-IMAGE 0 0)
                                           (make-faller FALLER-IMAGE 1 9)
                                           (make-faller FALLER-IMAGE  2 20)
                                           (make-faller FALLER-IMAGE 7 WORLD-HEIGHT)
                                           (make-faller SHRINK-TOUCH-FALLER-IMAGE 8 17)
                                           (make-faller FALLER-IMAGE 9 WORLD-HEIGHT))
                                     (make-paddle "constant" "left" PADDLE-IMAGE 8)) "constant")



;; update-paddle\image: image stretch -> image
;; Every tick either shrinks paddle or expands paddle depending on paddle-stretch
;; UPDATE: PADDLE-IMAGE
;; strategy: strucutral decomposition
(define (update-paddle\image paddle-img stretch)
  (let ([paddle-width (image-width paddle-img)])
    (cond [(string=? stretch "expand")
           (if (= paddle-width MAX-PADDLE-WIDTH)
               paddle-img
               (rectangle (+ paddle-width 1) 12 "solid" "black"))]
          [(string=? stretch "shrink")
           (if (= paddle-width MIN-PADDLE-WIDTH)
               paddle-img
               (rectangle (- paddle-width 1) 12 "solid" "black"))]
          [else
           paddle-img])))

(check-expect (update-paddle\image (rectangle 50 12 "solid" "black")  "expand")
              (rectangle 51 12 "solid" "black"))

(check-expect (update-paddle\image (rectangle MAX-PADDLE-WIDTH 12 "solid" "black")  "expand")
              (rectangle MAX-PADDLE-WIDTH 12 "solid" "black"))

(check-expect (update-paddle\image (rectangle 50 12 "solid" "black")  "shrink")
              (rectangle 49 12 "solid" "black"))

(check-expect (update-paddle\image (rectangle  MIN-PADDLE-WIDTH 12 "solid" "black")  "shrink")
              (rectangle  MIN-PADDLE-WIDTH 12 "solid" "black"))

(check-expect (update-paddle\image (rectangle 50 12 "solid" "black")  "constant")
              (rectangle 50 12 "solid" "black"))


;; update-paddle: paddle fallers -> paddle
;; updates the paddle each tick
;; UPDATE: PADDLE
;; strategy: function composition
(define (update-paddle paddle fallers)
  (make-paddle
   (update-paddle\stretch fallers paddle)
   (update-paddle\direction (paddle-x paddle) 
                            (paddle-direction paddle) 
                            (paddle-image paddle))
   (update-paddle\image (paddle-image paddle) (paddle-stretch paddle))
   (update-paddle\x (paddle-x paddle) (paddle-direction paddle) (paddle-image paddle))))
  


;update x-corrdinate check 
(check-expect (update-paddle (make-paddle "constant" "left" PADDLE-IMAGE 50)
                             (list (make-faller FALLER-IMAGE 0 0)
                                   (make-faller FALLER-IMAGE 1 9)
                                   (make-faller FALLER-IMAGE  2 20)
                                   (make-faller FALLER-IMAGE 7 WORLD-HEIGHT)
                                   (make-faller SHRINK-TOUCH-FALLER-IMAGE 8 17)
                                   (make-faller FALLER-IMAGE 9 WORLD-HEIGHT)))
              (make-paddle "constant" "left" PADDLE-IMAGE 49))

;makes sure paddle stretches for "expand"
(check-expect (update-paddle (make-paddle "expand" "left" PADDLE-IMAGE 50)
                             (list (make-faller FALLER-IMAGE 0 0)
                                   (make-faller FALLER-IMAGE 1 9)
                                   (make-faller FALLER-IMAGE  2 20)
                                   (make-faller FALLER-IMAGE 7 WORLD-HEIGHT)
                                   (make-faller SHRINK-TOUCH-FALLER-IMAGE 8 17)
                                   (make-faller FALLER-IMAGE 9 WORLD-HEIGHT)))
              (make-paddle "expand" "left" (rectangle 51 12 "solid" "black") 49))

;makes sure paddles stretches for "shrink"
(check-expect (update-paddle (make-paddle "shrink" "left" PADDLE-IMAGE 50)
                             (list (make-faller FALLER-IMAGE 0 0)
                                   (make-faller FALLER-IMAGE 1 9)
                                   (make-faller FALLER-IMAGE  2 20)
                                   (make-faller FALLER-IMAGE 7 WORLD-HEIGHT)
                                   (make-faller SHRINK-TOUCH-FALLER-IMAGE 8 17)
                                   (make-faller FALLER-IMAGE 9 WORLD-HEIGHT)))
              (make-paddle "shrink" "left" (rectangle 49 12 "solid" "black") 49))

; make sure stretch variable updates to "shrink"
(check-expect (update-paddle (make-paddle "constant" "left" PADDLE-IMAGE 50)
                             (list (make-faller FALLER-IMAGE 0 0)
                                   (make-faller FALLER-IMAGE 1 9)
                                   (make-faller FALLER-IMAGE  2 20)
                                   (make-faller FALLER-IMAGE 7 WORLD-HEIGHT)
                                   (make-faller SHRINK-FALLER-IMAGE 50 (- (- WORLD-HEIGHT 12) 10))
                                   (make-faller FALLER-IMAGE 9 WORLD-HEIGHT)))
              (make-paddle "shrink" "left" PADDLE-IMAGE 49))

; make sure the direction changes
(check-expect (update-paddle (make-paddle "constant" "left" PADDLE-IMAGE 25)
                             (list (make-faller FALLER-IMAGE 0 0)
                                   (make-faller FALLER-IMAGE 1 9)
                                   (make-faller FALLER-IMAGE  2 20)
                                   (make-faller FALLER-IMAGE 7 WORLD-HEIGHT)
                                   (make-faller SHRINK-FALLER-IMAGE 25 (- (- WORLD-HEIGHT 12) 10))
                                   (make-faller FALLER-IMAGE 9 WORLD-HEIGHT)))
              (make-paddle "shrink" "right" PADDLE-IMAGE 25))


  
#|--------end: code to update paddle every tick --------|#


;; add-score: paddle list-of-faller number -> number
;; Updates the score of the game by cycling through every
;; faller in `fallers and checking if the faller hits the paddle.
;; UPDATE: SCORE
;; strategy: structural decomp
(define (add-score paddle fallers score)
  (local [;; get-score: list-of-faller paddle -> number
          ;; For every faller in `fallers', if a faller hits the paddle then add +10 to the score.
          ;; otherwise add +0 to the score. Essentially a sum recursive function
          ;; strategy: structural decomposition
          (define (get-score fallers paddle)
            (cond [(equal? fallers '()) 0]
                  [else (cond
                          [(faller-equal-paddle? paddle (first fallers))
                           (+ 10 (get-score (rest fallers) paddle))]
                          [else
                           (+ 0 (get-score (rest fallers)  paddle))])]))]
    (+ score (get-score fallers  paddle))))


(check-expect (add-score (make-paddle "constant" "left" PADDLE-IMAGE 8)
                         (list (make-faller FALLER-IMAGE 0 0)
                               (make-faller FALLER-IMAGE 1 9)
                               (make-faller FALLER-IMAGE  2 20)
                               (make-faller FALLER-IMAGE 7 WORLD-HEIGHT)
                               (make-faller FALLER-IMAGE 8 (- (- WORLD-HEIGHT 12) 10))
                               (make-faller FALLER-IMAGE 9 WORLD-HEIGHT)) 0) 10)

(check-expect (add-score (make-paddle "constant" "left" PADDLE-IMAGE 8)
                         (list (make-faller FALLER-IMAGE 0 0)
                               (make-faller FALLER-IMAGE 1 9)
                               (make-faller FALLER-IMAGE  2 20)
                               (make-faller FALLER-IMAGE  8 (- (- WORLD-HEIGHT 12) 10))
                               (make-faller FALLER-IMAGE  8 (- (- WORLD-HEIGHT 12) 10))
                               (make-faller FALLER-IMAGE  8 (- (- WORLD-HEIGHT 12) 10))) 20) 50)

(check-expect (add-score (make-paddle "constant" "left" PADDLE-IMAGE 8)
                         (list (make-faller FALLER-IMAGE 0 0)
                               (make-faller FALLER-IMAGE 1 9)
                               (make-faller FALLER-IMAGE 2 20)
                               (make-faller FALLER-IMAGE 99 WORLD-HEIGHT)
                               (make-faller FALLER-IMAGE 6 WORLD-HEIGHT)
                               (make-faller FALLER-IMAGE 55 WORLD-HEIGHT)) 20) 20)

#|--------start: code to update faller every tick --------|#

;; create-faller\special: number -> list-of-faller
;; Every tick mod EXPAND-TICK = 0  and tick mod SHRINK-TICK = 0, we add a expand ball and shrink
;; ball to list-of-fallers
(define (create-faller\special tick)
  (let ([expand-indc (= (remainder tick EXPAND-TICK) 0)]
        [shrink-indc (= (remainder tick SHRINK-TICK) 0)]) 
    (cond [(and expand-indc shrink-indc)
           ;We want the random number to be in [10, WORLD-WIDTH-10].
           (list (make-faller SHRINK-FALLER-IMAGE (+ 10 (random (- WORLD-WIDTH 20))) 0)
                 (make-faller EXPAND-FALLER-IMAGE (+ 10 (random (- WORLD-WIDTH 20))) 0))]
          [expand-indc
           (list (make-faller EXPAND-FALLER-IMAGE (+ 10 (random (- WORLD-WIDTH 20))) 0))]
          [shrink-indc
           (list (make-faller SHRINK-FALLER-IMAGE (+ 10 (random (- WORLD-WIDTH 20))) 0))]
          [else '()])))


(check-random (create-faller\special (* SHRINK-TICK EXPAND-TICK))
              (list (make-faller SHRINK-FALLER-IMAGE (+ 10 (random (- WORLD-WIDTH 20))) 0)
                    (make-faller EXPAND-FALLER-IMAGE (+ 10 (random (- WORLD-WIDTH 20))) 0)))

(check-random (create-faller\special  SHRINK-TICK)
              (list (make-faller SHRINK-FALLER-IMAGE (+ 10 (random (- WORLD-WIDTH 20))) 0)))

(check-random (create-faller\special  EXPAND-TICK)
              (list (make-faller EXPAND-FALLER-IMAGE (+ 10 (random (- WORLD-WIDTH 20))) 0)))

(check-random (create-faller\special  7)
              '())

;; update-faller: paddle faller -> faller or boolean    
;; checks if the ball is at the bottom of the screen [posn-y = WORLD-HEIGHT]. 
;; If so then returns #false. Checks if the faller equal paddle if so
;; then changes the faller image to TOUCH-MAIN-IMAGE and updates the faller
;; position. We are creating this function to apply it to filter. 
;; strategy: struc. decomp.
(define (update-faller paddle faller)
  (cond [(equal? (- (faller-y faller) 
                    (get-half-height (faller-image faller))) 
                 WORLD-HEIGHT)
         #false]
        [(and (faller-equal-paddle? paddle faller)
              (equal? (faller-image faller) FALLER-IMAGE))
         (make-faller TOUCH-MAIN-IMAGE (faller-x faller) (+ (faller-y faller) 1))]
        [(and (faller-equal-paddle? paddle faller)
              (equal? (faller-image faller) EXPAND-FALLER-IMAGE))
         (make-faller EXPAND-TOUCH-FALLER-IMAGE (faller-x faller) (+ (faller-y faller) 1))]
        [(and (faller-equal-paddle? paddle faller)
              (equal? (faller-image faller) SHRINK-FALLER-IMAGE))
         (make-faller SHRINK-TOUCH-FALLER-IMAGE (faller-x faller) (+ (faller-y faller) 1))]
        [else
         (make-faller (faller-image faller) (faller-x faller) (+ (faller-y faller) 1))]))


(check-expect (update-faller (make-paddle "constant" "left" PADDLE-IMAGE 10)
                             (make-faller FALLER-IMAGE 10 (- (- WORLD-HEIGHT 12) 10)))
              (make-faller TOUCH-MAIN-IMAGE 10 (- (- WORLD-HEIGHT 11) 10)))
(check-expect (update-faller (make-paddle "constant" "left" PADDLE-IMAGE 10)
                             (make-faller EXPAND-FALLER-IMAGE 10 (- (- WORLD-HEIGHT 12) 10)))
              (make-faller EXPAND-TOUCH-FALLER-IMAGE 10 (- (- WORLD-HEIGHT 11) 10)))
(check-expect (update-faller (make-paddle "constant" "left" PADDLE-IMAGE 10)
                             (make-faller SHRINK-FALLER-IMAGE 10 (- (- WORLD-HEIGHT 12) 10)))
              (make-faller SHRINK-TOUCH-FALLER-IMAGE 10 (- (- WORLD-HEIGHT 11) 10)))
(check-expect (update-faller (make-paddle "constant" "left" PADDLE-IMAGE 10)
                             (make-faller FALLER-IMAGE 10 (+ 10 WORLD-HEIGHT))) #false)
(check-expect (update-faller (make-paddle "constant" "left" PADDLE-IMAGE 10)
                             (make-faller FALLER-IMAGE 10 (- (- WORLD-HEIGHT 10) 10)))
              (make-faller FALLER-IMAGE 10 (- (- WORLD-HEIGHT 9) 10)))



;; add-faller\random: list-of-faller -> list-of-faller
;; Adds faller to the list-of-faller randomly according to probability (HARDNESS-LVL/100)
;; strategy: Function given by instructor
(define (add-faller\random fallers)
  (cond [(< (length fallers) MAX-AMT-FALLERS)
         (cond [(< (random 100) HARDNESS-LVL)
                (cons (make-faller FALLER-IMAGE (random WORLD-WIDTH) 0)
                      fallers)]
               [else fallers])]
        [else fallers]))

;; not_false?: x -> boolean
;; returns true if a `val' is not equal to false.
;; strategy: struc. decomp.
(define (not_false? val)
  (not (equal? val #false)))

(check-expect (not_false? 5) #true)
(check-expect (not_false? #false) #false)

;; update-all-faller: paddle list-of-faller -> list-of-faller
;; Updates all the fallers positions and images.
;; For every faller in list-of-faller, `fallers', we either remove the
;; faller from the list if the faller is at the bottom of the screen,
;; or update faller-y -> (+ faller-y 1), and if a faller happens to hit the paddle we also
;; change the faller image. 
;; strategy: function composition
(define (update-all-faller paddle fallers)
  (filter not_false? (map (lambda (f) (update-faller paddle f)) fallers)))

(check-expect (update-all-faller (make-paddle "constant" "left" PADDLE-IMAGE 10)
                                 (list (make-faller FALLER-IMAGE 0 0)
                                       (make-faller FALLER-IMAGE 1 1)
                                       (make-faller FALLER-IMAGE 2 2)
                                       (make-faller FALLER-IMAGE 3 3)
                                       (make-faller FALLER-IMAGE 4 4)
                                       (make-faller FALLER-IMAGE 5 5)
                                       (make-faller FALLER-IMAGE 6 6)
                                       (make-faller FALLER-IMAGE 10  (- (- WORLD-HEIGHT 12) 10))
                                       (make-faller EXPAND-FALLER-IMAGE 11
                                                    (- (- WORLD-HEIGHT 12) 10))
                                       (make-faller SHRINK-FALLER-IMAGE 12
                                                    (- (- WORLD-HEIGHT 12) 10))
                                       (make-faller FALLER-IMAGE 8 (+ 10 WORLD-HEIGHT))
                                       (make-faller FALLER-IMAGE 9 (+ 10 WORLD-HEIGHT))))

              (list (make-faller FALLER-IMAGE 0 1)
                    (make-faller FALLER-IMAGE 1 2)
                    (make-faller FALLER-IMAGE 2 3)
                    (make-faller FALLER-IMAGE 3 4)
                    (make-faller FALLER-IMAGE 4 5)
                    (make-faller FALLER-IMAGE 5 6)
                    (make-faller FALLER-IMAGE 6 7)
                    (make-faller TOUCH-MAIN-IMAGE 10  (- (- WORLD-HEIGHT 11) 10))
                    (make-faller EXPAND-TOUCH-FALLER-IMAGE 11  (- (- WORLD-HEIGHT 11) 10))
                    (make-faller SHRINK-TOUCH-FALLER-IMAGE 12  (- (- WORLD-HEIGHT 11) 10))))
(check-expect (update-all-faller  10 '())
              '())

;; next-fallers: paddle list-of-faller number-> list-of-faller
;; Calls the function `update-all-faller' to update all faller position and faller images. Then
;; calls add-faller\random to add a normal faller to our list of fallers.
;; Then appends the special fallers to this list
;; THIS FUNCTION UPDATES: FALLERS
;; strategy: Function Composiiton. (Random Variable no tests)
(define (next-fallers paddle fallers tick)
  (append (add-faller\random (update-all-faller paddle fallers)) (create-faller\special tick)))

#|--------end: code to update faller every tick --------|#

;;tick-tock: World -> World
;;updates `ws' every tick of the clock
;; strategy: structural decomposition (Random Variable no tests)
(define (tick-tock ws)
  (make-world
   (update-paddle (world-paddle ws) (world-fallers ws))
   (next-fallers (world-paddle ws) (world-fallers ws) (world-tick ws))
   (add-score (world-paddle ws) (world-fallers ws) (world-score ws))
   (add1 (world-tick ws))))


;;Possible to-do make tests for random functions. I did this for create-faller\special
;;but structure for this and the other random function diff so takes some thinking. 

#|----------------------------- click-click function code --------------------------------|#
;; subtract-score: number -> number
;; function to decrease the score if the player hits spacebar 
;; strategy: structural decomposition
(define (subtract-score score)
  (cond [(> score 0) (- score 1)]
        [else score]))
  
(check-expect (subtract-score 5) 4)
(check-expect (subtract-score 0) 0)

;; direction-on-click: string - > string
;; changes the `direction' whenever the user hits the up arrow
;; strategy: structural decomposition
(define (direction-on-click direction)
  (cond [(string=? direction "left") "right"]
        [else "left"]))

(check-expect (direction-on-click "left") "right")
(check-expect (direction-on-click "right") "left")


;; click-click: World string -> World
;; updates world state whenever the user hits the spacebar
;; strategy: struc. decomp.
(define (click-click ws a-key)
  (cond
    [(string=? a-key " ")
     (make-world
      (make-paddle (paddle-stretch (world-paddle ws))
                   (direction-on-click (paddle-direction (world-paddle ws)))
                   (paddle-image (world-paddle ws))
                   (paddle-x (world-paddle ws)))
      (world-fallers ws)
      (subtract-score (world-score ws))
      (world-tick ws))]
    [else ws]))


(check-expect (click-click
               (make-world
                (make-paddle "constant" "left" PADDLE-IMAGE 40)
                (list (make-faller FALLER-IMAGE 0 0)
                      (make-faller FALLER-IMAGE 4 50)
                      (make-faller FALLER-IMAGE 2 30)) 5 999) " ")
              (make-world
               (make-paddle "constant" "right" PADDLE-IMAGE 40)
               (list (make-faller FALLER-IMAGE 0 0)
                     (make-faller FALLER-IMAGE 4 50)
                     (make-faller FALLER-IMAGE 2 30)) 4 999))

(check-expect (click-click
               (make-world
                (make-paddle "constant" "left" PADDLE-IMAGE 40)
                (list (make-faller FALLER-IMAGE 0 0)
                      (make-faller FALLER-IMAGE 4 50)
                      (make-faller FALLER-IMAGE 2 30)) 5 999) "t")
              (make-world
               (make-paddle "constant" "left" PADDLE-IMAGE 40)
               (list (make-faller FALLER-IMAGE 0 0)
                     (make-faller FALLER-IMAGE 4 50)
                     (make-faller FALLER-IMAGE 2 30)) 5 999))

#|----------------------------- render function code -------------------------------------|#
;; display-fallers: list-of-faller -> image
;; placing each faller onto the WORLD CANVAS
;; strategy: function comp.
(define (display-fallers fallers)
  (foldr (λ (a-faller pic)
           (place-image (faller-image a-faller)
                        (faller-x a-faller)
                        (faller-y a-faller)
                        pic))
         WORLD-CANVAS
         fallers))

(check-expect (display-fallers TEST-FALLERS) (place-images (list FALLER-IMAGE
                                                                 EXPAND-FALLER-IMAGE
                                                                 FALLER-IMAGE
                                                                 SHRINK-FALLER-IMAGE
                                                                 FALLER-IMAGE)
                                                           (list (make-posn 204 15)
                                                                 (make-posn 24 25)
                                                                 (make-posn 245 175)
                                                                 (make-posn 90 270)
                                                                 (make-posn 120 80))
                                                           WORLD-CANVAS))
;; monospaced-text: string -> image
;; Outputs text as an image
;; strategy: Instructor defined function
(define (monospaced-text str)
  (text/font str
             14
             "white"
             "Menlo" 'modern
             'normal 'normal #f))

;; display-score: number image ->image
;; Displays the score on the canvas
;; strategy: struc. decomp
(define (display-score score canvas)
  (place-image
   (monospaced-text (number->string score))
   20 20 canvas))

(check-expect (display-score 120 (display-fallers TEST-FALLERS))
              (place-image
               (monospaced-text (number->string 120))
               20 20 (display-fallers TEST-FALLERS)))

;; render: World -> image
;; renders the world to the canvas
;; strategy: func. comp.
(define (render ws)
  (place-image (paddle-image
                (world-paddle ws))
               (paddle-x (world-paddle ws))
               (- WORLD-HEIGHT
                  (get-half-height (paddle-image (world-paddle ws))))
               (display-score (world-score ws) (display-fallers (world-fallers ws)))))

(check-expect (render TEST-WORLD)
              (place-image
               (paddle-image
                (world-paddle TEST-WORLD))
               (paddle-x (world-paddle TEST-WORLD))
               (- WORLD-HEIGHT
                  (get-half-height (paddle-image (world-paddle TEST-WORLD))))
               (display-score (world-score TEST-WORLD)
                              (display-fallers (world-fallers TEST-WORLD)))))
                                         
#|
;; big-bang: World -> World
(big-bang (make-world (make-paddle
                       "constant"
                       "right"
                       PADDLE-IMAGE
                       (/ WORLD-WIDTH 2))
                      '() 0 0)
  [on-tick tick-tock 1/200]
  [on-key click-click]
  [to-draw render])

|#