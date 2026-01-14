;; vim:ts=2:sw=2:et:
;;
;;  (require "isinPATH")
;;
;;  (isinPATH "ln" "rm") => true
;;  (isinPATH "lnrm" "rmln") => nil
;;  (isinPATH true "lnrm" "rmln") => throw an error
;;
(context 'isinPATH)

(define (isinPATH:isinPATH) (let (
  throw? nil
  missing '()
  )
  (doargs (e)
    (if (= e true)
      (setq throw? true)
      (unless (real-path e true) (push e missing -1))))
  (when (and throw? (true? missing))
    (throw-error
      (append "Non-existing file(s) in PATH! : '" (string missing) "'")))
  (empty? missing)))
