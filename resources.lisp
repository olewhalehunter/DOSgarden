;;;; Resource converter
;;;; .PNG -> 256 color bitmap
;;;; 

(ql:quickload "imago")


(defparameter png-source "images.png")
(defparameter pal-source "IMAGES.TXT")

(defun test-palette ()
  "Draw assumed palette file as converted rgb .png."
  (let ((in (open pal-source
		  :if-does-not-exist nil)))
    (print "...!")
    (when in
      (loop for cha = (read-char in nil)
         while cha do (format t "~a~%" 
			       (char-int cha)))
      (close in)))
)


(defun convert-resources ()
  
)

(imago:write-png
 (imago:emboss (imago:read-image "images.png")
	       :angle (* pi 0.22) :depth 1.0)
 "anderee.png")

(convert-resources)
