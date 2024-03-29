(defun alplang-repl ()
  (loop named main
	do
	   (let ((input-command (alplang-read-inputs)))
	     (if (eq (car input-command) 'alp-exit)
		 (return-from main 'goodbye)
		 (alplang-return (alplang-eval-sexp input-command))))))

(defun alplang-read-inputs ()
  (if (eq (char (read-line) 1) #\')
      (let ((line (read-line)))
	`(alplang-return (alplang-eval-sexp ',line)))
    (let ((cmd (read-from-string (concatenate 'string "(" (read-line) ")"))))
         (flet ((quote-it (x)
                    (list 'quote x)))
           (cons (car cmd) (mapcar #'quote-it (cdr cmd)))))))

(defun alplang-eval-sexp (sexp)
  (if sexp
      (eval sexp)
      '(please enter an expression.)))

(defun alplang-pprint-response (lst caps lit)
  (when lst
    (let ((item (car lst))
          (rest (cdr lst)))
      (cond ((eql item #\space) (cons item (alplang-pprint-response rest caps lit)))
            ((member item '(#\! #\? #\.)) (cons item (alplang-pprint-response rest t lit)))
            ((eql item #\") (alplang-pprint-response rest caps (not lit)))
            (lit (cons item (alplang-pprint-response rest nil lit)))
            (caps (cons (char-upcase item) (alplang-pprint-response rest nil lit)))
            (t (cons (char-downcase item) (alplang-pprint-response rest nil nil)))))))

(defun alplang-return (lst)
  (princ (coerce (alplang-pprint-response (coerce (string-trim "() " (prin1-to-string lst)) 'list) t nil) 'string))
  (fresh-line))
