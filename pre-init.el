;;; pre-init.el --- load before init.el -*- no-byte-compile: t; lexical-binding: t; -*-

(add-to-list 'load-path (expand-file-name "init-lisp" user-emacs-directory))

;; set the relative line number. 
(setq display-line-numbers-type 'relative)

;; emacs clipborad integration
(setq select-enable-clipboard t)

;; relative number only open when programming.
(add-hook 'prog-mode-hook #'display-line-numbers-mode)

