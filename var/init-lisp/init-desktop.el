;;; init-desktop.el --- Restore the previous Emacs session -*- lexical-binding: t; -*-

;;; Commentary:
;; Save the buffers, cursor positions, and window/frame layout when Emacs
;; exits, and restore them the next time it starts.
;;
;; The desktop file lives under `user-emacs-directory' (here
;; `~/.emacs.d/var/desktop/emacs.desktop'), so it is kept with the other
;; runtime state and ignored by Git.
;;
;; Only file-visiting buffers are saved.  Short-lived buffers such as
;; `*Messages*', `*scratch*', VTerm, and agent-shell sessions are skipped by
;; the built-in `desktop' package.  In daemon sessions the buffer state is
;; restored without trying to recreate graphical frames.

;;; Code:

(use-package desktop
  :ensure nil
  :init
  (setq desktop-dirname (expand-file-name "desktop/" user-emacs-directory))
  ;; `desktop-read' searches `desktop-path' rather than using the value of
  ;; `desktop-dirname' directly, so point both at the same directory.
  (setq desktop-path (list desktop-dirname))
  (setq desktop-base-file-name "emacs.desktop"
        desktop-base-lock-name "emacs.desktop.lock"
        ;; Always save on exit without prompting.
        desktop-save t
        ;; If a previous Emacs crashed, do not refuse to restore just because
        ;; a stale lock file is present.  `check-pid' still protects against a
        ;; session that is actually running on this machine.
        desktop-load-locked-desktop 'check-pid
        ;; Restore the first few buffers immediately so the window layout is
        ;; usable right away, then restore the rest when Emacs is idle.  This
        ;; keeps startup responsive for large sessions.
        desktop-restore-eager 5
        ;; Save and restore the frame and window configuration.  A daemon has
        ;; no display to restore frames on, so keep the buffer state only.
        desktop-restore-frames (not (daemonp))
        desktop-restore-in-current-display t
        desktop-auto-save-timeout 30)
  (unless (file-directory-p desktop-dirname)
    (make-directory desktop-dirname t))
  :config
  (unless noninteractive
    (desktop-save-mode 1)))

(provide 'init-desktop)

;;; init-desktop.el ends here
