(asdf:defsystem synthy
  :components ((:file "package")
               (:file "toolkit")
               (:file "synthy")
               (:file "main")
               (:file "ui"))
  :depends-on (:trial-glfw
               :trial-harmony
               :trial-alloy))
