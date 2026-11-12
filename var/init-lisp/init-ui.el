;;; init-ui.el --- Built-in UI and window conveniences -*- lexical-binding: t; -*-

;;; Commentary:
;; Small UI improvements that work well with Evil:
;;
;; - `which-key' makes the C-c/C-x and Evil prefix maps discoverable;
;; - `repeat-mode' repeats common Emacs commands with single keys;
;; - `winner-mode' restores previous window layouts;
;; - `ace-window' switches windows by label with `M-o';
;; - pixel scrolling is enabled on graphical frames;
;; - `C-=' / `C--' / `C-0' adjust the buffer's text scale.

;;; Code:

(defun my/text-scale-reset ()
  "Reset the current buffer's text scale."
  (interactive)
  (text-scale-set 0))

(global-set-key (kbd "C-=") #'text-scale-increase)
(global-set-key (kbd "C-+") #'text-scale-increase)
(global-set-key (kbd "C--") #'text-scale-decrease)
(global-set-key (kbd "C-0") #'my/text-scale-reset)

(use-package which-key
  :ensure nil
  :if (fboundp 'which-key-mode)
  :custom
  (which-key-idle-delay 0.4)
  :config
  (which-key-setup-side-window-bottom)
  (which-key-mode 1))

(repeat-mode 1)
(winner-mode 1)

;;; Window switching

(use-package ace-window
  :ensure t
  :demand t
  :custom
  ;; Home-row labels are easier to reach than digits, and they match the
  ;; letters shown in the mode line by `ace-window-display-mode'.  Skip `j'
  ;; because `aw-dispatch-alist' already uses it for "select buffer".
  (aw-keys '(?a ?s ?d ?f ?g ?h ?k ?l ?\;))
  (aw-scope 'frame)
  (aw-background t)
  :config
  ;; Show each window's label in its mode line, so the target is visible
  ;; before pressing `M-o'.
  (ace-window-display-mode 1)
  :bind
  ;; With only two windows `M-o' switches immediately; with more, it labels
  ;; the windows and waits for one of the letters above.
  ("M-o" . ace-window))

(when (display-graphic-p)
  (pixel-scroll-precision-mode 1))

(provide 'init-ui)

;;; init-ui.el ends here.
