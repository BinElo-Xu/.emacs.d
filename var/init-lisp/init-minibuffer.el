;;; init-minibuffer.el --- Evil-style minibuffer keybindings -*- lexical-binding: t; -*-

;; `evil-collection-setup-minibuffer' (see init-evil.el) puts every new
;; minibuffer into Evil's insert state.  Evil's insert state intentionally
;; re-purposes several standard editing keys for Vim features (`C-a' pastes
;; the last insertion, `C-e' copies from the line below, `C-k' starts a
;; digraph, `C-n'/`C-p' run Evil's own completion, ...).  Those commands make
;; little sense on a one-line command prompt, so this file restores sensible
;; command-line editing and adds Vim-style candidate navigation:
;;
;;   C-j / C-n / <down>  select the next candidate (or history entry)
;;   C-k / C-p / <up>    select the previous candidate (or history entry)
;;   C-h / C-l           move one character left / right
;;   C-a / C-e           move to the beginning / end of the input
;;
;; After pressing <escape> (which switches the minibuffer to Evil normal
;; state) `j' and `k' also select the next and previous candidate, just like
;; the arrow keys.  <return> still accepts the current candidate, and a
;; second <escape> aborts the minibuffer.
;;
;; All bindings are Evil *auxiliary* keymaps attached to the minibuffer
;; keymaps.  They therefore take precedence over Evil's global insert/normal
;; state maps inside the minibuffer, without changing Evil anywhere else.

;;; Code:

(require 'evil)
(require 'vertico)

(defun my/minibuffer-vertico-p ()
  "Return non-nil when Vertico is displaying candidates in this minibuffer."
  (and (boundp 'vertico--input) vertico--input))

(defun my/minibuffer-next (&optional arg)
  "Select the next minibuffer candidate.
Without completion candidates, move to the next history element instead."
  (interactive "p")
  (cond
   ((my/minibuffer-vertico-p)
    ;; `vertico--prepare' only refreshes candidates for commands whose names
    ;; start with "vertico-", and this wrapper does not.  Refresh explicitly
    ;; in the unlikely case that `vertico-map' is not the active local map.
    (when (fboundp 'vertico--update)
      (vertico--update))
    (vertico-next (or arg 1)))
   ((fboundp 'next-line-or-history-element)
    (next-line-or-history-element (or arg 1)))
   (t
    (next-history-element (or arg 1)))))

(defun my/minibuffer-previous (&optional arg)
  "Select the previous minibuffer candidate.
Without completion candidates, move to the previous history element instead."
  (interactive "p")
  (cond
   ((my/minibuffer-vertico-p)
    (when (fboundp 'vertico--update)
      (vertico--update))
    (vertico-previous (or arg 1)))
   ((fboundp 'previous-line-or-history-element)
    (previous-line-or-history-element (or arg 1)))
   (t
    (previous-history-element (or arg 1)))))

(defvar my/minibuffer-maps
  (list minibuffer-local-map
        minibuffer-local-ns-map
        minibuffer-local-completion-map
        minibuffer-local-must-match-map
        minibuffer-local-isearch-map)
  "Plain minibuffer keymaps that receive the Evil-style bindings.

These cover `read-string', `read-from-minibuffer', `y-or-n-p' and friends.
`vertico-map' gets its own bindings, see `my/vertico-maps'.")

(defvar my/vertico-maps (list vertico-map)
  "Vertico's local keymap for `completing-read'.
Candidates are navigated with `vertico-next'/`vertico-previous' directly, so
that Vertico's `pre-command-hook' can refresh the candidate list before the
movement command runs.")

(defun my/minibuffer-bind (maps key insert-def normal-def)
  "Bind KEY to INSERT-DEF and NORMAL-DEF in the keymaps MAPS.
MAPS is a list of keymap objects.  The bindings are installed in Evil
auxiliary keymaps, so they are active only while one of MAPS is the
minibuffer's local map."
  (dolist (map maps)
    (evil-define-key* 'insert map key insert-def)
    (evil-define-key* 'normal map key normal-def)))

;; Candidate / history navigation in plain minibuffers.
(my/minibuffer-bind my/minibuffer-maps (kbd "C-j")
                    #'my/minibuffer-next #'my/minibuffer-next)
(my/minibuffer-bind my/minibuffer-maps (kbd "C-k")
                    #'my/minibuffer-previous #'my/minibuffer-previous)
(my/minibuffer-bind my/minibuffer-maps (kbd "C-n")
                    #'my/minibuffer-next #'my/minibuffer-next)
(my/minibuffer-bind my/minibuffer-maps (kbd "C-p")
                    #'my/minibuffer-previous #'my/minibuffer-previous)

;; Candidate navigation with Vertico.  Binding the commands directly (rather
;; than through `my/minibuffer-next') lets `vertico--prepare' update the
;; candidates in its `pre-command-hook' before the movement happens.
(my/minibuffer-bind my/vertico-maps (kbd "C-j")
                    #'vertico-next #'vertico-next)
(my/minibuffer-bind my/vertico-maps (kbd "C-k")
                    #'vertico-previous #'vertico-previous)
(my/minibuffer-bind my/vertico-maps (kbd "C-n")
                    #'vertico-next #'vertico-next)
(my/minibuffer-bind my/vertico-maps (kbd "C-p")
                    #'vertico-previous #'vertico-previous)

;; Horizontal movement and beginning/end of the input.
(dolist (maps (list my/minibuffer-maps my/vertico-maps))
  (my/minibuffer-bind maps (kbd "C-h")
                      #'backward-char #'evil-backward-char)
  (my/minibuffer-bind maps (kbd "C-l")
                      #'forward-char #'evil-forward-char)
  (my/minibuffer-bind maps (kbd "C-a")
                      #'beginning-of-line #'evil-beginning-of-line)
  (my/minibuffer-bind maps (kbd "C-e")
                      #'end-of-line #'evil-end-of-line))

;; Vim-style j/k navigation once the minibuffer is in normal state.
(dolist (map my/minibuffer-maps)
  (evil-define-key* 'normal map (kbd "j") #'my/minibuffer-next)
  (evil-define-key* 'normal map (kbd "k") #'my/minibuffer-previous))
(dolist (map my/vertico-maps)
  (evil-define-key* 'normal map (kbd "j") #'vertico-next)
  (evil-define-key* 'normal map (kbd "k") #'vertico-previous))

;; The Ex command line (`:') and the search prompt (`/' and `?') use their own
;; local keymaps.  `evil-ex-completion-map' does not inherit from
;; `minibuffer-local-map', so it needs explicit bindings; the search keymap
;; inherits the standard ones but still needs `C-j'/`C-k' and `C-e' because
;; Evil's insert state would otherwise shadow them.  `C-n'/`C-p' already
;; select history entries there; make `C-j'/`C-k' do the same.  Evil's other
;; Ex bindings (`C-a'/`C-l' completion, ...) are left alone.
(dolist (map (list evil-ex-completion-map evil-ex-search-keymap))
  (evil-define-key* 'insert map (kbd "C-h") #'backward-char)
  (evil-define-key* 'normal map (kbd "C-h") #'evil-backward-char)
  (evil-define-key* 'insert map (kbd "C-e") #'end-of-line)
  (evil-define-key* 'normal map (kbd "C-e") #'evil-end-of-line))

;; Restore the bindings that Evil's Ex keymaps define for themselves but
;; which are shadowed by Evil's global insert state.
(evil-define-key* 'insert evil-ex-completion-map (kbd "C-a")
                  #'evil-ex-completion)
(evil-define-key* 'insert evil-ex-completion-map (kbd "C-d")
                  #'evil-ex-completion)
(evil-define-key* 'insert evil-ex-completion-map (kbd "C-u")
                  #'evil-delete-whole-line)
(evil-define-key* 'insert evil-ex-search-keymap (kbd "C-u")
                  #'evil-delete-whole-line)

(evil-define-key* 'insert evil-ex-completion-map (kbd "C-j")
                  #'next-complete-history-element)
(evil-define-key* 'normal evil-ex-completion-map (kbd "C-j")
                  #'next-complete-history-element)
(evil-define-key* 'insert evil-ex-completion-map (kbd "C-k")
                  #'previous-complete-history-element)
(evil-define-key* 'normal evil-ex-completion-map (kbd "C-k")
                  #'previous-complete-history-element)

(evil-define-key* 'insert evil-ex-search-keymap (kbd "C-j")
                  #'next-history-element)
(evil-define-key* 'normal evil-ex-search-keymap (kbd "C-j")
                  #'next-history-element)
(evil-define-key* 'insert evil-ex-search-keymap (kbd "C-k")
                  #'previous-history-element)
(evil-define-key* 'normal evil-ex-search-keymap (kbd "C-k")
                  #'previous-history-element)

;; `evil-ex-completion-map' does not inherit from `minibuffer-local-map', so
;; add j/k history navigation there as well.
(dolist (map (list evil-ex-completion-map evil-ex-search-keymap))
  (evil-define-key* 'normal map (kbd "j") #'my/minibuffer-next)
  (evil-define-key* 'normal map (kbd "k") #'my/minibuffer-previous))

(provide 'init-minibuffer)
;;; init-minibuffer.el ends here
