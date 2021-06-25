(delay 1000 
  (let ((dial-1-captured dial-1))
    (lambda () 
      (out 0 (list 'play dial-1-captured dial-2)))))

(define dial-1 0)
(define dial-2 0)
