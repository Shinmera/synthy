(in-package #:org.shirakumo.synthy)

(defstruct (input (:constructor make-input (key))
                  (:copier NIL)
                  (:predicate NIL))
  (key NIL :type keyword :read-only T)
  (state :rise :type keyword)
  (clock 0.0 :type single-float)
  (state-start 0.0 :type single-float)
  (level 0.0 :type single-float))

(defclass synth (mixed:virtual)
  ((keys :initform () :accessor keys)
   (rise-time :initform 0.5 :accessor rise-time)
   (keep-time :initform 0.2 :accessor keep-time)
   (fall-time :initform 1.0 :accessor fall-time)))

(defmethod mixed:info ((synth synth))
  '(:name "Synth"
    :description "Simple synthesizer"
    :flags ()
    :min-inputs 0
    :max-inputs 0
    :outputs 2
    :fields ()))

(defmethod mixed:start ((synth synth)))
(defmethod mixed:end ((synth synth)))

(defun synthesize (synth input dt)
  (let ((output 0.0)
        (pan 0.0)
        (level (input-level input))
        (clock (input-clock input)))
    (flet ((generate ()
             (let ((frequency (key-frequency (input-key input))))
               (* level (sin (float (* 2 PI frequency clock) 0f0)))))
           (handle-state (max-time next level-change)
             (cond ((<= (+ (input-state-start input) max-time) clock)
                    (setf (input-state input) next)
                    (setf (input-state-start input) clock))
                   (T
                    (setf level (min 1.0 (max 0.0 (+ level level-change))))))))
      (ecase (input-state input)
        (:rise
         (handle-state (rise-time synth) :hold (/ dt (max 0.01 (rise-time synth))))
         (setf output (generate)))
        (:hold
         (setf output (generate)))
        (:keep
         (handle-state (keep-time synth) :fall 0.0)
         (setf output (generate)))
        (:fall
         (handle-state (fall-time synth) :dead (- (/ dt (max 0.01 (fall-time synth)))))
         (setf output (generate)))
        (:dead)))
    (setf (input-level input) level)
    (setf (input-clock input) (+ clock dt))
    (values output pan)))

(defmethod mixed:mix ((synth synth))
  (let* ((outputs (mixed:outputs synth))
         (lbuf (aref outputs 0))
         (rbuf (aref outputs 1))
         (dt (/ 1.0 mixed:*default-samplerate*))
         (volume 0.2))
    (mixed:with-buffer-tx (l lstart size lbuf :direction :output)
      (mixed:with-buffer-tx (r rstart size rbuf :direction :output :size size)
        (loop for i from 0 below size
              for ls = 0.0
              for rs = 0.0
              do (dolist (input (keys synth))
                   (multiple-value-bind (sample pan) (synthesize synth input dt)
                     (incf ls (* sample (max 0.0 (- 1.0 pan))))
                     (incf rs (* sample (max 0.0 (+ 1.0 pan))))))
                 (setf (aref l (+ lstart i)) (* volume ls))
                 (setf (aref r (+ rstart i)) (* volume rs)))
        (mixed:finish-write lbuf size)
        (mixed:finish-write rbuf size)))
    (setf (keys synth) (delete :dead (keys synth) :key #'input-state))))

(defmethod synth-input ((synth synth) key state)
  (let ((input (find key (keys synth) :key #'input-key)))
    (ecase state
      (:down
       (if input
           (setf (input-clock input) 0.0
                 (input-state input) :rise)
           (push (make-input key) (keys synth))))
      (:up
       (when input
         (setf (input-state-start input) (input-clock input))
         (setf (input-state input) :keep))))))
