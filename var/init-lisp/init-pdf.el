;;; init-pdf.el --- PDF reading with pdf-tools -*- lexical-binding: t; -*-

;;; Commentary:
;; PDF viewing is handled by pdf-tools, which is loaded on the first PDF visit;
;; doc-view is not used for PDFs.
;;
;; Pages are laid out to fit the window width, so splitting the frame does not
;; shrink a page to fit the window height.  Line and page movement are separate:
;; `j'/`k' scroll one line, `C-j'/`C-k' move one page.  `C-=', `C-+', `C--' and
;; `C-0' zoom the page instead of the buffer text, and `W'/`H' are unbound so
;; they fall back to Evil's own commands.  Everything else (search, occur,
;; outline, links, history, ...) keeps evil-collection's existing PDF bindings.

;;; Code:

(defvar pdf-view-mode-map)
(defvar pdf-view-display-size)

(declare-function pdf-view-themed-minor-mode "pdf-view" (&optional arg))
(declare-function pdf-view-refresh-themed-buffer "pdf-view"
                  (&optional get-theme))
(declare-function pdf-view-enlarge "pdf-view" (factor))
(declare-function pdf-view-shrink "pdf-view" (factor))
(declare-function pdf-view-next-page-command "pdf-view" (&optional n))
(declare-function pdf-view-previous-page-command "pdf-view" (&optional n))
(declare-function pdf-view-next-line-or-next-page "pdf-view" (&optional arg))
(declare-function pdf-view-previous-line-or-previous-page "pdf-view"
                  (&optional arg))
(declare-function pdf-view-fit-width-to-window "pdf-view" ())
(declare-function evil-define-key* "evil" (state keymap key def &rest bindings))

;;; Theme

(defun my/pdf-view-theme-colors-available-p ()
  "Return non-nil when the default face has concrete theme colors.
Batch and TTY frames may report `unspecified-fg'/`unspecified-bg', which
`pdf-view-themed-minor-mode' cannot use."
  (and (color-defined-p (face-foreground 'default nil))
       (color-defined-p (face-background 'default nil))))

(defun my/pdf-view-theme-setup ()
  "Make PDF rendering follow the current Emacs theme."
  (when (and (fboundp 'pdf-view-themed-minor-mode)
             (my/pdf-view-theme-colors-available-p))
    (pdf-view-themed-minor-mode 1)))

(defun my/pdf-view-refresh-theme (&rest _)
  "Refresh open PDF buffers after an Emacs theme change."
  (when (featurep 'pdf-view)
    (dolist (buffer (buffer-list))
      (with-current-buffer buffer
        (when (and (derived-mode-p 'pdf-view-mode)
                   (bound-and-true-p pdf-view-themed-minor-mode)
                   (my/pdf-view-theme-colors-available-p))
          (ignore-errors (pdf-view-refresh-themed-buffer t)))))))

(add-hook 'pdf-view-mode-hook #'my/pdf-view-theme-setup)
(add-hook 'enable-theme-functions #'my/pdf-view-refresh-theme)

;;; pdf-tools

(use-package pdf-tools
  :ensure t
  :defer t
  :init
  ;; Add a lightweight auto-mode entry.  pdf-tools itself is loaded on the
  ;; first PDF visit instead of during startup.  The extra arguments keep the
  ;; loader quiet and avoid trying to install system packages.
  (pdf-loader-install t t t)
  ;; `pdf-view-display-size' is buffer-local; set its default before the first
  ;; PDF buffer is created.  Fitting the width keeps pages readable when the
  ;; frame is split vertically; `fit-page' would shrink the whole page to the
  ;; window height.
  (setq-default pdf-view-display-size 'fit-width)
  :config
  (setq pdf-view-use-scaling t
        ;; Reaching the page edge advances to the next/previous page instead
        ;; of requiring a separate page command.
        pdf-view-continuous t)
  ;; `evil-collection-pdf' binds `j'/`k' to line-or-page movement and `W'/`H'
  ;; to fit-width/fit-height.  `j'/`k' keep pdf-view's own line movement, which
  ;; scrolls the page like text and continues to the next/previous page at the
  ;; edge.  Plain `image-next-line' only scrolls the image and stops at the page
  ;; boundary, which makes each page feel like a standalone picture.  Override
  ;; the keys in the Evil normal state map: a buffer-local `local-set-key' does
  ;; not win over the state map.
  (with-eval-after-load 'evil
    (evil-define-key* 'normal pdf-view-mode-map
      (kbd "j") #'pdf-view-next-line-or-next-page
      (kbd "k") #'pdf-view-previous-line-or-previous-page
      (kbd "C-j") #'pdf-view-next-page-command
      (kbd "C-k") #'pdf-view-previous-page-command
      (kbd "C-=") #'pdf-view-enlarge
      (kbd "C-+") #'pdf-view-enlarge
      (kbd "C--") #'pdf-view-shrink
      ;; "Reset" means going back to the default width fit, not pdf-tools'
      ;; fixed 100%, which would shrink the page again.
      (kbd "C-0") #'pdf-view-fit-width-to-window
      (kbd "z0") #'pdf-view-fit-width-to-window
      ;; Unbind the PDF fit shortcuts so Evil's own W/H commands apply.
      (kbd "W") nil
      (kbd "H") nil)))

(provide 'init-pdf)

;;; init-pdf.el ends here
