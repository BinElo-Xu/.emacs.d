;;; pre-init.el --- load before init.el -*- no-byte-compile: t; lexical-binding: t; -*-

(add-to-list 'load-path (expand-file-name "init-lisp" user-emacs-directory))

;; set the relative line number. 
(setq display-line-numbers-type 'relative)

;; relative number only open when programming.
(add-hook 'prog-mode-hook #'display-line-numbers-mode)

;; set the global fill-column-indicator
(global-display-fill-column-indicator-mode 1)

;; pre-init.el ends here.
