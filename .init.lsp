;; vim:ts=2:sw=2:et:
;;
;; simple loaders for the newLISP
;;
(context 'include)

(let(
  homedir (env "HOME")
  nlspdir (env "NEWLISPDIR")
  )
  (constant 'DIRS (unique (clean nil? (list
    (append homedir "/.local/share/newlisp")
    (append homedir "/.local/bin")
    (append homedir "/bin")
    "/usr/local/share/newlisp"
    "/usr/share/newlisp"
    nlspdir)))))

(define(include:include alsp (ctx 'MAIN)) (let(
  rslt nil
  path nil
  dirs (append (list (real-path)) DIRS)
  )
  (dolist(e dirs rslt)
    (setq path (append e "/" alsp ".lsp"))
    (when(file? path true)
      (setq rslt (load path ctx))))
  (unless(true? rslt)
    (throw-error (append "Not loaded! : '" alsp "'")))))


(context 'require)

(setq dbase '())

(define(require:require)
  (map
    (fn(a)
      (when(nil? (find a dbase))
        (push a dbase)
        (include a)))
    (flat (args))))
