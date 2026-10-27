;;; init-treesit.el --- Generic Tree-sitter configuration -*- lexical-binding: t; -*-

;;; Commentary:
;; Shared Tree-sitter setup for language modules.
;;
;; Emacs 31 can download and build missing grammar libraries on demand.  This
;; file enables that behavior once for all languages and provides
;; `my/treesit-enable', which language modules use to choose the Tree-sitter
;; major mode for a file type:
;;
;;   (my/treesit-enable 'python-mode 'python-ts-mode 'python)
;;
;; The first time a Tree-sitter mode is used, its grammar is installed into
;; the `tree-sitter' directory under `user-emacs-directory' (here
;; `~/.emacs.d/var/tree-sitter').  Later sessions load the compiled grammar
;; directly.  Installation requires Git and a C compiler on `exec-path'.
;;
;; On Emacs versions without `treesit-auto-install-grammar' (before 31.1), the
;; remapping is only installed when the grammar is already available; install
;; it manually with `M-x treesit-install-language-grammar' or set
;; `my/treesit-auto-install' to nil and manage grammars yourself.

;;; Code:

(require 'treesit)

(defcustom my/treesit-auto-install t
  "Whether to install missing Tree-sitter grammars automatically.
This uses Emacs 31's `treesit-auto-install-grammar'.  Set it to
nil if grammars should only be installed manually."
  :type 'boolean
  :group 'treesit)

(when (and my/treesit-auto-install
           (boundp 'treesit-auto-install-grammar))
  (setq treesit-auto-install-grammar 'always))

(defun my/treesit-enable (mode ts-mode &optional language)
  "Use TS-MODE for buffers that would normally use MODE.

TS-MODE is the Tree-sitter major mode and MODE its non-Tree-sitter
counterpart.  LANGUAGE is the grammar name and defaults to the
name of TS-MODE without its `-ts-mode' suffix.

The remapping is only installed when Tree-sitter is available and
either automatic grammar installation is enabled (Emacs 31) or the
grammar is already installed."
  (let* ((language (or language
                       (intern (replace-regexp-in-string
                                "-ts-mode\\'" "" (symbol-name ts-mode)))))
         (auto-install (and (boundp 'treesit-auto-install-grammar)
                            my/treesit-auto-install)))
    (when (and (treesit-available-p)
               (or auto-install
                   (treesit-language-available-p language)))
      (add-to-list 'major-mode-remap-alist (cons mode ts-mode)))))

(provide 'init-treesit)

;;; init-treesit.el ends here.
