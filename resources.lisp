;;;; Resource converter
;;;; .PNG -> DOS palette indexed 256 color bitmap
; (load "C:/development/aquarium/quicklisp.lisp")
; (load "C:/Users/andersen.puckett/AppData/Roaming/quicklisp/setup.lisp") 
; (quicklisp-quickstart:install)
(ql:quickload "imago")

(defparameter png-source "image.png")
(defparameter palette-source "PALETTE.dat")
(defparameter alpha-bits 16777215)
(defun 2d-array-to-list (array)
  (loop for x below (array-dimension array 0)
     collect (loop for y below (array-dimension array 1)
		collect (aref array x y))))
(defun flatten (obj)
  (do* ((result (list obj))
        (node result))
       ((null node) (delete nil result))
    (cond ((consp (car node))
           (when (cdar node) (push (cdar node) (cdr node)))
           (setf (car node) (caar node)))
          (t (setf node (cdr node))))))
(defun hex-to-rgb-list (hex-list)
  (map 'list 
       #'(lambda (x) 
	   (if (= x alpha-bits)
	       (list 0 0 0 0)
	       (let ((hex-str (format nil "~x" x)))
		 (map 'list #'(lambda (y) (parse-integer y :radix 16))
			   (list
			    (subseq hex-str 0 2)
			    (subseq hex-str 2 4)
			    (subseq hex-str 4 6)
			    (subseq hex-str 6 8))))))
       hex-list))
(defun rgb-distance (a b)
  (sqrt (+
   (expt (- (elt a 1) (elt b 1)) 2)
   (expt (- (elt a 2) (elt b 2)) 2)
   (expt (- (elt a 3) (elt b 3)) 2))))

(defparameter img-width 0)
(defparameter img-height 0)
(defparameter img-pixels 
  (let ((img-array 
	 (imago:image-pixels (imago:read-image png-source))))
    (setq img-height (elt (array-dimensions img-array) 0))
    (setq img-width (elt (array-dimensions img-array) 1))
    (hex-to-rgb-list
     (flatten 
      (2d-array-to-list img-array)))))
(defparameter palette-pixels
  (with-open-file (in palette-source)
      (loop for i from 0 to 254 collect 
	  (list 255
	   (* 4 (char-int (read-char in)))
	   (* 4 (char-int (read-char in)))
	   (* 4 (char-int (read-char in)))))))

(defun index-of-closest-palette (rgb)
  (let ((min-dist 442) (min-index 255))
    (loop for x from 0 to 254 do
	 (let ((dist (rgb-distance rgb (elt palette-pixels x))))
	   (if (< dist min-dist)
	       (progn (setq min-index x)
		      (setq min-dist dist)))))
    min-index))

(defun write-indices-file (stream)
  (loop for x in img-pixels do
       (write-char
	(if (< (index-of-closest-palette x) 127)
	    (code-char (index-of-closest-palette x))
	    (code-char 0)) ;; encoding weirdness?
	stream)))

(defun write-dimensions-file (stream)
  (write-char (code-char img-height) stream)
  (write-char (code-char img-width) stream)
)

(defun convert-resources ()
  (print "Converting source .png file to 256 color binary...")
  (with-open-file (stream "out.dat" :direction :output
			  :if-exists :SUPERSEDE 
			  :if-does-not-exist :create)
    (write-dimensions-file stream)
    (write-indices-file stream))
  (print "...done."))

(convert-resources)
