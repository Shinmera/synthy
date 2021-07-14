(in-package #:org.shirakumo.synthy)

(defvar +main+ NIL)

(defclass main (trial:main)
  ((synth :initform (make-instance 'synth) :accessor synth)))

(defmethod initialize-instance :before ((main main) &key)
  (setf +main+ main))

(defmethod initialize-instance :after ((main main) &key)
  (let* ((server (make-instance 'harmony:server :name "Synthy" :samplerate 44100))
         (output (harmony::construct-output :server server :source-channels 2 :target-channels 2))
         (synth (synth main)))
    (harmony:connect synth T (harmony:segment 0 output) T)
    (let ((segments (mixed:segments output)))
      (mixed:match-channel-order (aref segments (- (length segments) 2))
                                 (mixed:channel-order (aref segments (- (length segments) 1)))))
    (harmony:add-to server synth output)
    (mixed:start server)))

(defmethod trial:finalize :after ((main main))
  (setf +main+ NIL)
  (mixed:end harmony:*server*)
  (mixed:free harmony:*server*))

(defmethod trial:handle ((ev trial:key-event) (main main))
  (typecase ev
    (trial:key-press (synth-input (synth main) (trial:key ev) :down))
    (trial:key-release (synth-input (synth main) (trial:key ev) :up))))

(defun launch (&rest initargs)
  (apply #'trial:launch 'main initargs))
