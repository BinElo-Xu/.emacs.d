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

;; project.el integration: project list, dispatch menu, and Evil-friendly
;; project keybindings.
(require 'init-project)

;; Evil-style keybindings for the minibuffer (candidate navigation, editing
;; keys).  It has to be loaded after init-completion (Vertico) and init-evil.
(require 'init-minibuffer)

;; visual-line-mode and visual-fill-column for prose buffers.
(require 'init-visual-line)

;; org-mode configuration.
(require 'init-org)

;; Tree-sitter grammar installation and major-mode remapping.  Language modules
;; use `my/treesit-enable' to select their Tree-sitter major mode.
(require 'init-treesit)

;; Language Server Protocol support.  Generic Eglot behavior lives in
;; init-eglot; each language keeps its own settings in init-<language>.el and
;; registers its server with `my/eglot-register'.  Add new language files here.
(require 'init-eglot)
(require 'init-python)

