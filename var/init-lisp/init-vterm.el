;;; init-vterm.el --- VTerm terminal with Evil integration -*- lexical-binding: t; -*-

;;; Commentary:
;; VTerm is a libvterm-based terminal emulator.
;;
;;   `C-c t'  open a terminal in the current project root
;;   `C-c T'  open it in another window
;;
;; Each project gets its own VTerm buffer.  Without a project the terminal
;; starts in the current directory and uses the default `*vterm*' buffer name.
;;
;; Evil integration comes from evil-collection's vterm support.  New terminals
;; start in insert state; normal state has prompt-aware motions and operators.
;; `C-c C-z' toggles whether ESC is sent to the terminal or handled by Evil.
;; The latter is important for shells that use ESC, and for programs such as
;; Vim or an Emacs running over SSH.
;;
;; The vterm module is compiled on first use and needs CMake and libvterm.

;;; Code:

(require 'project)
(require 'subr-x)

;; `vterm-buffer-name' is defined by the vterm package, which is loaded
;; lazily.  Declare it so the project-specific `let' binding below is dynamic
;; rather than a lexical variable.
(defvar vterm-buffer-name)
(defvar vterm-copy-mode)
(defvar vterm-copy-mode-map)

(declare-function evil-define-key* "evil"
                  (state keymap key def &rest bindings))
(declare-function evil-insert-state "evil" ())
(declare-function evil-normal-state "evil" ())
(declare-function vterm-copy-mode-done "vterm" (&optional arg))
(declare-function vterm-end-of-line "vterm" ())

;;; Project-aware terminal commands

(defun my/vterm--root ()
  "Return the current project root, or `default-directory'."
  (if-let* ((project (project-current)))
      (file-name-as-directory (project-root project))
    default-directory))

(defun my/vterm--buffer-name ()
  "Return a VTerm buffer name for the current project."
  (if-let* ((project (project-current)))
      (format "*vterm:%s*" (project-name project))
    "*vterm*"))

(defun my/vterm (&optional arg)
  "Open a VTerm in the current project root.
With prefix ARG, create or switch to a numbered VTerm session."
  (interactive "P")
  (let ((default-directory (my/vterm--root))
        (vterm-buffer-name (my/vterm--buffer-name)))
    (vterm arg)))

(defun my/vterm-other-window (&optional arg)
  "Open a VTerm in another window, in the current project root.
With prefix ARG, create or switch to a numbered VTerm session."
  (interactive "P")
  (let ((default-directory (my/vterm--root))
        (vterm-buffer-name (my/vterm--buffer-name)))
    (vterm-other-window arg)))

;;; Evil and terminal behavior

(defun my/vterm-setup ()
  "Configure the current VTerm buffer for Evil and terminal use."
  ;; vterm-cursor position is meaningful; do not move it backwards when
  ;; leaving insert state.
  (setq-local evil-move-cursor-back nil)
  (when (bound-and-true-p evil-mode)
    (evil-insert-state)))

(defun my/vterm-copy-mode-evil-sync (&rest _)
  "Keep Evil state in sync with `vterm-copy-mode'.
Copy mode is a read-only navigation mode, so use Evil normal state there;
return to insert state when copy mode is left."
  (when (and (derived-mode-p 'vterm-mode)
             (bound-and-true-p evil-mode))
    (if vterm-copy-mode
        (evil-normal-state)
      (evil-insert-state))))

(use-package vterm
  :ensure t
  :commands (vterm vterm-other-window)
  :custom
  ;; Use the login shell from the environment, with a portable fallback.
  (vterm-shell (or (getenv "SHELL") shell-file-name))
  (vterm-term-environment-variable "xterm-256color")
  ;; Ask programs that support it for true-color output.
  (vterm-environment '("COLORTERM=truecolor"))
  (vterm-max-scrollback 100000)
  (vterm-kill-buffer-on-exit t)
  (vterm-always-compile-module t)
  ;; Make search/copy in copy mode work with visual lines.
  (vterm-copy-mode-remove-fake-newlines t)
  (vterm-copy-exclude-prompt t)
  :hook
  (vterm-mode . my/vterm-setup))

;; evil-collection registers its vterm bindings when vterm is loaded.  Keep the
;; terminal cursor in place when leaving insert state, as recommended by the
;; vterm documentation.
(with-eval-after-load 'evil-collection-vterm
  (setq evil-collection-vterm-move-cursor-back nil))

;; Copy mode is read-only navigation; use Evil normal state while it is active.
;; Evil's normal-state map shadows a few keys that vterm-copy-mode provides, so
;; restore the useful ones explicitly.
(with-eval-after-load 'vterm
  (unless (advice-member-p #'my/vterm-copy-mode-evil-sync 'vterm-copy-mode)
    (advice-add 'vterm-copy-mode :after #'my/vterm-copy-mode-evil-sync))
  (with-eval-after-load 'evil
    (evil-define-key* 'normal vterm-copy-mode-map
      (kbd "C-e") #'vterm-end-of-line
      (kbd "RET") #'vterm-copy-mode-done
      (kbd "<return>") #'vterm-copy-mode-done)))

;;; Keybindings

(keymap-global-set "C-c t" #'my/vterm)
(keymap-global-set "C-c T" #'my/vterm-other-window)

(provide 'init-vterm)

;;; init-vterm.el ends here.
