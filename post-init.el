;;; post-init.el --- load after init.el, mainly include package relative configuration. -*- no-byte-compile: t; lexical-binding: t; -*-

;; this file can set the build in buildin theme
(require 'init-theme)

;; this package ensure ensure that byte-compiled and
;; native compailed.
(require 'init-sysEnv)

;; this package install xclip for clipborad integration.
(require 'init-clipboard)

;; this package recentf, savehist, saveplace and
;; auto-revert. Which for file management and
;; history.
(require 'init-file)

;; completion system configuration. Corfu can enhence in-buffer completion. Cape
;; extends the capabilities of in-buiffer completion.
(require 'init-completion)

;; evil relative configuration.
(require 'init-evil)

;; org-mode configuration.
(require 'init-org)

