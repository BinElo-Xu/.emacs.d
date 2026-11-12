;;; -*- lexical-binding: t -*-

;; Org mode is a major mode designed for organizing notes, planning, task
;; management, and authoring documents using plain text with a simple and
;; expressive markup syntax. It supports hierarchical outlines, TODO lists,
;; scheduling, deadlines, time tracking, and exporting to multiple formats
;; including HTML, LaTeX, PDF, and Markdown.
(use-package org
  :commands (org-mode org-version)
  :mode
  ("\\.org\\'" . org-mode)
  :init
  (setq org-hide-leading-stars t)
  (setq org-startup-indented t)
  (setq org-adapt-indentation nil)
  (setq org-src-content-indentation 0)
  (setq org-directory (expand-file-name "~/Notes/"))
  (setq my/notes-directory org-directory)
  ;; (setq org-fontify-done-headline t)
  ;; (setq org-fontify-todo-headline t)
  ;; (setq org-fontify-whole-heading-line t)
  ;; (setq org-fontify-quote-and-verse-blocks t)
  ;; Org derives from `text-mode', where init-visual-line enables
  ;; `visual-line-mode'.  Keep the two settings consistent instead of asking
  ;; Org to truncate lines and then immediately overriding it.
  (setq org-startup-truncated nil)
  :bind
  (("C-c a" . org-agenda)
   ("C-c c" . org-capture)
   ("C-c l" . org-store-link)
   ))

;; Capturing template
(setq org-capture-templates
      (let ((inbox (expand-file-name "agenda/inbox.org" org-directory)))
        `(("t" "todo" entry (file ,inbox)
           "* TODO %?\n%u\n" :clock-resume t)
          ("n" "note" entry (file ,inbox)
           "* %? :NOTE:\n%U\n%a\n" :clock-resume t))))

;; All Org files in the agenda directory are part of the agenda.  Keeping the
;; directory here also picks up files created later by capture or other tools.
(setq org-agenda-files (list (expand-file-name "agenda/" org-directory)))

;; Allow refiling between every agenda file.  The file path is included in the
;; completion candidate so different files with similar headings are clear.
(setq org-refile-targets '((org-agenda-files :maxlevel . 3))
      org-refile-use-outline-path 'file
      org-refile-allow-creating-parent-nodes 'confirm)

;; Keep state-change notes in the conventional :LOGBOOK: drawer instead of
;; writing them directly below the task heading.
(setq org-log-into-drawer t)


;; when cursor is on the link, link content will 
;; appear. Hidding when cursor leave. 
(use-package org-appear
  :commands org-appear-mode
  :hook (org-mode . org-appear-mode))

;; To-do settings
(setq org-todo-keywords
      (quote ((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!/!)")
              (sequence "PROJECT(p)" "|" "DONE(d!/!)" "CANCELLED(c@/!)")
              (sequence "WAITING(w@/!)" "DELEGATED(e!)" "HOLD(h)" "|" "CANCELLED(c@/!)")))
      org-todo-repeat-to-state "NEXT")

(setq org-todo-keyword-faces
      (quote (("NEXT" :inherit warning)
              ("PROJECT" :inherit font-lock-string-face))))

(setq-default org-agenda-clockreport-parameter-plist '(:link t :maxlevel 3))


;; Agenda views

(setq org-stuck-projects
      '("-INBOX/PROJECT" ("NEXT")))

(let ((active-project-match (car org-stuck-projects)))
  (setq org-agenda-compact-blocks t
        org-agenda-sticky nil
        org-agenda-start-on-weekday nil
        org-agenda-span 'day
        org-agenda-include-diary nil
        org-agenda-sorting-strategy
        '((agenda habit-down time-up effort-up category-keep)
          (todo category-up effort-up)
          (tags category-up effort-up)
          (search category-up))
        org-agenda-window-setup 'current-window
        org-agenda-custom-commands
        `(("N" "Notes" tags "NOTE"
           ((org-agenda-overriding-header "Notes")
            (org-tags-match-list-sublevels t)))
          ("g" "GTD"
           ((agenda "" nil)
            (tags "INBOX"
                  ((org-agenda-overriding-header "Inbox")
                   (org-tags-match-list-sublevels nil)))
            (stuck ""
                   ((org-agenda-overriding-header "Stuck Projects")
                    (org-agenda-tags-todo-honor-ignore-options t)
                    (org-tags-match-list-sublevels t)
                    (org-agenda-todo-ignore-scheduled 'future)))
            (tags-todo "-INBOX"
                       ((org-agenda-overriding-header "Next Actions")
                        (org-agenda-tags-todo-honor-ignore-options t)
                        (org-agenda-todo-ignore-scheduled 'future)
                        (org-agenda-skip-function
                         '(lambda ()
                            (or (org-agenda-skip-subtree-if 'todo '("HOLD" "WAITING"))
                                (org-agenda-skip-entry-if 'nottodo '("NEXT")))))
                        (org-tags-match-list-sublevels t)
                        (org-agenda-sorting-strategy
                         '(todo-state-down effort-up category-keep))))
            (tags-todo ,active-project-match
                       ((org-agenda-overriding-header "Projects")
                        (org-tags-match-list-sublevels t)
                        (org-agenda-sorting-strategy
                         '(category-keep))))
            (tags-todo "-INBOX/-NEXT"
                       ((org-agenda-overriding-header "Orphaned Tasks")
                        (org-agenda-tags-todo-honor-ignore-options t)
                        (org-agenda-todo-ignore-scheduled 'future)
                        (org-agenda-skip-function
                         '(lambda ()
                            (or (org-agenda-skip-subtree-if 'todo '("PROJECT" "HOLD" "WAITING" "DELEGATED"))
                                (org-agenda-skip-subtree-if 'nottodo '("TODO")))))
                        (org-tags-match-list-sublevels t)
                        (org-agenda-sorting-strategy
                         '(category-keep))))
            (tags-todo "/WAITING"
                       ((org-agenda-overriding-header "Waiting")
                        (org-agenda-tags-todo-honor-ignore-options t)
                        (org-agenda-todo-ignore-scheduled 'future)
                        (org-agenda-sorting-strategy
                         '(category-keep))))
            (tags-todo "/DELEGATED"
                       ((org-agenda-overriding-header "Delegated")
                        (org-agenda-tags-todo-honor-ignore-options t)
                        (org-agenda-todo-ignore-scheduled 'future)
                        (org-agenda-sorting-strategy
                         '(category-keep))))
            (tags-todo "-INBOX"
                       ((org-agenda-overriding-header "On Hold")
                        (org-agenda-skip-function
                         '(lambda ()
                            (or (org-agenda-skip-subtree-if 'todo '("WAITING"))
                                (org-agenda-skip-entry-if 'nottodo '("HOLD")))))
                        (org-tags-match-list-sublevels nil)
                        (org-agenda-sorting-strategy
                         '(category-keep))))
            ;; (tags-todo "-NEXT"
            ;;            ((org-agenda-overriding-header "All other TODOs")
            ;;             (org-match-list-sublevels t)))
            )))))

(add-hook 'org-agenda-mode-hook 'hl-line-mode)

(defun my/org-agenda-refresh-after-todo (&rest _)
  "Refresh the agenda after a TODO state change in the agenda buffer."
  (when (derived-mode-p 'org-agenda-mode)
    (org-agenda-redo)))

(with-eval-after-load 'org-agenda
  (unless (advice-member-p #'my/org-agenda-refresh-after-todo
                           'org-agenda-todo)
    (advice-add 'org-agenda-todo :after
                #'my/org-agenda-refresh-after-todo)))

;;; Org-roam

(use-package org-roam
  :ensure t
  :commands (org-roam-capture org-roam-db-sync)
  :init
  ;; 在首次加载 Org-roam 前就设置路径。
  (setq org-roam-directory org-directory
        org-roam-dailies-directory "journal/")

  :custom
  (org-roam-completion-everywhere t)
  (org-roam-node-display-template "${tags:50} ${title:*}")

  ;; 笔记统一保存在已有的 notes/ 分类目录中，不新建顶层目录。
  (org-roam-capture-templates
   '(("p" "project" plain "%?"
      :target
      (file+head "notes/projects/%<%Y%m%d%H%M%S>.org"
                 "#+title: ${title}\n#+filetags: :Project:")
      :unnarrowed t)
     ("l" "literature" plain "%?"
      :target
      (file+head "notes/reference/%<%Y%m%d%H%M%S>.org"
                 "#+title: ${title}\n#+filetags: :Literature:")
      :unnarrowed t)
     ("z" "zettel(permanent)" plain "%?"
      :target
      (file+head "notes/permanent/%<%Y%m%d%H%M%S>.org"
                 "#+title: ${title}\n#+filetags: :Permanent:")
      :unnarrowed t)))

  :bind
  (("C-c n l" . org-roam-buffer-toggle)
   ("C-c n f" . org-roam-node-find)
   ("C-c n i" . org-roam-node-insert)
   :map org-mode-map
   ("C-M-i" . completion-at-point))

  :config
  ;; 只确保现有笔记结构存在：notes/ 及其分类子目录、journal/。
  ;; 不在 org-roam-directory 顶层创建 projects/、reference/、permanent/。
  (dolist (dir '("notes/"
                 "notes/projects/"
                 "notes/reference/"
                 "notes/permanent/"
                 "journal/"))
    (make-directory (expand-file-name dir org-roam-directory) t))

  ;; 首次使用 Org-roam 时开启数据库自动同步。
  (org-roam-db-autosync-mode 1))


;; Dailies 随 Org-roam 一起加载，不在启动时强制加载 Org-roam。
(use-package org-roam-dailies
  :ensure nil                       ; 随 org-roam 提供
  :after org-roam
  :demand t

  :custom
  (org-roam-dailies-capture-templates
   '(("d" "default" entry
      "* %?"
      :target
      (file+head "%<%Y-%m-%d>.org"
                 "#+title: %<%Y-%m-%d>\n#+author: BinElo\n"))))

  :bind-keymap
  ("C-c n d" . org-roam-dailies-map)

  :config
  ;; The standard map is created by org-roam-dailies; add the two extra
  ;; capture commands after it loads.  `:bind' with `:map' cannot do this
  ;; because the map does not exist yet when init-org is evaluated.
  (keymap-set org-roam-dailies-map "Y" #'org-roam-dailies-capture-yesterday)
  (keymap-set org-roam-dailies-map "T" #'org-roam-dailies-capture-tomorrow))


;; 图谱：按快捷键时才加载并启动。
(use-package org-roam-ui
  :ensure t
  :after org-roam
  :commands org-roam-ui-mode
  :bind
  ("C-c n u" . org-roam-ui-mode)

  :custom
  (org-roam-ui-sync-theme t)
  (org-roam-ui-follow t)
  (org-roam-ui-update-on-save t)
  (org-roam-ui-open-on-start t))


;; 首次加载 Org-roam 后启用 Consult 集成。
(use-package consult-org-roam
  :ensure t
  :after org-roam
  :demand t

  :bind
  (("C-c n b" . consult-org-roam-backlinks)
   ("C-c n s" . consult-org-roam-search))

  :config
  (consult-org-roam-mode 1)

  ;; 禁用这几个 Consult 命令的自动预览。
  (consult-customize
   consult-org-roam-backlinks
   consult-org-roam-file-find
   consult-org-roam-search
   :preview-key nil))

;; The `:after org-roam' forms above are deferred until Org-roam is first
;; loaded, which would leave their bindings unavailable on a fresh session.
;; Bind the commands eagerly here; they are autoloaded, so pressing them loads
;; Org-roam (and the relevant extension) on demand.
(keymap-global-set "C-c n b" #'consult-org-roam-backlinks)
(keymap-global-set "C-c n s" #'consult-org-roam-search)
(keymap-global-set "C-c n u" #'org-roam-ui-mode)

(provide 'init-org)

;; init-org.el ends here.
