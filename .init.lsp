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

(define(include:include lsp (ctx 'MAIN)) (let(
  flag nil
  path nil
  dirs (push (real-path) (copy DIRS))
  )
  (dolist(e dirs flag)
    (setq path (append e "/" lsp ".lsp"))
    (when(file? path true)
      (load path ctx)
      (setq flag true)))
  (unless flag
    (throw-error (append "Not loaded! : '" lsp "'")))))


(context 'require)

(setq inloaded '())

(define(require:require)
  (map (fn(a)
          (when(nil? (find a inloaded))
            (push a inloaded)
            (include a)))
       (flat (args))))
