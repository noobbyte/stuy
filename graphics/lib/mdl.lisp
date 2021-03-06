(in-package :graphics)

(defvar *reserved-words* (make-hash-table :test 'equal))

(loop
   for (reserved . value) in '(("x" . "XYZ")
                               ("y" . "XYZ")
                               ("z" . "XYZ")
                               ("screen" . "SCREEN")
                               ("light" . "LIGHT")
                               ("constants" . "CONSTANTS")
                               ("save_coord_system" . "SAVE_COORDS")  
                               ("camera" . "CAMERA")
                               ("ambient" . "AMBIENT")  
                               ("torus" . "TORUS")
                               ("sphere" . "SPHERE")
                               ("box" . "BOX")  
                               ("line" . "LINE")
                               ("bezier" . "BEZIER")
                               ("hermite" . "HERMITE")  
                               ("circle" . "CIRCLE") 
                               ("mesh" . "MESH")
                               ("texture" . "TEXTURE")  
                               ("set" . "SET") 
                               ("move" . "MOVE")
                               ("scale" . "SCALE")
                               ("rotate" . "ROTATE")  
                               ("basename" . "BASENAME")
                               ("save_knobs" . "SAVE_KNOBS")  
                               ("tween" . "TWEEN")
                               ("frames" . "FRAMES")
                               ("vary" . "VARY")  
                               ("push" . "PUSH")
                               ("pop" . "POP")  
                               ("save" . "SAVE")
                               ("display" . "DISPLAY")  
                               ("generate_rayfiles" . "GENERATE_RAYFILES")  
                               ("shading" . "SHADING")  
                               ("phong" . "SHADING_TYPE")
                               ("flat" . "SHADING_TYPE")
                               ("ground" . "SHADING_TYPE")
                               ("raytrace" . "SHADING_TYPE")
                               ("wireframe" . "SHADING_TYPE")  
                               ("set_knobs" . "SET_KNOBS")
                               ("focal" . "FOCAL")
                               ("web" . "WEB"))
   do (setf (gethash reserved *reserved-words*) value))

(define-string-lexer mdl-lexer
  ("[a-zA-Z_][.a-zA-Z0-9_]*"
   (let ((value (gethash $@ *reserved-words*)))
     (if value
         (return (values (intern value) $@))
         (return (values 'string $@)))))
  ("-?([0-9]+\.?|[0-9]*\.?[0-9]+)" (return (values 'number (read-from-string $@))))
  ("//" (return (values 'comment $@))))

(define-parser mdl-parser
  (:start-symbol mdl)
  (:terminals (push pop move rotate scale box sphere torus line save display xyz comment number string))

  (mdl command
       commented)

  (command (push)
           (pop)
           (move number number number)
           (rotate xyz number)
           (scale number number number)
           (box number number number number number number)
           (sphere number number number number)
           (torus number number number number number)
           (line number number number number number number)
           (save string)
           (display))

  (commented (comment arguments #'(lambda (comment arguments) "")))

  (arguments (alphanum #'list)
             (alphanum arguments #'(lambda (alphanum arguments)
                                     (cons alphanum arguments))))
  
  (alphanum number
            string))

(defun parse-file (filename)
  (with-open-file (stream filename)
    (loop
       for line = (read-line stream nil)
       while line
       do
         (let* ((parsed (parse-with-lexer (mdl-lexer line) mdl-parser))
                (command (car parsed))
                (arguments (cdr parsed)))
           (format t "~a: ~a~%" command arguments)
           (cond
             ((string-equal command "line")
              ;;(format t "Drawing line...~%")
              (let* ((point1 (apply 'vector (subseq arguments 0 3)))
                     (point2 (apply 'vector (subseq arguments 3 6))))
                (add-edge point1 point2))
              (draw-edges)
              (clear-edge-matrix))
             ((string-equal command "circle")
              ;;(format t "Drawing circle...~%")
              (apply 'add-circle arguments)
              (draw-edges)
              (clear-edge-matrix))
             ((string-equal command "hermite")
              ;;(format t "Drawing hermite curve...~%")
              (apply 'add-hermite-curve arguments)
              (draw-edges)
              (clear-edge-matrix))
             ((string-equal command "bezier")
              ;;(format t "Drawing bezier curve...~%")
              (apply 'add-bezier-curve arguments)
              (draw-edges)
              (clear-edge-matrix))
             ((string-equal command "box")
              ;;(format t "Drawing box...~%")
              (apply 'add-box arguments)
              (draw-triangles)
              (clear-triangle-matrix))
             ((string-equal command "sphere")
              ;;(format t "Drawing sphere...~%")
              (apply 'add-sphere arguments)
              (draw-triangles)
              (clear-triangle-matrix))
             ((string-equal command "torus")
              ;;(format t "Drawing torus...~%")
              (apply 'add-torus arguments)
              (draw-triangles)
              (clear-triangle-matrix))
             ((string-equal command "ident")
              ;;(format t "Setting identity matrix...~%")
              (setf *transformation-matrix* (make-identity-matrix)))
             ((string-equal command "scale")
              ;;(format t "Scaling...~%")
              (let ((matrix (apply 'make-scale-matrix arguments)))
                (set-coordinate-system
                 (matrix-matrix-mult (get-coordinate-system) matrix))))
             ((string-equal command "move")
              ;;(format t "Moving...~%")
              (let ((matrix (apply 'make-translation-matrix arguments)))
                (set-coordinate-system
                 (matrix-matrix-mult (get-coordinate-system) matrix))))
             ((string-equal command "rotate")
              ;;(format t "Rotating...~%")
              (let ((matrix (apply 'make-rotation-matrix arguments)))
                (set-coordinate-system
                 (matrix-matrix-mult (get-coordinate-system) matrix))))
             ((string-equal command "push")
              ;;(format t "Pushing...~%")
              (push-coordinate-system))
             ((string-equal command "pop")
              ;;(format t "Popping...~%")
              (pop-coordinate-system))
             ((string-equal command "clear")
              ;;(format t "Clearing...~%")
              (clear-edge-matrix)
              (clear-triangle-matrix))
             ((string-equal command "display")
              ;;(format t "Displaying...~%")
              (display))
             ((string-equal command "save")
              ;;(format t "Saving...~%")
              (let ((filename (string-trim '(#\Space #\Return) (car arguments))))
                (create filename)
                (format t "Saved ~a~%" filename))))))))
