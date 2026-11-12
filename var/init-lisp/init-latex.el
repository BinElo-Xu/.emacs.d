;;; init-latex.el --- Org LaTeX preview and LaTeX editing -*- lexical-binding: t; -*-

;;; Commentary:
;; This module covers two workflows:
;;
;; 1. Rendering and editing LaTeX fragments in Org.  org-fragtog automatically
;;    toggles the preview when point enters/leaves a fragment, and CDLaTeX
;;    provides fast math input inside Org math fragments.
;;
;; 2. Editing .tex files with AUCTeX + RefTeX.  XeLaTeX is the default engine
;;    because it works well with Chinese documents.  `C-c C-c' compiles,
;;    `C-c C-v' opens the PDF in pdf-tools, and SyncTeX connects the source and
;;    PDF positions.
;;
;; PDF reading itself, including pdf-tools setup, theme following, and its
;; keybindings, lives in init-pdf.el.

;;; Code:

(require 'seq)
(require 'subr-x)

(defvar org-latex-default-packages-alist)
(defvar org-preview-latex-image-directory)

(declare-function org--latex-preview-region "org" (beg end))
(declare-function org-cdlatex-mode "org" (&optional arg))
(declare-function TeX-source-correlate-mode "tex" (&optional arg))
(declare-function reftex-mode "reftex" (&optional arg))

;;; LaTeX fragments in Org

(defun my/org-latex-drop-missing-packages ()
  "Drop unavailable packages from Org's default LaTeX package list.
Some minimal TeX Live installations do not ship `ulem.sty'.  Org's
default export package list includes `ulem', which makes formula
preview fail with \"File ...dvi wasn't produced\"."
  (when (and (executable-find "kpsewhich")
             (string-empty-p
              (string-trim
               (shell-command-to-string "kpsewhich ulem.sty"))))
    (setq org-latex-default-packages-alist
          (seq-remove (lambda (entry)
                        (equal (nth 1 entry) "ulem"))
                      org-latex-default-packages-alist))))

(with-eval-after-load 'ox-latex
  (my/org-latex-drop-missing-packages))

;;; Org LaTeX preview cache

;; Org always writes preview images to disk.  Keep them out of the notes
;; directories, in a per-Emacs cache under `var/'.  The cache is cleaned at
;; startup (stale sessions) and at exit (current session).
(defvar my/org-latex-preview-cache
  (expand-file-name (format "ltximg/%d/" (emacs-pid)) user-emacs-directory)
  "Directory for generated Org LaTeX preview images.")

(defun my/org-latex-preview--use-cache (fn beg end)
  "Bind Org's preview image directory to the private cache for FN.
FN is `org--latex-preview-region'; BEG and END are the preview region."
  (make-directory my/org-latex-preview-cache t)
  (let ((org-preview-latex-image-directory my/org-latex-preview-cache))
    (funcall fn beg end)))

(defun my/org-latex-cleanup-preview-cache ()
  "Delete LaTeX preview caches left by Emacs sessions that have exited.
On systems where process IDs can be queried, only caches whose Emacs
process is no longer alive are removed.  This avoids deleting previews
used by another running Emacs instance."
  (let ((root (expand-file-name "ltximg/" user-emacs-directory))
        (processes (and (fboundp 'list-system-processes)
                        (list-system-processes))))
    (when (file-directory-p root)
      (dolist (dir (directory-files root t "\\`[0-9]+\\'"))
        (let ((pid (string-to-number (file-name-nondirectory dir))))
          (when (and (file-directory-p dir)
                     (or (not processes)
                         (not (memq pid processes))))
            (ignore-errors (delete-directory dir t))))))))

(defun my/org-latex-cleanup-current-preview-cache ()
  "Delete this Emacs session's LaTeX preview cache."
  (when (file-directory-p my/org-latex-preview-cache)
    (ignore-errors (delete-directory my/org-latex-preview-cache t))))

(with-eval-after-load 'org
  (unless (advice-member-p #'my/org-latex-preview--use-cache
                           'org--latex-preview-region)
    (advice-add 'org--latex-preview-region :around
                #'my/org-latex-preview--use-cache)))

(add-hook 'emacs-startup-hook #'my/org-latex-cleanup-preview-cache)
(add-hook 'kill-emacs-hook #'my/org-latex-cleanup-current-preview-cache)

(use-package org-fragtog
  :ensure t
  :hook (org-mode . org-fragtog-mode))

(use-package cdlatex
  :ensure t
  :hook (LaTeX-mode . cdlatex-mode))

;; `org-cdlatex-mode' is provided by Org itself and uses the cdlatex package.
(add-hook 'org-mode-hook #'org-cdlatex-mode)

;;; LaTeX editing with AUCTeX

(defun my/latex-mode-setup ()
  "Set up AUCTeX buffers for PDF/SyncTeX and reference completion."
  (TeX-source-correlate-mode 1)
  (reftex-mode 1))

(use-package tex
  :ensure auctex
  :defer t
  :mode ("\\.tex\\'" . LaTeX-mode)
  :init
  ;; These are buffer-local variables in AUCTeX, so set their defaults before
  ;; the first .tex file is opened.  Change `xetex' to `default' (pdfLaTeX)
  ;; or `luatex' if a project needs another engine.
  (setq-default TeX-engine 'xetex
                TeX-command-default "LaTeX"
                TeX-master nil
                TeX-parse-self t
                TeX-auto-save t
                TeX-source-correlate-method 'synctex
                TeX-view-program-selection '((output-pdf "PDF Tools")))
  :hook
  (LaTeX-mode . my/latex-mode-setup))

(provide 'init-latex)

;;; init-latex.el ends here
