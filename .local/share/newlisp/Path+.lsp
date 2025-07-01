;; vim:ts=2:sw=2:et:
;;
(require "isinPATH")
(isinPATH true "ln" "rm")

(require "Cmd" "Path" "isa" "splat")

(context Path)

(define (Path:directory?)
  (MAIN:directory? (:dirname (self))))

(define (Path:file?)
  (splat MAIN:file? (cons (:path (self)) (args))))

(define (Path:change-dir)
  (MAIN:change-dir (:dirname (self))))

(define (Path:copy-file topath)
  (MAIN:copy-file (:path (self))
    (if (isa topath MAIN:Path) (:path topath) topath)))

(define (Path:delete-file)
  (MAIN:delete-file (:path (self))))

(define (Path:directory)
  (splat MAIN:directory (cons (:dirname (self)) (args))))

(define (Path:file-info)
  (splat MAIN:file-info (cons (:path (self)) (args))))

(define (dir-info)
  (splat MAIN:file-info (cons (:dirname (self)) (args))) )

(define (Path:make-dir)
  (splat MAIN:make-dir (cons (:dirname (self)) (args))))

(define (Path:remove-dir)
  (MAIN:remove-dir (:dirname (self))))

(define (Path:rename-file topath)
  (MAIN:rename-file (:path (self))
    (if (isa topath MAIN:Path) (:path topath) topath)))

(define (rename-dir topath)
  (MAIN:rename-file (:dirname (self))
    (if (isa topath MAIN:Path) (:dirname topath) topath)))

(define (Path:read-file)
  (MAIN:read-file (:path (self))))

(define (Path:append-file str)
  (MAIN:append-file (:path (self)) str))

(define (Path:write-file str)
  (MAIN:write-file (:path (self)) str))

(constant
  'ln (Cmd {ln} "-s -f" "; echo $?")
  'rm (Cmd {rm} "-r" "; echo $?"))

(define (symlink-file topath relative?) (let (
  rslt (:run ln
    (format (if relative? {-r '%s' '%s'} {'%s' '%s'})
            (:path (self))
            (if (isa topath MAIN:Path) (:path topath) topath)))
  )
  (= rslt '("0"))))

(define (symlink-dir topath relative?) (let (
  rslt (:run ln
    (format (if relative? {-r '%s' '%s'} {'%s' '%s'})
            (:dirname (self))
            (if (isa topath MAIN:Path) (:dirname topath) topath)))
  )
  (= rslt '("0"))))

(define (rm-dir) (let (
  rslt (:run rm (format {'%s'} (:dirname (self))))
  )
  (= rslt '("0"))))
