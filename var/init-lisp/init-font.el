;;; init-font.el --- Default font and CJK fontset -*- lexical-binding: t; -*-

;;; Commentary:
;; Use the LXGW WenKai Mono (霞鹜文楷等宽) family for both Latin and CJK
;; text.  The GB Screen variant uses mainland Chinese glyph shapes and is
;; tuned for screen reading.
;;
;; This family is monospaced with a 1:2 metric: a Latin character advances
;; 0.5em and a Han character advances 1em.  Two English letters therefore
;; occupy exactly the same width as one Chinese character, so mixed
;; Chinese/English text, tables, and aligned comments stay aligned without
;; any per-font rescaling.
;;
;; The height is 13pt instead of Emacs' default 10pt.  LXGW's x-height is
;; smaller than JetBrains Maple Mono at the same point size, so a slightly
;; larger height keeps mixed text readable.  Adjust `my/font-height' if the
;; result feels too large or too small.

;;; Code:

(defcustom my/font-family "LXGW WenKai Mono GB Screen"
  "Font family used for both Latin and CJK text."
  :type 'string
  :group 'faces)

(defcustom my/font-height 130
  "Default face height in 1/10 pt (130 = 13pt)."
  :type 'integer
  :group 'faces)

(defun my/font-apply (&optional frame)
  "Apply the configured font to FRAME, or to all frames when FRAME is nil."
  (when (display-graphic-p frame)
    (set-face-attribute 'default nil
                        :family my/font-family
                        :height my/font-height)
    ;; Org source blocks, code snippets, and other fixed-pitch text should not
    ;; fall back to the system monospace font.
    (set-face-attribute 'fixed-pitch nil :family my/font-family)
    ;; The default fontset may keep a different family for Han characters
    ;; and CJK punctuation; point both at LXGW so mixed text is consistent.
    (dolist (script '(han cjk-misc))
      (set-fontset-font t script (font-spec :family my/font-family)))))

(my/font-apply)
(add-hook 'after-make-frame-functions #'my/font-apply)

(provide 'init-font)

;;; init-font.el ends here
