;;; init-multicursor.el --- Multiple cursors with evil-mc -*- lexical-binding: t; -*-

;;; Commentary:
;; `evil-mc' provides Vim-style multiple cursors for Evil.
;;
;; The keymap is provided by evil-collection's evil-mc integration, which
;; clears the package's default direct bindings and installs a single `g.'
;; prefix in normal and visual state.  This avoids conflicts with Evil's
;; C-n/C-p paste history, C-t pop-tag-mark, and Eglot's `gr' prefix.
;;
;;   g. n/N      add a cursor at the next/previous match
;;   g. a        add cursors at all matches
;;   g. C-m      add a cursor at point
;;   g. o/O      add a cursor on the next/previous line
;;   g. I/A      add cursors at the beginning/end of the visual selection
;;   g. C-n/C-S-n  skip to the next/previous match without adding a cursor
;;   g. M-n/M-N  move to the next/previous existing cursor
;;   g. C-u/C-S-u  skip to the next/previous existing cursor
;;   g. u/q      undo the last/all cursors
;;   g. C-p/C-r  pause/resume cursors
;;   g. 0/$      go to the first/last cursor
;;
;; `g. n' and `g. N' accept a numeric prefix, so `3 g. n' adds cursors for
;; the current match and the next two matches instead of asking you to press
;; the key three times.  `g. o' and `g. O' also accept a count.
;;
;; After `g. n' or `g. N', a transient `;' key repeats the same operation for
;; the next match, and `,' repeats it in the opposite direction.  Any other
;; key leaves the repeat state.  This is similar to repeating `f'/`F'/`t'/`T'
;; with `;'/`,`.
;;
;; `evil-mc' is enabled in programming, configuration, and text buffers
;; (including Org), where multiple cursors are useful.  It is not enabled in
;; terminal, REPL, or other special buffers.

;;; Code:

(require 'evil)

(declare-function evil-mc-make-and-goto-next-match "evil-mc" ())
(declare-function evil-mc-make-and-goto-prev-match "evil-mc" ())
(defvar evil-mc-cursors-map)

(defvar my/evil-mc--repeat-direction 'forward
  "Direction used by `my/evil-mc-repeat'.")

(defvar my/evil-mc-repeat-map
  (let ((map (make-sparse-keymap)))
    (keymap-set map ";" #'my/evil-mc-repeat)
    (keymap-set map "," #'my/evil-mc-repeat-opposite)
    map)
  "Transient map for repeating multi-cursor match selection.
It is installed after `g. n'/`g. N' and stays active until a key that
is not in the map is pressed.")

(defun my/evil-mc-repeat (count)
  "Repeat the last multi-cursor match selection in the same direction.
With a numeric prefix, add cursors at COUNT matches."
  (interactive "p")
  (if (eq my/evil-mc--repeat-direction 'forward)
      (my/evil-mc-make-and-goto-next-match count)
    (my/evil-mc-make-and-goto-prev-match count)))

(defun my/evil-mc-repeat-opposite (count)
  "Repeat the last multi-cursor match selection in the opposite direction.
With a numeric prefix, add cursors at COUNT matches."
  (interactive "p")
  (if (eq my/evil-mc--repeat-direction 'forward)
      (my/evil-mc-make-and-goto-prev-match count)
    (my/evil-mc-make-and-goto-next-match count)))

(defun my/evil-mc-make-and-goto-next-match (count)
  "Add cursors at COUNT consecutive matches, starting at point.
With no prefix argument, behave like `evil-mc-make-and-goto-next-match'.
After the cursors are added, `;' repeats the same operation for the next
match, and `,' repeats it in the opposite direction until another key is
pressed."
  (interactive "p")
  (dotimes (_ (max 1 count))
    (evil-mc-make-and-goto-next-match))
  (setq my/evil-mc--repeat-direction 'forward)
  (set-transient-map my/evil-mc-repeat-map))

(defun my/evil-mc-make-and-goto-prev-match (count)
  "Add cursors at COUNT consecutive matches going backwards from point.
With no prefix argument, behave like `evil-mc-make-and-goto-prev-match'.
After the cursors are added, `;' repeats the same operation for the previous
match, and `,' repeats it in the opposite direction until another key is
pressed."
  (interactive "p")
  (dotimes (_ (max 1 count))
    (evil-mc-make-and-goto-prev-match))
  (setq my/evil-mc--repeat-direction 'backward)
  (set-transient-map my/evil-mc-repeat-map))

(use-package evil-mc
  :ensure t
  :hook
  ((prog-mode . evil-mc-mode)
   (conf-mode . evil-mc-mode)
   (text-mode . evil-mc-mode))
  :config
  ;; evil-collection sets up `g. n'/`g. N' when evil-mc is loaded.  Replace
  ;; those two commands with count-aware versions; repeat the other bindings
  ;; unchanged by only touching n and N.
  (keymap-set evil-mc-cursors-map "n" #'my/evil-mc-make-and-goto-next-match)
  (keymap-set evil-mc-cursors-map "N" #'my/evil-mc-make-and-goto-prev-match))

(provide 'init-multicursor)

;;; init-multicursor.el ends here
