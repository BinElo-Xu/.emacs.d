;;; init-clipboard.el --- Clipboard integration and org-download -*- lexical-binding: t; -*-

;; emacs clipborad integration
(setq select-enable-clipboard t)

;; Wayland clipboard integration.

(use-package emacs
  :ensure nil
  :custom
  (select-enable-clipboard t)
  (select-enable-primary nil)
  (save-interprogram-paste-before-kill t))

;;; org-download

;; `org-download-image-dir' is intentionally left unset here.  Each notes
;; directory sets it buffer-locally through its own `.dir-locals.el', e.g.
;; `permanent/.dir-locals.el' sets it to "./permanent-img".  Leaving the
;; global value nil lets org-download use those buffer-local values, so images
;; always stay next to the notes they belong to.
;;
;; Keep the annotation and attributes consistent with the images already in
;; the notes: no "#+DOWNLOADED" line, and an Org/HTML width attribute above
;; each link.
(defun my/org-download-annotate-none (_link)
  "Return an empty annotation for the downloaded image at LINK."
  "")

;; `org-download-clipboard' uses `wl-paste' on Wayland; on X11 it uses
;; `xclip'.  Both are only needed for images copied from other applications.
(use-package org-download
  :ensure t
  :commands (org-download-clipboard
             org-download-screenshot
             org-download-image)
  ;; Loading org-download registers its drag-and-drop handlers.  Do that when
  ;; an Org buffer is opened instead of during startup.
  :hook (org-mode . org-download-enable)
  :bind (:map org-mode-map
              ("C-c g" . org-download-clipboard))
  :init
  (setq org-download-annotate-function #'my/org-download-annotate-none)
  :custom
  (org-download-method 'directory)
  ;; The notes' `.dir-locals.el' already selects "<subdir>-img"; do not add a
  ;; heading-named subdirectory below it.
  (org-download-heading-lvl nil)
  ;; Match the existing file naming, e.g. 20260426-221347_screenshot.png.
  (org-download-timestamp "%Y%m%d-%H%M%S_")
  (org-download-display-inline-images t)
  (org-download-image-attr-list
   '("#+ATTR_ORG: :width 400"
     "#+ATTR_HTML: :width 80% :align center")))

;;; Directory-local `eval' forms in the notes

;; minimal-emacs.d sets `enable-local-eval' to nil to protect against malicious
;; local variables.  The notes use `eval' in `.dir-locals.el' to compute the
;; image directory from the name of the current notes subdirectory:
;;
;;   (eval . (setq-local org-download-image-dir
;;                       (concat "./"
;;                               (file-name-nondirectory
;;                                (directory-file-name default-directory))
;;                               "-img")))
;;
;; Such a value cannot be expressed as a plain directory-local variable, so
;; enable `eval' only while directory-local variables under the notes root are
;; being processed.  Everywhere else the minimal-emacs.d default is preserved.
(defcustom my/notes-directory (expand-file-name "~/Notes/")
  "Root directory of the notes whose `.dir-locals.el' may use `eval'."
  :type 'directory
  :group 'org)

(defun my/notes--allow-dir-local-eval (orig variables dir-name)
  "Allow `eval' in directory-local VARIABLES below `my/notes-directory'.
ORIG is the original `hack-local-variables-filter' and DIR-NAME is the
directory that provides the directory-local variables."
  (if (and dir-name
           (file-in-directory-p dir-name my/notes-directory))
      (let ((enable-local-eval t))
        (funcall orig variables dir-name))
    (funcall orig variables dir-name)))

(advice-add 'hack-local-variables-filter :around
            #'my/notes--allow-dir-local-eval)

(provide 'init-clipboard)

;;; init-clipboard.el ends here
