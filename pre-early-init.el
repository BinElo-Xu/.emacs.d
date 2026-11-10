;;; pre-early-init.el --- load before early-init.el -*- no-byte-compile: t; lexical-binding: t; -*-

;;; Reducing clutter in ~/.emacs.d by redirecting files to ~/.emacs.d/var/
;; NOTE: This must be placed in 'pre-early-init.el'.
(setq user-emacs-directory (expand-file-name "var/" minimal-emacs-user-directory))
(setq package-user-dir (expand-file-name "elpa" user-emacs-directory))

;; `native-comp-eln-load-path' is initialized before early-init runs, so it
;; still points at "~/.emacs.d/eln-cache" unless it is redirected here.
(when (fboundp 'startup-redirect-eln-cache)
  (startup-redirect-eln-cache
   (expand-file-name "eln-cache/" user-emacs-directory)))

