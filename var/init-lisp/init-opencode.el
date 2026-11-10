;;; init-opencode.el --- OpenCode integration via agent-shell -*- lexical-binding: t; -*-

;;; Commentary:
;; OpenCode is driven through agent-shell and its ACP backend:
;;
;;   opencode acp
;;
;; agent-shell provides a native Emacs buffer (comint-based) instead of
;; embedding the OpenCode TUI in VTerm.  That gives us Evil, Corfu/Vertico,
;; project.el, diff-mode, and the rest of the Emacs editing environment.
;;
;;   C-c o o  start or reuse OpenCode in the current project
;;   C-c o n  force a new OpenCode session
;;   C-c o s  send the active region to OpenCode
;;   C-c o d  send region/error at point (DWIM)
;;   C-c o t  toggle the OpenCode shell window
;;
;; OpenCode must be installed and authenticated first:
;;
;;   opencode auth login
;;
;; The integration uses `agent-shell' from MELPA and its OpenCode ACP
;; configuration.  It does not replace the VTerm setup; the two are independent.

;;; Code:

(require 'project)
(require 'subr-x)

;;; Storage and environment

(defun my/opencode--dot-subdir (subdir)
  "Return a storage directory for agent-shell SUBDIR.
Keep OpenCode transcripts and screenshots under `user-emacs-directory'
instead of writing `.agent-shell' into every project."
  (let* ((cwd (or (ignore-errors (agent-shell-cwd))
                  default-directory))
         (cwd (string-remove-suffix "/" cwd))
         (sanitized (replace-regexp-in-string
                     "/" "-" (string-remove-prefix "/" cwd))))
    (expand-file-name
     subdir
     (locate-user-emacs-file (concat "agent-shell/" sanitized)))))

;;; Evil and buffer behavior

(defun my/opencode-mode-setup ()
  "Configure an agent-shell buffer for Evil and OpenCode."
  (setq-local evil-move-cursor-back nil)
  (when (bound-and-true-p evil-mode)
    (evil-insert-state)))

(defun my/opencode-diff-mode-setup ()
  "Use Emacs state in agent-shell diff buffers.
This keeps the diff accept/reject keys (`y', `n', `p', `q') available
without first entering Evil insert state."
  (when (derived-mode-p 'agent-shell-diff-mode)
    (evil-emacs-state)))

;;; Package configuration

(use-package agent-shell
  :ensure t
  :commands (agent-shell
             agent-shell-opencode-start-agent
             agent-shell-toggle
             agent-shell-send-region
             agent-shell-send-dwim)
  :init
  ;; OpenCode is the only agent launched by this configuration.
  (setq agent-shell-preferred-agent-config 'opencode)
  :config
  ;; OpenCode needs HOME/PATH and the credentials written by
  ;; `opencode auth login'.  Inherit the parent environment by default.
  (setq agent-shell-opencode-environment
        (agent-shell-make-environment-variables :inherit-env t))
  ;; Replay the whole conversation when a session is resumed.  The default
  ;; `minimal' only restores the session title.
  (setq agent-shell-session-restore-verbosity 'last)
  (setq agent-shell-dot-subdir-function #'my/opencode--dot-subdir)
  (add-hook 'agent-shell-mode-hook #'my/opencode-mode-setup)
  (add-hook 'agent-shell-diff-mode-hook #'my/opencode-diff-mode-setup)
  (with-eval-after-load 'evil
    (evil-set-initial-state 'agent-shell-mode 'insert)
    (evil-set-initial-state 'agent-shell-diff-mode 'emacs)
    ;; Submit with RET in both states; M-J inserts a newline.  This is more
    ;; convenient for a chat buffer than Evil's comint default (RET newline in
    ;; insert state, submit only in normal state).
    (evil-define-key* 'insert agent-shell-mode-map
      (kbd "RET") #'agent-shell-submit
      (kbd "M-J") #'newline
      (kbd "C-c C-r") #'agent-shell-send-region)
    (evil-define-key* 'normal agent-shell-mode-map
      (kbd "RET") #'agent-shell-submit
      (kbd "M-J") #'newline
      (kbd "C-c C-r") #'agent-shell-send-region
      ;; `evil-collection' binds `gp' in agent-shell buffers to
      ;; `agent-shell-yank-dwim' (paste a clipboard image, otherwise call
      ;; `yank').  That shadows the global `gp' -> project.el prefix and
      ;; signals "Kill ring is empty" when there is nothing to yank.
      ;; Restore the project prefix so `gp f', `gp p', ... work here too.
      (kbd "gp") project-prefix-map)))

;; On an agent-shell fold triangle/header, TAB folds or unfolds that item.
;; Everywhere else TAB remains `agent-shell-next-item'.
(with-eval-after-load 'agent-shell-ui
  (define-key agent-shell-ui-fragment-map
              (kbd "TAB") #'agent-shell-ui-toggle-fragment))

;;; Keybindings

(defvar my/opencode-prefix-map
  (let ((map (make-sparse-keymap)))
    (keymap-set map "o" #'agent-shell)
    (keymap-set map "n" #'agent-shell-opencode-start-agent)
    (keymap-set map "s" #'agent-shell-send-region)
    (keymap-set map "d" #'agent-shell-send-dwim)
    (keymap-set map "t" #'agent-shell-toggle)
    map)
  "Prefix map for OpenCode, bound to `C-c o'.")

(keymap-global-set "C-c o" my/opencode-prefix-map)

(provide 'init-opencode)

;;; init-opencode.el ends here.
