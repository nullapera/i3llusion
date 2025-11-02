;; vim:ts=2:sw=2:et:
;;
;;  (require "rebox")
;;
;;  (setq rb (rebox {RB} '(([] "alfa" 1 2) (3 4) ([] "beta" 5 6)))) or
;;  (begin
;;    (rebox {RB} '(([] "alfa") () ([] "beta")))
;;    (setq rb (RB '(1 2) '(3 4) '(5 6))))
;;  (rb RB:_alfa) or (rb (RB:alfa)) or (rb (:alfa rb)) => (1 2)
;;  (rb (RB:alfa 1)) or (rb (:alfa rb 1)) => 2
;;  (++ (rb (RB:beta 1))) or (++ (rb (:beta rb 1))) => 7
;;
(global (constant '[] '[]))

(context 'rebox)

(define (rebox:rebox ctxname lst) (letn (
  ctx (new Class (sym ctxname MAIN))
  rf (ref '[] (push ctx lst))
  )
  (while rf
    (pop rf -1)
    (letex (
      _rf rf
      nm (begin (pop (lst rf)) (pop (lst rf)))
      )
      (context ctx nm (lambda () (append '_rf (args))))
      (context ctx (string "_" nm) '_rf))
    (setq rf (ref '[] lst)))
  lst))
