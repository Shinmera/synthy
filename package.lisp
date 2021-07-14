(defpackage #:org.shirakumo.synthy
  (:use #:cl)
  (:nicknames #:synthy)
  (:shadow #:launch #:main)
  (:local-nicknames
   (#:mixed #:org.shirakumo.fraf.mixed)
   (#:harmony #:org.shirakumo.fraf.harmony)
   (#:trial #:org.shirakumo.fraf.trial)
   (#:alloy #:org.shirakumo.alloy)
   (#:simple #:org.shirakumo.alloy.renderers.simple)
   (#:presentations #:org.shirakumo.alloy.renderers.simple.presentations))
  (:export #:launch))
