;;; init-visual-line.el --- Visual line wrapping -*- lexical-binding: t; -*-

;; Make the fill-column indicator and visual-fill-column use the same width.
;; `display-fill-column-indicator-column' defaults to t, which means that the
;; indicator is drawn at the buffer-local value of `fill-column'.  Setting the
;; default explicitly keeps the two settings paired: `visual-fill-column-width'
;; below is nil, so visual-fill-column also wraps at `fill-column'.
(setq-default display-fill-column-indicator-column t)

;; Allow line breaks at word boundaries according to the character categories
;; of the active language.
(setq word-wrap-by-category t)

(use-package visual-fill-column
  :ensure t
  :commands (visual-fill-column-mode
             global-visual-fill-column-mode
             visual-fill-column-for-vline)
  ;; Enable and disable visual-fill-column together with visual-line-mode.
  :hook (visual-line-mode . visual-fill-column-for-vline)
  :custom
  ;; nil means use the buffer-local `fill-column', which is also the column
  ;; used by `global-display-fill-column-indicator-mode'.
  (visual-fill-column-width nil))

;; Enable visual-line-mode in prose buffers.  Org mode derives from
;; `text-mode', so Org notes are covered as well.  Programming buffers keep
;; minimal-emacs.d's `truncate-lines t' default, avoiding wrapped code lines.
(add-hook 'text-mode-hook #'visual-line-mode)

;;; Keep the fill column visible in narrow windows

;; A window narrower than `fill-column' cannot display the indicator at that
;; column.  When the window is split, this makes the indicator disappear in
;; the narrow window while it remains visible in the wide one.  Fit
;; `fill-column' to the width of the windows that display the buffer, so the
;; indicator and the wrap position stay together.  The original value is
;; remembered and restored as soon as the window is wide enough again.

(defvar-local my/visual-line--fill-column-base nil
  "Original value of `fill-column' before fitting it to the window width.")

(defvar-local my/visual-line--fill-column-target nil
  "Last `fill-column' value installed by `my/visual-line--fit-fill-column'.")

(defvar my/visual-line--fitting nil
  "Non-nil while `my/visual-line--fit-fill-column' is running.")

(declare-function visual-fill-column-adjust
                  "visual-fill-column" (&optional inc))

(defun my/visual-line--available-columns (window)
  "Return the usable number of columns in WINDOW.
The margins added by visual-fill-column are ignored, so this is the width
available to the text area if the window is wide enough."
  (let ((margins (window-margins window)))
    (if (and (null (car margins))
             (null (cdr margins)))
        (window-max-chars-per-line window)
      (unwind-protect
          (progn
            (set-window-margins window nil)
            (window-max-chars-per-line window))
        (set-window-margins window (car margins) (cdr margins))))))

(defun my/visual-line--fit-fill-column (&optional frame)
  "Fit `fill-column' to the windows displaying each buffer.
When a buffer is visible in several windows, use the narrowest window so
that the fill-column indicator is visible in all of them."
  (unless my/visual-line--fitting
    (let ((my/visual-line--fitting t)
          (frame (or frame (selected-frame)))
          (seen nil))
      (dolist (window (window-list frame 'no-minibuffer))
        (let ((buffer (window-buffer window)))
          (unless (memq buffer seen)
            (push buffer seen)
            (with-current-buffer buffer
              (when (bound-and-true-p visual-fill-column-mode)
                (let (windows)
                  (dolist (win (window-list frame 'no-minibuffer))
                    (when (eq (window-buffer win) buffer)
                      (push win windows)))
                  (setq windows (nreverse windows))
                  (let ((columns
                         (apply #'min
                                (mapcar #'my/visual-line--available-columns
                                        windows))))
                    (unless my/visual-line--fill-column-base
                      (setq my/visual-line--fill-column-base fill-column))
                    ;; A value different from the one we installed means the
                    ;; user or the major mode changed `fill-column'; adopt it
                    ;; as the new base value.
                    (when (and my/visual-line--fill-column-target
                               (/= fill-column
                                   my/visual-line--fill-column-target)
                               (/= fill-column
                                   my/visual-line--fill-column-base))
                      (setq my/visual-line--fill-column-base fill-column))
                    (let ((target (max 1
                                       (min my/visual-line--fill-column-base
                                            columns))))
                      (unless (= fill-column target)
                        (setq-local fill-column target))
                      (setq-local display-fill-column-indicator-column t)
                      (setq-local my/visual-line--fill-column-target target)
                      (dolist (win windows)
                        (with-selected-window win
                          (visual-fill-column-adjust))))))))))))))

(add-hook 'visual-fill-column-mode-hook #'my/visual-line--fit-fill-column)
(add-hook 'window-configuration-change-hook #'my/visual-line--fit-fill-column)
(add-hook 'window-size-change-functions #'my/visual-line--fit-fill-column)

(provide 'init-visual-line)

;;; init-visual-line.el ends here
