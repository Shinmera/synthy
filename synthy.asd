(asdf:defsystem synthy
  :serial T
  :components ((:file "package")
               (:file "toolkit")
               (:file "synthy")
               (:file "main")
               (:file "ui"))
  :depends-on (:trial-glfw
               :trial-harmony
               :trial-alloy)
  :build-operation "deploy-op"
  :build-pathname "synthy"
  :entry-point "org.shirakumo.synthy:launch"
  :defsystem-depends-on (:deploy))
