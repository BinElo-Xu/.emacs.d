;;; init-project.el --- Project management configuration -*- lexical-binding: t; -*-

;;; Commentary:
;; Configuration built on project.el.
;;
;; Project commands use the standard `C-x p' prefix.  That prefix is not
;; shadowed by Evil, so it already works in normal and visual state.  For
;; convenience this file also binds:
;;
;;   `gp'   to the project prefix map in Evil normal state;
;;   `C-c P' to the same map, for use from other states.
;;
;; Eglot uses `project-current' to decide which server instance manages a
;; buffer.  Python projects are recognized by the markers configured in
;; init-python.el, so `C-x p', Consult and Eglot all agree on the project root.

;;; Code:

(require 'project)

;;; Project registry

;; Keep the project list with the other runtime data under `var/'.  In Emacs 31
;; the default already points here because `user-emacs-directory' is redirected,
;; but setting it explicitly documents the location and keeps older versions
;; consistent.
(setq project-list-file (locate-user-emacs-file "projects.eld"))

(defun my/project-remember-on-visit ()
  "Remember the current project when a local file is visited.
This keeps `C-x p p' useful even for projects that were opened
directly from a file instead of through `project-switch-project'.
Remote files are skipped to avoid slow TRAMP lookups."
  (when (and buffer-file-name
             (not (file-remote-p buffer-file-name)))
    (when-let* ((project (project-current)))
      (project-remember-project project))))

(add-hook 'find-file-hook #'my/project-remember-on-visit)

;;; Switching and dispatch

;; `consult-project-buffer' is bound to `C-x p b' in init-completion.el.  Use
;; the same command in the `C-x p p' dispatch menu so both entry points behave
;; alike.
(setq project-switch-commands
      '((consult-project-buffer "Project buffer" ?b)
        (project-find-file "Find file" ?f)
        (project-find-regexp "Find regexp" ?g)
        (project-find-dir "Find directory" ?d)
        (project-vc-dir "VC-Dir" ?v)
        (project-shell "Shell" ?s)
        (project-eshell "Eshell" ?e)
        (project-compile "Compile" ?c)
        (project-any-command "Other" ?o)))

;; Accept every key from `project-prefix-map' in the `C-x p p' dispatch menu,
;; not only the entries listed above.  This keeps additions from language
;; modules and future Emacs versions available without editing this list.
(setq project-switch-use-entire-map t)

;; Show the project name in the mode line for local buffers.  Avoid looking up
;; remote projects on every mode-line update.
(setq project-mode-line 'non-remote)

;; Give each project its own compilation buffer.
(setq project-compilation-buffer-name-function
      #'project-prefixed-buffer-name)

;; Show the buffers that will be killed before asking for confirmation.
(setq project-kill-buffers-display-buffer-list t)

;; Keep the built-in Buffer Menu for `project-list-buffers'.  Ibuffer is not
;; used for project buffer listings.
(setq project-buffers-viewer #'project-list-buffers-buffer-menu)

;; Extra project commands that are useful but do not have a default key.
(keymap-set project-prefix-map "R" #'project-remember-projects-under)
(keymap-set project-prefix-map "X" #'project-forget-project)
(keymap-set project-prefix-map "Z" #'project-forget-zombie-projects)

;; Remove the temporary `C-x p B' binding from the earlier configuration when
;; this file is re-evaluated in a running Emacs.
(keymap-unset project-prefix-map "B")

;;; Evil and global bindings

;; Evil does not bind `C-x' in normal state, so `C-x p' already reaches
;; `project-prefix-map'.  Add a Vim-like `gp' prefix for normal state and a
;; state-independent `C-c P' alias for convenience.
(declare-function evil-define-key* "evil"
                  (state keymap key def &rest bindings))

(with-eval-after-load 'evil
  (evil-define-key* 'normal 'global (kbd "gp") project-prefix-map))

(keymap-global-set "C-c P" project-prefix-map)

(provide 'init-project)

;;; init-project.el ends here.
