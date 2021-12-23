(in-package #:org.shirakumo.synthy)

(defclass ui (org.shirakumo.fraf.trial.alloy:ui
              org.shirakumo.alloy:smooth-scaling-ui
              org.shirakumo.alloy.renderers.simple.presentations:default-look-and-feel)
  ((alloy:target-resolution :initform (alloy:px-size 1280 720))
   (alloy:base-scale :initform 2.0)))

(defmethod org.shirakumo.alloy.renderers.opengl.msdf:fontcache-directory ((ui ui))
  (trial:pool-path 'synthy "font-cache/"))

(trial:define-shader-pass ui-pass (ui)
  ((trial:name :initform 'ui-pass)
   (trial:color :port-type trial:output :attachment :color-attachment0)
   (trial:depth :port-type trial:output :attachment :depth-stencil-attachment)))

(defmethod trial:render :before ((pass ui-pass) target)
  (gl:clear-color 0 0 0 0))

(defmethod trial:stage ((pass ui-pass) (area trial:staging-area))
  (call-next-method)
  (trial:stage (simple:request-font pass :default) area)
  (trial:stage (trial:framebuffer pass) area))

(defmethod trial:compile-to-pass (object (pass ui-pass)))
(defmethod trial:compile-into-pass (object container (pass ui-pass)))
(defmethod trial:remove-from-pass (object (pass ui-pass)))

;; KLUDGE: No idea why this is necessary, fuck me.
(defmethod simple:request-font :around ((pass ui-pass) font &key)
  (let ((font (call-next-method)))
    (unless (and (alloy:allocated-p font)
                 (trial:allocated-p (org.shirakumo.alloy.renderers.opengl.msdf:atlas font)))
      (trial:commit font (trial:loader +main+) :unload NIL))
    font))

(defmethod trial:setup-scene ((main main) scene)
  (trial:enter (make-instance 'ui-pass) scene))

(defmethod initialize-instance :after ((pass ui-pass) &key)
  (let ((layout (make-instance 'alloy:fullscreen-layout :layout-parent (alloy:layout-tree pass)))
        (focus (make-instance 'alloy:focus-list :focus-parent (alloy:focus-tree pass)))
        (synth (synth +main+)))
    (let ((props (make-instance 'alloy:grid-layout :col-sizes '(200 T) :row-sizes '(30) :layout-parent layout))
          (wave (alloy:represent (wave-form synth) 'alloy:combo-set :value-set '(:sine :square :triangle :sawtooth) :focus-parent focus))
          (rise (alloy:represent (rise-time synth) 'alloy:ranged-slider :range '(0.0 . 2.0) :focus-parent focus))
          (keep (alloy:represent (keep-time synth) 'alloy:ranged-slider :range '(0.0 . 2.0) :focus-parent focus))
          (fall (alloy:represent (fall-time synth) 'alloy:ranged-slider :range '(0.0 . 2.0) :focus-parent focus)))
      (alloy:enter-all props "Wave" wave "Rise" rise "Keep" keep "Fall" fall))))
