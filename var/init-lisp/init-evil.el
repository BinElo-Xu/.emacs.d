;;; -*- lexical-binding: t -*-

;; this is for solving the bug of "Error in post-command-hook
;; (evil-normal-post-command): (void-variable evil-mode-buffers) [2 times]".

(defvar evil-mode-buffers '() "Workaround for Evil 1.15.0 bug.")

;; Uncomment the following if you are using undo-fu
;; (setq evil-undo-system 'undo-fu)
;; Vim emulation
(use-package evil
  :init
  ;; It has to be defined before evil
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)

  ;; Make :s in visual mode operate only on the actual visual selection
  ;; (character or block), instead of the full lines covered by the selection
  (setq evil-ex-visual-char-range t)
  ;; Use Vim-style regular expressions in search and substitute commands,
  ;; allowing features like \v (very magic), \zs, and \ze for precise matches
  (setq evil-ex-search-vim-style-regexp t)
  ;; Enable automatic horizontal split below
  (setq evil-split-window-below t)
  ;; Enable automatic vertical split to the right
  (setq evil-vsplit-window-right t)
  ;; Disable echoing Evil state to avoid replacing eldoc
  (setq evil-echo-state nil)
  ;; Do not move cursor back when exiting insert state
  (setq evil-move-cursor-back nil)
  ;; Make `v$` exclude the final newline
  (setq evil-v$-excludes-newline t)
  ;; Enable fine-grained undo behavior
  (setq evil-want-fine-undo t)
  ;; Disable wrapping of search around buffer
  (setq evil-search-wrap nil)
  ;; Allow C-h to delete in insert state
  (setq evil-want-C-h-delete t)
  ;; Enable C-u to delete back to indentation in insert state
  (setq evil-want-C-u-delete t)
  ;; Whether Y yanks to the end of the line
  (setq evil-want-Y-yank-to-eol t)

  ;; Make `j'/`k' move by screen lines in buffers where
  ;; `visual-line-mode' is active.  Without this, a soft-wrapped
  ;; paragraph is one logical line, so `j'/`k' jump over the whole
  ;; paragraph instead of moving one visual line.  This must be set
  ;; before Evil is loaded, because Evil installs the visual-line
  ;; key bindings at load time.
  (setq evil-respect-visual-line-mode t)

  ;; Start `evil-mode'
  (evil-mode 1)

  :config
  ;; Occasionally, `evil' fails to respect `evil-search-module' when it is
  ;; defined inside the :custom block. This fix ensures the search module
  ;; is correctly set to `evil-search'.
  (setq evil-search-module 'evil-search)
  (evil-select-search-module 'evil-search-module 'evil-search))

(use-package evil-collection
  :after evil
  :init
  ;; It has to be defined before evil-collection
  (setq evil-collection-setup-minibuffer t)
  (evil-collection-init))

;; The goto-chg package is useful with Evil to jump directly to the most recent
;; edit location. This mirrors Vim's change navigation, allowing fast return to
;; where text was last modified without relying on the jump list or search.
;;
;; The goto-chg commands are bound to g; and g,
(use-package goto-chg
  :commands (goto-last-change
             goto-last-change-reverse))

;; The evil-surround package simplifies handling surrounding characters, such as
;; parentheses, brackets, quotes, etc. It provides key bindings to easily add,
;; change, or delete these surrounding characters in pairs. For instance, you
;; can surround the currently selected text with double quotes in visual state
;; using S" or gS".
(use-package evil-surround
  :after evil
  :init
  (setq evil-surround-pairs-alist
        '((?\( . ("(" . ")"))
          (?\[ . ("[" . "]"))
          (?\{ . ("{" . "}"))

          (?\) . ("(" . ")"))
          (?\] . ("[" . "]"))
          (?\} . ("{" . "}"))

          (?< . ("<" . ">"))
          (?> . ("<" . ">"))))
  :config
  (global-evil-surround-mode 1))

;; The following code enables commenting and uncommenting by pressing gcc in
;; normal mode and gc in visual mode.
(with-eval-after-load "evil"
  (evil-define-operator my-evil-comment-or-uncomment (beg end)
    "Toggle comment for the region between BEG and END."
    (interactive "<r>")
    (comment-or-uncomment-region beg end))
  (evil-define-key 'normal 'global (kbd "gc") 'my-evil-comment-or-uncomment))

(provide 'init-evil)

