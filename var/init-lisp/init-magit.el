;;; init-magit.el --- Magit integration for Emacs -*- lexical-binding: t; -*-

;;; Commentary:
;; Magit is configured as the Git interface while preserving the existing
;; Evil, project.el, diff-mode, Corfu/Vertico, and agent-shell workflows.
;;
;;   C-x g    Magit status
;;   C-x p m  Magit status for the current project
;;
;; Evil integration is provided by evil-collection's magit support.  Magit
;; status/log/diff buffers use the Evil normal state; git commit messages use
;; insert state.  `C-t' (or `\') toggles the evil-collection Magit text mode
;; for free movement and copying.

;;; Code:

(require 'project)

(declare-function evil-define-key* "evil"
                  (state keymap key def &rest bindings))
(declare-function evil-set-initial-state "evil" (mode state))
(declare-function evil-collection-magit-toggle-text-mode
                  "evil-collection-magit" ())
(defvar magit-mode-map)

(defun my/magit-project-status ()
  "Open Magit status for the current project.
Respect `project-current-directory-override', which project.el sets
when a project is selected from `project-switch-project'."
  (interactive)
  (let ((default-directory
         (if-let* ((project (project-current)))
             (project-root project)
           default-directory)))
    (magit-status)))

(use-package magit
  :ensure t
  :init
  ;; Make Magit a first-class project command, available before Magit loads.
  (keymap-set project-prefix-map "m" #'my/magit-project-status)
  (add-to-list 'project-switch-commands
               '(my/magit-project-status "Magit" ?m) t)
  :bind
  (("C-x g" . magit-status))
  :custom
  ;; Open Magit status in the current window, but show diffs in another window.
  (magit-display-buffer-function
   #'magit-display-buffer-same-window-except-diff-v1)
  ;; Do not ask to save repository buffers when Magit needs a clean state.
  (magit-save-repository-buffers 'dontask)
  :config
  ;; Keep file buffers in sync after Git operations.
  (magit-auto-revert-mode 1)

  ;; Commit messages are edited in insert state; the rest of the Magit
  ;; buffers are configured by evil-collection-magit.
  (with-eval-after-load 'git-commit
    (evil-set-initial-state 'git-commit-mode 'insert))

  ;; Keep Evil's Magit text-mode toggle and its standard Evil bindings.
  (with-eval-after-load 'evil-collection-magit
    (evil-define-key* 'normal magit-mode-map
      (kbd "C-t") #'evil-collection-magit-toggle-text-mode)))

(provide 'init-magit)

;;; init-magit.el ends here.
