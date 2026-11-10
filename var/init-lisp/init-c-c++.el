;;; init-c-c++.el --- C/C++ editing with Tree-sitter and clangd -*- lexical-binding: t; -*-

;;; Commentary:
;; C and C++ support built on Tree-sitter and Eglot.
;;
;; Source and header files use `c-ts-mode', `c++-ts-mode', or
;; `c-or-c++-ts-mode'.  Missing grammars are installed by init-treesit.
;;
;; Eglot starts clangd automatically.  clangd reads `compile_commands.json',
;; `.clangd', and `compile_flags.txt' from the project, so include paths and
;; compiler flags do not need to be duplicated in Emacs.
;;
;; Makefiles, CMake files, clang configuration files, and
;; `compile_commands.json' get appropriate major modes.  Build artifacts are
;; excluded from project searches.
;;
;; Debugging is intentionally not configured here; use gdb directly.

;;; Code:

(require 'init-eglot)
(require 'init-treesit)
(require 'project)
(require 'seq)

;;; Project roots and ignores

(defcustom my/c-c++-project-markers
  '(".clangd"
    "CMakeLists.txt"
    "meson.build"
    "configure.ac"
    "configure.in"
    "Makefile.am")
  "Files that identify the root of a C/C++ project.
The nearest directory containing one of these files is used as the
project root.  These markers are also added to
`project-vc-extra-root-markers', so project commands and Eglot use
the same root, including inside a larger repository.  Plain
`Makefile' projects are handled by `my/c-c++-project-find' instead,
so a subdirectory Makefile does not split a repository."
  :type '(repeat string)
  :group 'c)

(defcustom my/c-c++-makefile-markers '("Makefile" "GNUmakefile")
  "Makefile names used as a fallback C/C++ project marker.
The topmost matching ancestor is used, and only when the directory
does not already belong to a VC project."
  :type '(repeat string)
  :group 'c)

(dolist (marker my/c-c++-project-markers)
  (add-to-list 'project-vc-extra-root-markers marker))

(defun my/c-c++--has-marker-p (directory markers)
  "Return non-nil when DIRECTORY contains one of MARKERS."
  (seq-some (lambda (marker)
              (file-exists-p (expand-file-name marker directory)))
            markers))

(defun my/c-c++--topmost-makefile-root (directory)
  "Return the topmost ancestor of DIRECTORY containing a Makefile."
  (let ((directory (file-name-as-directory
                    (expand-file-name directory)))
        (found nil))
    (while (not (equal directory
                       (file-name-directory
                        (directory-file-name directory))))
      (when (my/c-c++--has-marker-p directory my/c-c++-makefile-markers)
        (setq found directory))
      (setq directory
            (file-name-directory (directory-file-name directory))))
    (when (my/c-c++--has-marker-p directory my/c-c++-makefile-markers)
      (setq found directory))
    found))

(defun my/c-c++-project-find (directory)
  "Find a Makefile-only C/C++ project for DIRECTORY.
This is a fallback for projects without a VC root or one of the
high-confidence markers in `my/c-c++-project-markers'.  The topmost
ancestor containing a Makefile is used, avoiding a project split for
every subdirectory Makefile."
  (when (and (derived-mode-p 'c-mode 'c++-mode
                             'c-ts-mode 'c++-ts-mode
                             'c-or-c++-mode 'c-or-c++-ts-mode
                             'makefile-mode 'cmake-ts-mode)
             (not (project-try-vc directory)))
    (when-let* ((root (my/c-c++--topmost-makefile-root directory)))
      (cons 'transient root))))

(add-hook 'project-find-functions #'my/c-c++-project-find)

;; Keep build output out of project file listings and project-wide searches.
(dolist (ignore '("build/" "out/" "cmake-build-*/" "CMakeFiles/" ".cache/"))
  (add-to-list 'project-vc-ignores ignore))

;;; Editing style

;; Prefer the Linux indentation style with four-space indentation.  The
;; variable is set before the Tree-sitter modes are loaded.
(setq c-ts-mode-indent-style 'linux
      c-ts-mode-indent-offset 4
      c-basic-offset 4)

(defun my/c-c++-indent-setup ()
  "Use Linux indentation style with four spaces instead of tabs."
  (setq-local indent-tabs-mode nil)
  (setq-local tab-width 4)
  (setq-local c-basic-offset 4))

(dolist (hook '(c-mode-hook c++-mode-hook c-ts-mode-hook c++-ts-mode-hook))
  (add-hook hook #'my/c-c++-indent-setup))

;;; Tree-sitter modes

;; Emacs 31 installs the C and C++ grammars on demand.  The
;; `c-or-c++-ts-mode' entry is used for headers whose language is decided from
;; their contents.  Upstream marks that function obsolete, but Emacs 31 still
;; ships it as the content-based header dispatcher; keep it until there is a
;; replacement.
(my/treesit-enable 'c-mode 'c-ts-mode 'c)
(my/treesit-enable 'c++-mode 'c++-ts-mode 'cpp)
(my/treesit-enable 'c-or-c++-mode 'c-or-c++-ts-mode 'c)

;;; Eglot and clangd

(defcustom my/c-c++-clangd-args '("--background-index" "--clang-tidy")
  "Extra command-line arguments for clangd.
Set this to nil if the project does not need background indexing or
clang-tidy diagnostics."
  :type '(repeat string)
  :group 'c)

(defun my/c-c++-eglot-contact (&optional _interactive _project)
  "Return the clangd command used by Eglot.
Signal a user error when clangd is not available in `exec-path'."
  (if-let* ((clangd (executable-find "clangd")))
      (cons clangd my/c-c++-clangd-args)
    (user-error "clangd was not found in `exec-path'")))

(my/eglot-register '(c-mode c-ts-mode
                     c++-mode c++-ts-mode
                     c-or-c++-mode c-or-c++-ts-mode)
  :server #'my/c-c++-eglot-contact)

;;; File associations

;; C++ extensions that are not covered by the built-in table.  The same
;; `c++-mode' entries are remapped to `c++-ts-mode' above.
(dolist (regexp '("\\.C\\'" "\\.H\\'"
                  "\\.ipp\\'" "\\.tpp\\'" "\\.inl\\'"
                  "\\.ixx\\'" "\\.cppm\\'" "\\.ccm\\'" "\\.cxxm\\'"))
  (add-to-list 'auto-mode-alist (cons regexp #'c++-mode)))

;; GNU make files.  The built-in table already covers Makefile, GNUmakefile,
;; *.mk, and *.make.
(add-to-list 'auto-mode-alist '("\\.mak\\'" . makefile-gmake-mode))
(add-to-list 'auto-mode-alist
             '("/Kbuild\\(?:\\.include\\)?\\'" . makefile-gmake-mode))
(add-to-list 'auto-mode-alist
             '("/\\(?:Makefile\\|makefile\\)\\.in\\'" . makefile-mode))

;; Use `cmake-ts-mode' directly instead of `cmake-ts-mode-maybe', which falls
;; back to `fundamental-mode' when the grammar is not installed.  Calling the
;; mode lets `treesit-ensure-installed' install the CMake grammar on demand.
(when (fboundp 'cmake-ts-mode)
  (add-to-list 'auto-mode-alist
               '("\\(?:CMakeLists\\.txt\\|\\.cmake\\)\\'" . cmake-ts-mode)))

(defun my/c-c++-spaces-setup ()
  "Indent configuration and build files with spaces."
  (setq-local indent-tabs-mode nil))

;; Meson build files have no built-in major mode in Emacs 31.
(use-package meson-mode
  :ensure t
  :mode (("meson\\.build\\'" . meson-mode)
         ("meson_options\\.txt\\'" . meson-mode))
  :hook (meson-mode . my/c-c++-spaces-setup))

;; Clang configuration files are YAML.  Generated compilation databases and
;; CMake presets are JSON.
(when (fboundp 'yaml-ts-mode)
  (dolist (regexp '("\\.clangd\\'" "\\.clang-format\\'" "\\.clang-tidy\\'"))
    (add-to-list 'auto-mode-alist (cons regexp #'yaml-ts-mode))))

(when (fboundp 'json-ts-mode)
  (dolist (regexp '("/compile_commands\\.json\\'"
                    "/CMake\\(?:User\\)?Presets\\.json\\'"))
    (add-to-list 'auto-mode-alist (cons regexp #'json-ts-mode))))

;;; Mode-specific editing settings

(defun my/c-c++-makefile-setup ()
  "Use tabs for Makefile recipes and leave continuations untouched."
  (setq-local indent-tabs-mode t)
  (setq-local tab-width 8)
  (setq-local makefile-cleanup-continuations nil))

(add-hook 'makefile-mode-hook #'my/c-c++-makefile-setup)

(dolist (hook '(cmake-ts-mode-hook yaml-ts-mode-hook json-ts-mode-hook))
  (add-hook hook #'my/c-c++-spaces-setup))

(provide 'init-c-c++)

;;; init-c-c++.el ends here.
