;;; init-python.el --- Python development with uv and Eglot -*- lexical-binding: t; -*-

;;; Commentary:
;; Python support for projects managed by uv.
;;
;; The language server is basedpyright (or pyright).  It is looked up in this
;; order:
;;
;;   1. the project's uv virtualenv (`.venv/bin');
;;   2. an executable on `exec-path';
;;   3. a temporary environment managed by `uvx'.
;;
;; The third option means no manual installation is required: the first time a
;; Python file is opened, Eglot asks uv to download and run basedpyright.  To
;; pin a project to a specific server version, add basedpyright as a development
;; dependency with `uv add --dev basedpyright'; the first lookup step will then
;; pick it up from the project's own virtualenv.
;;
;; This file also configures the built-in `python' package: the uv virtualenv
;; is discovered from the project root and used for `run-python' and the Python
;; shell.  Ruff is not part of the language server setup; basedpyright provides
;; completion, navigation, type checking and diagnostics, but not formatting.

;;; Code:

(require 'cl-lib)
(require 'init-eglot)
(require 'init-treesit)
(require 'project)
(require 'seq)
(require 'subr-x)

;;; Project and virtualenv discovery

(defcustom my/python-project-markers '("pyproject.toml" "uv.lock")
  "Files that identify the root of a Python project.
The nearest directory containing one of these files is used as the
Python project root.  These markers are also added to
`project-vc-extra-root-markers', so Eglot and project commands use
the same root, including inside a larger repository."
  :type '(repeat string)
  :group 'python)

(dolist (marker my/python-project-markers)
  (add-to-list 'project-vc-extra-root-markers marker))

;; Keep uv-created virtualenvs and caches out of project file listings and
;; project-wide searches.  Git ignores often cover these, but this also works
;; for non-VC projects and transient projects.
(dolist (ignore '(".venv/" "__pycache__/" ".mypy_cache/"
                  ".ruff_cache/" ".pytest_cache/"))
  (add-to-list 'project-vc-ignores ignore))

(defcustom my/python-venv-directory ".venv"
  "Name of the virtualenv directory created by uv."
  :type 'string
  :group 'python)

(defun my/python--project-marker-p (dir)
  "Return non-nil when DIR contains a Python project marker."
  (seq-some (lambda (marker)
              (file-exists-p (expand-file-name marker dir)))
            my/python-project-markers))

(defun my/python--project-root (&optional dir)
  "Return the nearest Python project root above DIR.
DIR defaults to `default-directory'.  Return nil when no project
marker is found."
  (when-let* ((root (locate-dominating-file
                     (file-name-as-directory
                      (expand-file-name (or dir default-directory)))
                     #'my/python--project-marker-p)))
    (file-name-as-directory (expand-file-name root))))

(defun my/python--venv-bin (venv)
  "Return the executable directory inside VENV."
  (expand-file-name (if (eq system-type 'windows-nt) "Scripts" "bin") venv))

(defun my/python-venv-root (&optional dir)
  "Return the uv virtualenv root for DIR, or nil if there is none.
DIR defaults to `default-directory'.  `UV_PROJECT_ENVIRONMENT'
takes precedence over the default `.venv' directory, matching uv
behavior.  Relative values are resolved against the project
root."
  (let* ((start (file-name-as-directory
                 (expand-file-name (or dir default-directory))))
         (project (my/python--project-root start))
         (configured (getenv "UV_PROJECT_ENVIRONMENT")))
    (cond
     ((and configured (not (string-empty-p configured)))
      (let ((path (expand-file-name configured (or project start))))
        (when (file-directory-p path) path)))
     (project
      (let ((path (expand-file-name my/python-venv-directory project)))
        (when (file-directory-p path) path))))))

(defun my/python-setup ()
  "Configure the current Python buffer from its uv project.
Set the buffer-local Python shell to the project virtualenv, so
`run-python' and Python shell commands use the same packages as the
language server.  Do nothing when the project has no virtualenv."
  (when-let* ((venv (my/python-venv-root))
              (python (expand-file-name
                       (if (eq system-type 'windows-nt) "python.exe" "python")
                       (my/python--venv-bin venv)))
              ((file-executable-p python)))
    (setq-local python-shell-virtualenv-root venv)
    (setq-local python-shell-interpreter python)))

;;; Eglot language server

(defun my/python-eglot-contact (&optional _interactive project)
  "Choose the Python language server for PROJECT.
Prefer basedpyright, then pyright.  Search the uv virtualenv of
the project first, then the variable `exec-path', and finally let
`uvx' provide the server."
  (let* ((root (or (and project (ignore-errors (project-root project)))
                   (my/python--project-root)))
         (venv (and root (my/python-venv-root root)))
         (bin (and venv (my/python--venv-bin venv))))
    (or
     (cl-loop
      for program in '("basedpyright-langserver" "pyright-langserver")
      for path = (and bin (expand-file-name program bin))
      when (and path (file-executable-p path))
      return (cons path '("--stdio")))
     (funcall
      (my/eglot-contact-fallback
       '(("basedpyright-langserver" "--stdio")
         (:uvx "basedpyright" "basedpyright-langserver" "--stdio")
         ("pyright-langserver" "--stdio")
         (:uvx "pyright" "pyright-langserver" "--stdio")))))))

(my/eglot-register '(python-mode python-ts-mode)
  :server #'my/python-eglot-contact)

;;; Tree-sitter

;; Use `python-ts-mode' for .py files.  On Emacs 31 the Python grammar is
;; downloaded and built automatically the first time the mode is used, so no
;; manual `treesit-install-language-grammar' call is needed.
(my/treesit-enable 'python-mode 'python-ts-mode 'python)

;;; Python mode and shells

(use-package python
  :ensure nil
  :init
  ;; PEP 8 and Ruff/Black use four spaces.
  (setq python-indent-offset 4)
  ;; Keep one Python shell per project instead of sharing a single shell
  ;; between projects with different virtualenvs.
  (setq python-shell-dedicated 'project)
  :hook
  ((python-mode . my/python-setup)
   (python-ts-mode . my/python-setup)))

;;; uv commands

(defun my/python--uv-root ()
  "Return the directory in which uv commands should run."
  (or (my/python--project-root) default-directory))

(defun my/python--run-uv (args)
  "Run uv with ARGS in the current Python project.
The process runs asynchronously and its output is shown in the
`*uv*' buffer."
  (let ((uv (executable-find "uv"))
        (default-directory (my/python--uv-root)))
    (unless uv
      (user-error "The `uv' executable was not found in `exec-path'"))
    (async-shell-command
     (mapconcat #'shell-quote-argument (cons uv args) " ")
     "*uv*")))

(defun my/python-uv-sync ()
  "Run `uv sync' for the current project.
This creates or updates the project virtualenv and installs its
dependencies."
  (interactive)
  (my/python--run-uv '("sync")))

(defun my/python-uv-lock ()
  "Run `uv lock' for the current project."
  (interactive)
  (my/python--run-uv '("lock")))

(defun my/python-uv-venv ()
  "Run `uv venv' for the current project."
  (interactive)
  (my/python--run-uv '("venv")))

(defun my/python-uv-add (packages)
  "Add PACKAGES to the current uv project."
  (interactive "sPackage(s) to add: ")
  (my/python--run-uv
   (append '("add") (split-string-and-unquote packages))))

(defun my/python-uv-run (command)
  "Run COMMAND through `uv run' in the current project.
COMMAND is parsed like a shell command line, for example
\"pytest -q\" or \"python script.py\"."
  (interactive "sCommand to run with uv: ")
  (my/python--run-uv
   (append '("run") (split-string-and-unquote command))))

(defvar my/python-uv-prefix-map
  (let ((map (make-sparse-keymap)))
    (keymap-set map "s" #'my/python-uv-sync)
    (keymap-set map "l" #'my/python-uv-lock)
    (keymap-set map "v" #'my/python-uv-venv)
    (keymap-set map "a" #'my/python-uv-add)
    (keymap-set map "r" #'my/python-uv-run)
    (keymap-set map "p" #'run-python)
    map)
  "Prefix map for uv and Python commands, bound to `C-c v'.")

(keymap-global-set "C-c v" my/python-uv-prefix-map)

(provide 'init-python)

;;; init-python.el ends here.
