;;; init-eglot.el --- Generic Eglot configuration -*- lexical-binding: t; -*-

;;; Commentary:
;; Generic Language Server Protocol support built on Eglot.
;;
;; This file intentionally contains no language-specific server entries.  A
;; language is configured in its own `init-<language>.el' file with
;; `my/eglot-register', for example:
;;
;;   (my/eglot-register '(python-mode python-ts-mode)
;;     :server (my/eglot-contact-fallback
;;              '(("basedpyright-langserver" "--stdio")
;;                (:uvx "basedpyright" "basedpyright-langserver" "--stdio"))))
;;
;; Adding a language therefore means adding one file under `var/init-lisp/'
;; and requiring it from `post-init.el'.  The generic Eglot behavior, keymap
;; and server-selection helpers live here and are shared by all languages.

;;; Code:

(require 'eglot)
(require 'project)
(require 'seq)
(require 'subr-x)

;;; Eglot behavior

(setq
 ;; Shut down the server when the last buffer managed by it is killed.  This
 ;; keeps idle language servers from hanging around; a new one is started on
 ;; demand when a file of that project is opened again.
 eglot-autoshutdown t

 ;; Reconnect automatically only if the previous connection lived for at least
 ;; three seconds.  This avoids a reconnect loop when a server crashes at
 ;; startup.
 eglot-autoreconnect 3

 ;; Do not block opening a buffer while the server starts.  The first start of
 ;; a server installed through `uvx' may need to download it, so an
 ;; asynchronous connection is preferable and the timeout is generous.
 eglot-sync-connect nil
 eglot-connect-timeout 120

 ;; Let Eglot manage files reached through xref even when they are outside the
 ;; current project.
 eglot-extend-to-xref t

 ;; A slightly longer idle time reduces the number of didChange notifications
 ;; sent to the server while typing.
 eglot-send-changes-idle-time 0.4

 ;; Show progress in the mode line.
 eglot-report-progress t)

;;; Server selection helpers

(defun my/eglot--uv-tool-command ()
  "Return the command prefix for running a Python tool with uv.
Prefer `uvx'; fall back to `uv tool run' when only `uv' is available."
  (cond
   ((executable-find "uvx")
    (list (executable-find "uvx")))
   ((executable-find "uv")
    (list (executable-find "uv") "tool" "run"))))

(defun my/eglot-contact-fallback (candidates)
  "Return an Eglot contact function that tries CANDIDATES in order.

Each candidate is either a list of strings

  (PROGRAM ARGS...)

which is looked up with `executable-find', or a list starting with
`:uvx'

  (:uvx PACKAGE PROGRAM ARGS...)

which runs PROGRAM from the Python package PACKAGE through `uvx'
\(or `uv tool run' when `uvx' is unavailable).

The returned function is suitable as the CDR of an
`eglot-server-programs' entry.  For example, a contact that
prefers a local program and falls back to `uvx' can be written
as:

  (my/eglot-contact-fallback
   (list (list \"basedpyright-langserver\" \"--stdio\")
         (list :uvx \"basedpyright\" \"basedpyright-langserver\" \"--stdio\")))

The first executable that can be found is used.  If none is
available, starting Eglot signals an error listing the candidates."
  (lambda (&optional _interactive _project)
    (cl-loop
     for candidate in candidates
     for contact =
     (if (eq (car-safe candidate) :uvx)
         (pcase-let ((`(:uvx ,package ,program . ,args) candidate))
           (when-let* ((uv (my/eglot--uv-tool-command)))
             (append uv (list "--from" package program) args)))
       (when-let* ((program (executable-find (car candidate))))
         (cons program (cdr candidate))))
     when contact
     return contact
     finally
     (user-error
      "No usable language server found; tried: %s"
      (mapconcat
       (lambda (candidate)
         (if (eq (car-safe candidate) :uvx)
             (format "uvx --from %s %s"
                     (nth 1 candidate)
                     (nth 2 candidate))
           (car candidate)))
       candidates ", ")))))

;;; Registering languages

(cl-defun my/eglot-register (modes &key server (auto-start t))
  "Register SERVER as the Eglot server for MODES.

MODES is a major mode symbol or a list of major mode symbols.
SERVER is any value accepted as the CDR of an `eglot-server-programs'
entry: a program name, a list of program and arguments, or a
function such as the one returned by `my/eglot-contact-fallback'.

When AUTO-START is non-nil (the default), add `eglot-ensure' to
the hook of every mode in MODES, so Eglot starts automatically in
buffers using that mode.  Pass `:auto-start nil' to start Eglot
manually with `M-x eglot' instead."
  (let ((modes (ensure-list modes)))
    (when server
      (setq eglot-server-programs
            (cons (cons modes server)
                  (seq-remove (lambda (entry)
                                (equal (car entry) modes))
                              eglot-server-programs))))
    (when auto-start
      (dolist (mode modes)
        ;; Run after other mode-hook functions (for example a hook that
        ;; prepares a project-local environment) instead of before them.
        (add-hook (intern (format "%s-hook" mode)) #'eglot-ensure -90)))))

;;; Keymap

(defvar my/eglot-prefix-map
  (let ((map (make-sparse-keymap)))
    (keymap-set map "a" #'eglot-code-actions)
    (keymap-set map "." #'eglot-code-action-quickfix)
    (keymap-set map "o" #'eglot-code-action-organize-imports)
    (keymap-set map "r" #'eglot-rename)
    (keymap-set map "f" #'eglot-format)
    (keymap-set map "F" #'eglot-format-buffer)
    (keymap-set map "d" #'xref-find-definitions)
    (keymap-set map "D" #'xref-find-references)
    (keymap-set map "s" #'xref-find-apropos)
    (keymap-set map "b" #'xref-go-back)
    (keymap-set map "B" #'xref-go-forward)
    (keymap-set map "h" #'eldoc-doc-buffer)
    (keymap-set map "c" #'eglot-show-call-hierarchy)
    (keymap-set map "y" #'eglot-show-type-hierarchy)
    (keymap-set map "i" #'eglot-inlay-hints-mode)
    (keymap-set map "t" #'eglot-semantic-tokens-mode)
    (keymap-set map "e" #'eglot-events-buffer)
    (keymap-set map "l" #'eglot-list-connections)
    (keymap-set map "R" #'eglot-reconnect)
    (keymap-set map "q" #'eglot-shutdown)
    (keymap-set map "Q" #'eglot-shutdown-all)
    map)
  "Prefix map for Eglot commands, bound to `C-c e'.")

(keymap-global-set "C-c e" my/eglot-prefix-map)

;;; Evil integration

;; Evil-collection already binds the standard LSP-like keys in buffers managed
;; by Eglot: `gd' (definition), `gD' (definition in another window), `K'
;; (documentation) and `C-t' (jump back).  Add a Vim-style `gr' prefix for the
;; remaining Eglot commands, so they do not have to leave normal state.
;; The bindings are attached to `eglot-mode-map' and therefore only exist in
;; buffers where Eglot is active.
(declare-function evil-define-key* "evil"
                  (state keymap key def &rest bindings))

(defvar my/eglot-evil-prefix-map
  (let ((map (make-sparse-keymap)))
    (keymap-set map "a" #'eglot-code-actions)
    (keymap-set map "." #'eglot-code-action-quickfix)
    (keymap-set map "c" #'eglot-code-action-organize-imports)
    (keymap-set map "d" #'xref-find-definitions)
    (keymap-set map "D" #'xref-find-definitions-other-window)
    (keymap-set map "r" #'xref-find-references)
    (keymap-set map "i" #'eglot-find-implementation)
    (keymap-set map "t" #'eglot-find-typeDefinition)
    (keymap-set map "n" #'eglot-rename)
    (keymap-set map "f" #'eglot-format)
    (keymap-set map "F" #'eglot-format-buffer)
    (keymap-set map "h" #'eldoc-doc-buffer)
    map)
  "Evil `gr' prefix map for Eglot commands.")

(with-eval-after-load 'evil
  (when (boundp 'eglot-mode-map)
    (evil-define-key* 'normal eglot-mode-map
      (kbd "gd") #'xref-find-definitions
      (kbd "gD") #'xref-find-definitions-other-window
      (kbd "g5") #'xref-find-definitions-other-frame
      (kbd "K") #'eldoc-doc-buffer
      (kbd "C-t") #'xref-go-back
      (kbd "gr") my/eglot-evil-prefix-map)))

(provide 'init-eglot)

;;; init-eglot.el ends here.
