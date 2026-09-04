(defpackage #:closurelab-logo
  (:use #:common-lisp))

(in-package #:closurelab-logo)

;; BEGIN-LOGO
;;    CCC               RRR
;;   CCC                 RRR
;;  CCC                   RRR
;; CCC          L          RRR
;; CC           L           RR
;; CC            L          RR
;; CC            L          RR
;; CC            LL         RR
;; CC            LL         RR
;; CC            LL         RR
;; CC           LLLL        RR
;; CC           L  L        RR
;; CC          LL  L        RR
;; CC          L   LL       RR
;; CC         LL    L       RR
;; CC         L     L       RR
;; CC        LL     LL      RR
;; CC        L       L      RR
;; CC       LL       L      RR
;; CCC                     RRR
;;  CCC                   RRR
;;   CCC                 RRR
;;    CCC               RRR
;; END-LOGO

(defconstant +canvas-size+ 1024)
(defconstant +padding+ 2)

(defparameter +palette+
  '((#\C . "#453A62")
    (#\L . "#5E5086")
    (#\R . "#8F4E8B")))

(defun marker (side)
  (ecase side
    (:begin (concatenate 'string ";; BEGIN-" "LOGO"))
    (:end (concatenate 'string ";; END-" "LOGO"))))

(defun source-lines ()
  (unless *load-truename*
    (error "The generator must be loaded from its source file."))
  (with-open-file (source *load-truename* :direction :input)
    (loop for line = (read-line source nil nil)
          while line
          collect line)))

(defun artwork-line (source-line)
  (unless (and (<= 3 (length source-line))
               (string= ";; " source-line :end2 3))
    (error "Artwork lines must start with ~S: ~S" ";; " source-line))
  (subseq source-line 3))

(defun extract-artwork ()
  (let ((begin (marker :begin))
        (end (marker :end))
        (inside nil)
        (finished nil)
        (artwork nil))
    (dolist (line (source-lines))
      (cond
        ((string= line begin)
         (when (or inside finished)
           (error "The source must contain exactly one logo block."))
         (setf inside t))
        ((string= line end)
         (unless inside
           (error "The logo block ends before it begins."))
         (setf inside nil
               finished t))
        (inside
         (push (artwork-line line) artwork))))
    (unless finished
      (error "The source does not contain a complete logo block."))
    (setf artwork (nreverse artwork))
    (unless artwork
      (error "The logo block is empty."))
    artwork))

(defun validate-artwork (artwork)
  (dolist (line artwork)
    (loop for character across line
          unless (or (char= character #\Space)
                     (assoc character +palette+ :test #'char=))
            do (error "Unsupported artwork character ~S." character)))
  (dolist (entry +palette+)
    (unless (some (lambda (line) (find (car entry) line :test #'char=))
                  artwork)
      (error "The artwork does not use palette character ~S." (car entry))))
  artwork)

(defun artwork-width (artwork)
  (reduce #'max artwork :key #'length))

(defun write-runs (stream artwork character)
  (loop for line in artwork
        for row from 0
        do (loop with column = 0
                 while (< column (length line))
                 do (if (char= character (char line column))
                        (let ((start column))
                          (loop while (and (< column (length line))
                                           (char= character
                                                  (char line column)))
                                do (incf column))
                          (format stream "M~D ~D h~D v1 h-~D z"
                                  start row (- column start)
                                  (- column start)))
                        (incf column)))))

(defun write-svg (pathname artwork)
  (let* ((width (artwork-width artwork))
         (height (length artwork))
         (side (+ (max width height) (* 2 +padding+)))
         (offset-x (floor (- side width) 2))
         (offset-y (floor (- side height) 2)))
    (ensure-directories-exist pathname)
    (with-open-file (svg pathname
                         :direction :output
                         :if-exists :supersede
                         :if-does-not-exist :create)
      (format svg "<?xml version=~S encoding=~S?>~%" "1.0" "UTF-8")
      (format svg
              "<svg xmlns=~S width=~S height=~S viewBox=~S role=~S aria-labelledby=~S shape-rendering=~S>~%"
              "http://www.w3.org/2000/svg"
              (format nil "~D" +canvas-size+)
              (format nil "~D" +canvas-size+)
              (format nil "0 0 ~D ~D" side side) "img" "title description"
              "crispEdges")
      (format svg "  <title id=~S>closurelab logo</title>~%" "title")
      (format svg
              "  <desc id=~S>Mirrored C shapes surrounding a lambda.</desc>~%"
              "description")
      (format svg "  <g transform=~S>~%"
              (format nil "translate(~D ~D)" offset-x offset-y))
      (dolist (entry +palette+)
        (format svg "    <path fill=~S d=~S/>~%"
                (cdr entry)
                (with-output-to-string (path)
                  (write-runs path artwork (car entry)))))
      (format svg "  </g>~%</svg>~%"))))

#+sbcl
(defun render-png (svg-pathname png-pathname)
  (ensure-directories-exist png-pathname)
  (let ((process
          (sb-ext:run-program
           "rsvg-convert"
           (list "--format=png"
                 (format nil "--width=~D" +canvas-size+)
                 (format nil "--height=~D" +canvas-size+)
                 (format nil "--output=~A" (namestring png-pathname))
                 (namestring svg-pathname))
           :search t
           :output *standard-output*
           :error *error-output*
           :wait t)))
    (unless (zerop (sb-ext:process-exit-code process))
      (error "rsvg-convert failed with status ~D."
             (sb-ext:process-exit-code process)))))

#-sbcl
(defun render-png (svg-pathname png-pathname)
  (declare (ignore svg-pathname png-pathname))
  (error "PNG rendering currently requires SBCL."))

(defun directory-pathname (name)
  (when (zerop (length name))
    (error "The output directory cannot be empty."))
  (pathname
   (if (char= (char name (1- (length name))) #\/)
       name
       (concatenate 'string name "/"))))

(defun output-directory ()
  #+sbcl
  (let ((arguments (cdr sb-ext:*posix-argv*)))
    (case (length arguments)
      (0 (directory-pathname "build"))
      (1 (directory-pathname (first arguments)))
      (otherwise
       (error "Usage: sbcl --script src/logo.lisp [OUTPUT-DIRECTORY]"))))
  #-sbcl
  (directory-pathname "build"))

(defun main ()
  (let* ((artwork (validate-artwork (extract-artwork)))
         (directory (output-directory))
         (svg (merge-pathnames "closurelab-logo.svg" directory))
         (png (merge-pathnames "closurelab-logo.png" directory)))
    (write-svg svg artwork)
    (render-png svg png)
    (format t "Wrote ~A~%Wrote ~A~%" (namestring svg) (namestring png))))

(main)
