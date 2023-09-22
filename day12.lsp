; For some reason, printing to stdout isn't working...
(define (print-stderr . vals)
    (map (lambda (x) (io.write *stderr* (string x))) vals)
    (io.write *stderr* #\newline))

(define (lookup grid coord)
    (let ((r (car coord))
          (c (cdr coord)))
        (string.char (aref grid r) c)))

(define (valid? grid coord)
    (let ((r (car coord))
          (c (cdr coord)))
        (and
            (>= r 0)
            (<  r (length grid))
            (>= c 0)
            (<  c (length (aref grid r))))))

(define (get-height grid coord)
    (let ((sym (lookup grid coord)))
        (fixnum
            (cond ((= sym #\S) #\a)
                  ((= sym #\E) #\z)
                  (#t          sym)))))

(define (adjacent grid coord allow?)
    (let ((r (car coord))
          (c (cdr coord)))
        (filter
            (lambda (new-coord)
                (and
                    (valid? grid new-coord)
                    (allow? grid coord new-coord)))
            (list
                (cons r (+ c 1))
                (cons r (- c 1))
                (cons (+ r 1) c)
                (cons (- r 1) c)))))

(define (find-syms grid sym)
    (set! res ())
    (for 0 (- (length grid) 1)
        (lambda (r)
            (let ((pos (string.find (aref grid r) sym)))
                (if (integer? pos) (set! res (cons (cons r pos) res))))))
    res)

(define (matches? p1 p2)
    (and (= (car p1) (car p2)) (= (cdr p1) (cdr p2))))

(define (bfs grid adj-cond done? paths visited)
    (let ((path (car paths))
          (here (caar paths)))
        (if (done? grid path)
            path
            (bfs grid adj-cond done?
                (append
                    (cdr paths)
                    (if (member here visited)
                        ()
                        (map
                            (lambda (new-coord) (cons new-coord path))
                            (adjacent grid here adj-cond))))
                (cons here visited)))))

(let* ((fp          (file "input12.txt" :read))
       (grid        (list->vector (io.readlines fp)))
       (start-coord (car (find-syms grid #\S)))
       (end-coord   (car (find-syms grid #\E))))
    (print-stderr (length (cdr
        (bfs
            grid
            (lambda (g orig adj)
                (<=
                    (get-height g adj)
                    (+ (get-height g orig) 1)))
            (lambda (g p) (matches? (car p) end-coord))
            (list (list start-coord))
            ()))))
    (print-stderr (length (cdr
        (bfs
            grid
            (lambda (g orig adj)
                (>=
                    (get-height g adj)
                    (- (get-height g orig) 1)))
            (lambda (g p) (= #\a (lookup g (car p))))
            (list (list end-coord))
            ()))))
    (io.close fp))
