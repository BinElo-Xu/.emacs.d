;;; init-ui.el --- Built-in UI and window conveniences -*- lexical-binding: t; -*-

;;; Commentary:
;; Small, dependency-free UI improvements that work well with Evil:
;;
;; - `which-key' makes the C-c/C-x and Evil prefix maps discoverable;
;; - `repeat-mode' repeats common Emacs commands with single keys;
;; - `winner-mode' restores previous window layouts;
;; - pixel scrolling is enabled on graphical frames.

;;; Code:

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

(when (display-graphic-p)
  (pixel-scroll-precision-mode 1))

(provide 'init-ui)

;;; init-ui.el ends here.
