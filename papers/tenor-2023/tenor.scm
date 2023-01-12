(post "tenor.scm loading")

(define (to-list-f a b c)
  ; return the result of appending a to b 
  (post "args in list:" (list a b c))
  (list a b c))

(define-macro (to-list-m a b c)
  (post "args in list:" (list a b c))
  (list a b c))

(define-macro (to-list-m3 a b c)
  (post "args in list:" (list a b c))
  `(list (quote ,a) (quote ,b) (quote ,c)))

(to-list-f 1 2 3)
(to-list-f 1 2 (+ 3 4))
(to-list-m 1 2 3)

(to-list-m 1 2 (+ 3 4))

(to-list-m list 2 (+ 3 4))

(to-list-m2 1 2 (+ 3 4))
(to-list-m3 1 2 (+ 3 4))

#f

(define ticks/beat 480)

(define (player-1 expr)
  (post "player-1:" expr))

(define (play-note . args)
  (post "play-note" args))

(define (schedule beat ms/beat output-fn note-data)
  "put a note event on the scheduler given beat and ms-per-beat"
  (delay (* beat ms/beat) 
    (lambda ()(apply output-fn note-data))))

; working score, no fancy addition
(define-macro (score output-fn-sym ms/beat . exprs) 
  (for-each 
    (lambda (expr)
      (let ((output-fn (eval output-fn-sym))
            (beat (first expr))
            (evt-data (rest expr)))
      (schedule beat ms/beat output-fn evt-data)))
    exprs))    


(define-macro (score-2 output-fn-sym ticks/beat . exprs) 
  (let ((output-fn (eval output-fn-sym)))
    (let out-loop ((beat 0) (exprs exprs))
      (let* ((evt-data (first exprs))
             (cur-beat (if (eq? (evt-data 0) '+) (inc beat) (evt-data 0))))
        (schedule cur-beat ticks/beat output-fn (rest evt-data))
        (if (not-null? (rest exprs))
          (out-loop cur-beat (rest exprs)))))))

; version that implements adding times
(define-macro (score-2 output-fn-sym ticks/beat . exprs) 
  (let ((output-fn (eval output-fn-sym)))
    (let out-loop ((beat 0) (exprs exprs))
      (let* ((evt-data (first exprs))
             (cur-beat (if (eq? (evt-data 0) '+) (inc beat) (evt-data 0))))
        (schedule cur-beat ticks/beat output-fn (rest evt-data))
        (if (not-null? (rest exprs))
          (out-loop cur-beat (rest exprs)))))))

(score play-note 500
  (1    C1 E1 G1)
  (2    F1 A1 E2)
  (3    G1 B1 D2)
)

(score-2 play-note 480
    (1.0    .5 C2 .99)
    (+      .5 D2 .74)
    (5.0    .5 E2 .49)
    (+      .5 F2 .74)
  )
(define a 99)
(eval a)
