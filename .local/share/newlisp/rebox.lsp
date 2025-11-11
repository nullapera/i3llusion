;; vim:ts=2:sw=2:et:
;;
;;  (require "rebox")
;;
;;  (setq rb (rebox {RB} '(([] "alfa" 1 2) (3 4) ([] "beta" 5 6))))
;;  (rb RB:_alfa) or (rb (RB:alfa)) => (1 2)
;;  (rb (RB:alfa 1)) => 2
;;  (++ (rb (RB:beta 1))) => 7
;;
(global (constant '[] '[]))

(context 'rebox)

(define (rebox:rebox ctxname (lst '())) (let (
  ctx (new Class (sym ctxname MAIN))
  rf (ref [] lst)
  )
  (while rf
    (pop rf -1)
    (pop (lst rf))
    (tag ctx (pop (lst rf)) rf)
    (setq rf (ref [] lst)))
  lst))

(define (tag ctx nm rf) (letex (
  rf rf
  )
  (context ctx nm (lambda () (append 'rf (args))))
  (context ctx (string "_" nm) 'rf)))
