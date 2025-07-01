;; vim:ts=2:sw=2:et:
;;
(require "isa")

(context 'i3ipc)

(constant
  '.SOCKET 1
  'MAGIC "i3-ipc"
  'CMDFMT {[id="%lu"] %s}
  'PACKFMT (format {s%d lu lu} (length MAGIC))
  'PACKFMTLENGTH (length (pack PACKFMT "" 0 0))
  'COMMAND 0
  'GET_WORKSPACES 1
  'SUBSCRIBE 2
  'GET_TREE 4)

(define (i3ipc:i3ipc apath) (letn (
  path (if (isa apath MAIN:Path) (:path apath) apath)
  socket (net-connect path)
  )
  (if socket
    (list (context) socket)
    (throw-error (string (context) " => No connection to: '" path "'")))))

(define (socket)
  (self .SOCKET))

(define (i3ipc:close)
  (net-close (self .SOCKET)))

(define (i3ipc:send msgtype msg)
  (net-send
    (self .SOCKET)
    (append (pack PACKFMT MAGIC (length msg) msgtype) msg)))

(define (i3ipc:receive) (local (
  rslt data
  )
  (net-receive (self .SOCKET) data PACKFMTLENGTH)
  (setq rslt (unpack PACKFMT data))
  (net-receive (self .SOCKET) data (rslt 1))
  data))

(define (chat msgtype msg)
  (send msgtype msg)
  (receive))

(define (command id cmd)
  (chat COMMAND (format CMDFMT id cmd)))

(define (subscribe msg)
  (chat SUBSCRIBE msg))

(define (getworkspaces)
  (chat GET_WORKSPACES ""))

(define (gettree)
  (chat GET_TREE ""))
